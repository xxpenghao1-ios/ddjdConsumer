//
//  RedPackageRechargeViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/26.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import SVProgressHUD
import SwiftyJSON
/// 红包充值
class RedPackageRechargeViewController:FormViewController{
    struct Static {
        static let redPackagePriceTag = "redPackagePrice"
        static let redPackageCountTag = "redPackageCount"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="红包充值"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
}
///页面设置
extension RedPackageRechargeViewController{
    private func setUpView(){
        setUpNav()
        let form = FormDescriptor()
        let section1 = FormSectionDescriptor(headerTitle:nil, footerTitle:"说明:每个红包金额是随机产生")
        var row = FormRowDescriptor(tag: Static.redPackagePriceTag, type:.number, title:"红包金额")
        row.configuration.cell.placeholder="请输入红包金额"
        section1.rows.append(row)

        row = FormRowDescriptor(tag: Static.redPackageCountTag, type:.number, title:"红包个数")
        row.configuration.cell.placeholder="请输入红包个数"
        section1.rows.append(row)

        let section2=FormSectionDescriptor(headerTitle:"重要说明:由于第三方支付平台会收取0.6%手续费,如充值100最后红包总金额为99.4元。谢谢理解", footerTitle: nil)
        row = FormRowDescriptor(tag:"button", type: .button, title:"确认充值")
        row.configuration.button.didSelectClosure = { _ in
            self.submit(formValues:self.form.formValues())
        }
        section2.rows.append(row)
        form.sections = [section1,section2]
        self.form=form
    }

    private func setUpNav(){
        self.navigationItem.rightBarButtonItem=UIBarButtonItem.init(title:"充值记录", style: UIBarButtonItemStyle.done, target:self, action:#selector(pushRedPackageRechargeRecordVC))
    }
    @objc private func pushRedPackageRechargeRecordVC(){
        let vc=RedPackageRechargeRecordViewController()
        self.navigationController?.pushViewController(vc, animated:true)
    }
}

extension RedPackageRechargeViewController{
    private func submit(formValues:[String : AnyObject]){
        let json=JSON(formValues)
        let redPackCount=json[Static.redPackageCountTag].string
        let redPackMoney=json[Static.redPackagePriceTag].string
        if redPackMoney == nil || redPackMoney!.count == 0{
            self.showInfo(withStatus:"红包金额不能为空")
            return
        }
        if Int(redPackMoney!) == nil || Int(redPackMoney!)! < 100 {
            self.showInfo(withStatus:"红包金额必须大于100")
            return
        }
        if redPackCount == nil || redPackCount!.count == 0{
            self.showInfo(withStatus:"红包数量不能为空")
            return
        }
        if Int(redPackCount!) == nil || Int(redPackCount!)! <= 1 {
            self.showInfo(withStatus:"红包数量必须大于1")
            return
        }
        if Int(redPackCount!)! > 9000{
            self.showInfo(withStatus:"红包数量不能大于9000")
            return
        }
        let alert=UIAlertController.init(title:"", message:"请选择支付方式", preferredStyle: UIAlertControllerStyle.actionSheet)
        let wx=UIAlertAction.init(title:"微信", style: UIAlertActionStyle.default) { (action) in
            self.redPackageRecharge(payType:1, redPackCount: Int(redPackCount!)!, redPackMoney: Int(redPackMoney!)!)
        }
        let alipay=UIAlertAction.init(title:"支付宝", style: UIAlertActionStyle.default) { (action) in
            self.redPackageRecharge(payType:2, redPackCount: Int(redPackCount!)!, redPackMoney: Int(redPackMoney!)!)
        }
        let cancel=UIAlertAction.init(title:"取消", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(wx)
        alert.addAction(alipay)
        alert.addAction(cancel)
        self.present(alert, animated:true, completion:nil)
    }
    ///红包充值
    private func redPackageRecharge(payType:Int,redPackCount:Int,redPackMoney:Int){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:RedPackageApi.addRedPacket_store(storeId:STOREID, payType: payType, redPackCount: redPackCount, redPackMoney: redPackMoney), successClosure: { (json) in
            let success=json["success"].stringValue
            switch success{
            case "error":
                self.showInfo(withStatus:"红包个数必须大于1小于9000")
                break
            case "success":
                if payType == 1{
                    let charge=json["charge"]
                    let req=PayReq()
                    req.timeStamp=charge["timestamp"].uInt32Value
                    req.partnerId=charge["partnerid"].stringValue
                    req.package=charge["package"].stringValue
                    req.nonceStr=charge["noncestr"].stringValue
                    req.sign=charge["sign"].stringValue
                    req.prepayId=charge["prepayid"].stringValue
                    WXApiManager.shared.payAlertController(self, request: req, paySuccess: {
                        UIAlertController.showAlertYes(self, title:"", message:"充值成功", okButtonTitle:"确定", okHandler: { (action) in
                            self.navigationController?.popViewController(animated:true)
                        })
                        
                    }, payFail: {
                        SVProgressHUD.showError(withStatus:"充值失败")
                        SVProgressHUD.setDefaultMaskType(.none)
                    })
                }else if payType == 2{
                    let orderString=json["charge"]["orderString"].stringValue
                    AliPayManager.shared.payAlertController(self, request:orderString, paySuccess: {
                        UIAlertController.showAlertYes(self, title:"", message:"充值成功", okButtonTitle:"确定", okHandler: { (action) in
                            self.navigationController?.popViewController(animated:true)
                        })
                    }, payFail: {
                        SVProgressHUD.showError(withStatus:"充值失败")
                        SVProgressHUD.setDefaultMaskType(.none)
                    })
                }
                break
            default:
                SVProgressHUD.showError(withStatus:"充值失败")
                SVProgressHUD.setDefaultMaskType(.none)
            }
        }) { (error) in
            SVProgressHUD.showError(withStatus:error)
            SVProgressHUD.setDefaultMaskType(.none)
        }
    }
    private func showInfo(withStatus:String){
        SVProgressHUD.showInfo(withStatus:withStatus)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.dismiss(withDelay:2)
    }
}
