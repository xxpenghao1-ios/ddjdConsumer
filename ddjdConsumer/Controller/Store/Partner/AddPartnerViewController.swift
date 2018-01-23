//
//  AddPartnerViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/10.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import SVProgressHUD
class AddPartnerViewController:FormViewController{
    struct Static {
        static let memberAccTag = "memberAcc"
        static let memberTelTag = "memberTel"
        static let BFBTag = "BFB"
        static let nickNameTag = "nickName"
        static let storeAndPartneAmountOfPaymentTag = "storeAndPartneAmountOfPayment"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="添加合伙人"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
}
///页面设置
extension AddPartnerViewController{
    private func setUpView(){
        let form = FormDescriptor()
        let section1 = FormSectionDescriptor(headerTitle:"请填写合伙人相关信息", footerTitle: nil)
        var row = FormRowDescriptor(tag: Static.nickNameTag, type:.text, title:"姓名:")
        row.configuration.cell.placeholder="请输入合伙人姓名"
        section1.rows.append(row)

        row = FormRowDescriptor(tag: Static.memberAccTag, type:.phone, title:"账号:")
        row.configuration.cell.placeholder="请输入合伙人账号"
        section1.rows.append(row)

        row = FormRowDescriptor(tag: Static.memberTelTag, type:.phone, title:"联系方式:")
        row.configuration.cell.placeholder="请输入合伙人联系方式"
        section1.rows.append(row)

        row = FormRowDescriptor(tag: Static.storeAndPartneAmountOfPaymentTag, type:.decimal, title:"出资金额:")
        row.configuration.cell.placeholder="请输入合伙人出资金额"
        section1.rows.append(row)

        row = FormRowDescriptor(tag: Static.BFBTag, type:.number, title:"合伙人利润百分比(%):")
        row.configuration.cell.placeholder="请输入合伙人利润百分比"
        section1.rows.append(row)


        let section2=FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        row = FormRowDescriptor(tag:"button", type: .button, title:"提交")
        row.configuration.button.didSelectClosure = { _ in
            self.addPartnerByStore()
        }
        section2.rows.append(row)
        form.sections = [section1,section2]
        self.form=form
    }
}

// MARK: - 网络请求
extension AddPartnerViewController{

    private func addPartnerByStore(){
        let json=self.form.formValues()
        
        let memberAcc=json[Static.memberAccTag] as? String
        let memberTel=json[Static.memberTelTag] as? String
        let BFB=json[Static.BFBTag] as? String
        let nickName=json[Static.nickNameTag] as? String
        let storeAndPartneAmountOfPayment=json[Static.storeAndPartneAmountOfPaymentTag] as? String
        if memberAcc == nil || memberAcc!.count == 0{
            self.showInfo(withStatus:"合伙人账号不能为空")
            return
        }
        if memberTel == nil || memberTel!.count == 0{
            self.showInfo(withStatus:"合伙人联系方式不能为空")
            return
        }
        if BFB == nil || BFB!.count == 0{
            self.showInfo(withStatus:"合伙人利润百分比不能为空")
            return
        }
        if nickName == nil || nickName!.count == 0{
            self.showInfo(withStatus:"合伙人名称不能为空")
            return
        }
        if storeAndPartneAmountOfPayment == nil || storeAndPartneAmountOfPayment!.count == 0{
            self.showInfo(withStatus:"合伙人的出资金额不能为空")
            return
        }
        if Int(storeAndPartneAmountOfPayment!)! > 1000000{
            self.showInfo(withStatus:"合伙人的出资金额不能大于1百万")
            return
        }
        SVProgressHUD.show(withStatus:"正在请求...")
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreInfoApi.addPartnerByStore(storeId:STOREID, memberAcc:memberAcc!, memberTel: memberTel!, BFB:Int(BFB!) ?? 1, nickName: nickName!, storeAndPartneAmountOfPayment: storeAndPartneAmountOfPayment!), successClosure: { (json) in
            let success=json["success"].stringValue
            switch success{
            case "success":
                SVProgressHUD.showSuccess(withStatus:"添加合伙人成功")
                SVProgressHUD.setDefaultMaskType(.none)
                self.navigationController?.popViewController(animated:true)
                break
            case "bindPartnerExist":
                self.showInfo(withStatus:"此账号已经绑定合伙人信息,不能再绑定")
                break
            case "bindStoreError":
                self.showInfo(withStatus:"账号绑定店铺错误— 此账号并不是绑定的此店铺")
                break
            case "bindStoreNull":
                self.showInfo(withStatus:"账号没有绑定店铺")
                break
            case "accNotExist":
                self.showInfo(withStatus:"账号信息不存在")
                break
            case "exist":
                self.showInfo(withStatus:"合伙人数量已满，不能在添加")
                break
            case "error":
                self.showInfo(withStatus:"店铺已关闭")
                break
            case "notExist":
                self.showInfo(withStatus:"店铺信息不存了")
                break
            case "BFBerror":
                self.showInfo(withStatus:"百分比输入错误")
                break
            default:
                self.showError(withStatus:"添加失败")
                break
            }
        }) { (error) in
            self.showError(withStatus:error!)
        }
    }
    private func showInfo(withStatus:String){
        SVProgressHUD.showInfo(withStatus:withStatus)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.dismiss(withDelay:2)
    }
    private func showError(withStatus:String){
        SVProgressHUD.showError(withStatus:withStatus)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.dismiss(withDelay:2)
    }
}
