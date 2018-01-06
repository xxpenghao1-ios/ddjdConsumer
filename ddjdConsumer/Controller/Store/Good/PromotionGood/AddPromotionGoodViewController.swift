//
//  AddPromotionGoodViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/6.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import SwiftyJSON
import SVProgressHUD
import ObjectMapper
///加入促销
class AddPromotionGoodViewController:FormViewController{
    var storeAndGoodsId:Int?
    var reloadListClosure:(() -> Void)?
    struct Static {
        static let promotionStartTimeTag = "promotionStartTime"
        static let promotionEndTimeTag = "promotionEndTime"
        static let promotionMsgTag = "promotionMsg"
        static let promotionStockTag = "promotionStock"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="加入促销"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
}
///页面设置
extension AddPromotionGoodViewController{
    private func setUpView(){
        let form = FormDescriptor()
        let section1 = FormSectionDescriptor(headerTitle:"请填写相关信息", footerTitle: nil)
        var row = FormRowDescriptor(tag: Static.promotionStartTimeTag, type:.dateAndTime, title:"促销开始时间")
        section1.rows.append(row)

        row = FormRowDescriptor(tag: Static.promotionEndTimeTag, type:.dateAndTime, title:"促销结束时间")
        section1.rows.append(row)

        row = FormRowDescriptor(tag: Static.promotionStockTag, type: .number, title:"促销库存")
        row.configuration.cell.placeholder="请输入促销库存"
        section1.rows.append(row)

        let section2 = FormSectionDescriptor(headerTitle:"请输入促销信息", footerTitle: nil)
        row = FormRowDescriptor(tag: Static.promotionMsgTag, type:.multilineText, title:"")
        section2.rows.append(row)

        let section3=FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        row = FormRowDescriptor(tag:"button", type: .button, title:"提交")
        row.configuration.button.didSelectClosure = { _ in
            self.addPromotiongoods()
        }
        section3.rows.append(row)
        form.sections = [section1,section2,section3]
        self.form=form
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
// MARK: - 网络请求
extension AddPromotionGoodViewController{
    private func addPromotiongoods(){
        let json=self.form.formValues()
        print(json)
        let promotionStartTime=json[Static.promotionStartTimeTag] as? Date
        let promotionEndTime=json[Static.promotionEndTimeTag] as? Date
        let promotionMsg=json[Static.promotionMsgTag] as? String
        let promotionStock=json[Static.promotionStockTag] as? String
        if promotionStartTime == nil{
            self.showInfo(withStatus:"请选择促销开始时间")
            return
        }
        if promotionEndTime == nil{
            self.showInfo(withStatus:"请选择促销结束时间")
            return
        }
        guard promotionStartTime!.compare(promotionEndTime!) == .orderedAscending else {
            self.showInfo(withStatus:"促销结束时间不能小于开始时间")
            return
        }
        if promotionMsg == nil || promotionMsg!.count == 0{
            self.showInfo(withStatus:"促销信息不能为空")
            return
        }
        if promotionStock == nil || promotionStock!.count == 0{
            self.showInfo(withStatus:"促销库存不能为空")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        print(dateFormatter.string(from:promotionStartTime!))
        SVProgressHUD.show(withStatus:"正在提交...")
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.addPromotiongoods(storeAndGoodsId:storeAndGoodsId ?? 0, storeId:STOREID, promotionStartTime:dateFormatter.string(from:promotionStartTime!), promotionEndTime:dateFormatter.string(from:promotionEndTime!), promotionMsg:promotionMsg!, promotionStock:Int(promotionStock!)!), successClosure: { (json) in
            print(json)
            let success=json["success"].stringValue
            if success == "success"{
                SVProgressHUD.showSuccess(withStatus:"成功加入促销")
                SVProgressHUD.setDefaultMaskType(.none)
                self.reloadListClosure?()
                self.navigationController?.popViewController(animated:true)
            }else if success == "exist"{
                self.showInfo(withStatus:"商品已加入促销")
            }else if success == "storeDifferent"{
                self.showInfo(withStatus:"店铺不对应，这个商品不是这个店铺的")
            }else if success == "underStock"{
                self.showInfo(withStatus:"库存不足")
            }else{
                self.showError(withStatus:"加入促销失败")
            }
        }) { (error) in
            self.showError(withStatus:error!)
        }
    }
}
