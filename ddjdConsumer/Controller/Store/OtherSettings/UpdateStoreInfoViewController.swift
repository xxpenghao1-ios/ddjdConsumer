//
//  UpdateStoreInfoViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/25.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import SVProgressHUD
import SwiftyJSON
///设置店铺信息
class UpdateStoreInfoViewController:FormViewController{
    ///1最低起送额 2配送范围 3联系方式 4营业时间 5店铺折扣
    var type:Int?
    ///接收店铺信息
    var entity:StoreEntity?
    struct Static {
        static let telTag = "tel"
        static let distributionScopeTag  = "distributionScope"
        static let lowestMoneyTag  = "lowestMoney"
        static let distributionStartTimeTag  = "distributionStartTime"
        static let distributionEndTimeTag  = "distributionEndTime"
        static let memberDiscountTag = "memberDiscount"
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="设置店铺信息"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
}
///设置页面
extension UpdateStoreInfoViewController{
    
    private func setUpView(){
        let form = FormDescriptor()
        let section1 = FormSectionDescriptor(headerTitle:"修改店铺信息",footerTitle: nil)
        if type == 1{
            let row = FormRowDescriptor(tag:Static.lowestMoneyTag, type:.number, title:"最低起送金额:")
            row.configuration.cell.placeholder="请输入最低起送金额(元)"
            row.value=entity?.lowestMoney?.description as AnyObject
            section1.rows.append(row)
        }
        if type == 2{
            let row = FormRowDescriptor(tag:Static.distributionScopeTag, type:.decimal, title:"配送范围:")
            row.configuration.cell.placeholder="请输入配送范围(千米)"
            row.value=entity?.distributionScope?.description as AnyObject
            section1.rows.append(row)
        }
        if type == 3{
            let row = FormRowDescriptor(tag:Static.telTag, type:.text, title:"联系方式:")
            row.configuration.cell.placeholder="请输入联系方式"
            row.value=entity?.tel as AnyObject
            section1.rows.append(row)
        }
        if type == 4{
            var row = FormRowDescriptor(tag:Static.distributionStartTimeTag, type:.time, title:"开始营业时间")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            if entity?.distributionStartTime != nil{
                let date = dateFormatter.date(from:entity!.distributionStartTime!)
                row.value=date as AnyObject
            }
            section1.rows.append(row)
            
            row = FormRowDescriptor(tag:Static.distributionEndTimeTag, type:.time, title:"结束营业时间")
            if entity?.distributionEndTime != nil{
                let date = dateFormatter.date(from:entity!.distributionEndTime!)
                row.value=date as AnyObject
            }
            section1.rows.append(row)
        }
        if type == 5{
            let row = FormRowDescriptor(tag:Static.memberDiscountTag, type:.number, title:"会员折扣:")
            row.configuration.cell.placeholder="请输入折扣"
            row.value=entity?.memberDiscount?.description as AnyObject
            section1.rows.append(row)
        }

        let section2 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        let row = FormRowDescriptor(tag:"button", type: .button, title:"确认修改")
        row.configuration.button.didSelectClosure = { _ in
            self.updateStoreInfo()
        }
        section2.rows.append(row)
        form.sections = [section1,section2]
        self.form=form
    }
}
// MARK: - 网络请求
extension UpdateStoreInfoViewController{
    private func showInfo(withStatus:String){
        SVProgressHUD.showInfo(withStatus:withStatus)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.dismiss(withDelay:2)
    }
    private func showError(withStatus:String){
        SVProgressHUD.showInfo(withStatus:withStatus)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.dismiss(withDelay:2)
    }
    private func updateStoreInfo(){
        let values=JSON(self.form.formValues())
        let tel=values[Static.telTag].string
        let distributionScope=values[Static.distributionScopeTag].string
        let lowestMoney=values[Static.lowestMoneyTag].string
        let distributionStartTimeDate=values[Static.distributionStartTimeTag].string
        let distributionEndTimeDate=values[Static.distributionEndTimeTag].string
        let memberDiscount=values[Static.memberDiscountTag].string
        switch type! {
        case 1:
            guard lowestMoney != nil else {
                self.showInfo(withStatus:"订单起送金额不能为空")
                return
            }
        case 2:
            guard distributionScope != nil else{
                self.showInfo(withStatus:"配送范围不能为空")
                return
            }
        case 3:
            guard tel != nil else {
                self.showInfo(withStatus:"联系方式不能为空")
                return
            }
        case 4:
            return
        case 5:
            guard memberDiscount != nil else {
                self.showInfo(withStatus:"折扣不能为空")
                return
            }
        default:break

        }
        SVProgressHUD.show(withStatus:"正在修改...")
        SVProgressHUD.setDefaultMaskType(.clear)

        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreInfoApi.updateStoreInfo(storeId:STOREID, storeMsg:nil, tel:tel, distributionScope:Int(distributionScope ?? ""),lowestMoney:Int(lowestMoney ?? ""), distributionStartTime:distributionStartTimeDate, distributionEndTime:distributionEndTimeDate,memberDiscount:Int(memberDiscount ?? "")), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                SVProgressHUD.showSuccess(withStatus:"修改成功")
                SVProgressHUD.setDefaultMaskType(.none)
                self.navigationController?.popViewController(animated:true)
                if self.type == 1{
                    userDefaults.set(Int(lowestMoney ?? ""), forKey:"lowestMoney")
                    userDefaults.synchronize()
                }
            }else{
                self.showError(withStatus:"修改失败")
            }
        }) { (error) in
            self.showError(withStatus:error!)
        }
    }
}

