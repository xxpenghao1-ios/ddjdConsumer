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
            row.configuration.cell.placeholder="请输入折扣(如输入95,余额支付95折)"
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
        let dateFormatter=DateFormatter()
        dateFormatter.dateFormat="HH:mm"
        dateFormatter.timeZone=TimeZone(abbreviation: "GMT")
        let values=self.form.formValues()
        let tel=values[Static.telTag] as? String
        let distributionScope=values[Static.distributionScopeTag] as? String
        let lowestMoney=values[Static.lowestMoneyTag] as? String
        let distributionStartTime=values[Static.distributionStartTimeTag] as? String
        let distributionEndTime=values[Static.distributionEndTimeTag] as? String
        let memberDiscount=values[Static.memberDiscountTag] as? String
        switch type! {
        case 1:
            guard lowestMoney != nil else {
                self.showInfo(withStatus:"订单起送金额不能为空")
                return
            }
            if Int(lowestMoney!) == nil || Int(lowestMoney!)! < 1{
                self.showInfo(withStatus:"订单起送金额不能小于1")
                return
            }
        case 2:
            guard distributionScope != nil else{
                self.showInfo(withStatus:"配送范围不能为空")
                return
            }
            if Int(distributionScope!) == nil || Int(distributionScope!)! < 1{
                self.showInfo(withStatus:"配送范围不能小于1公里")
                return
            }
        case 3:
            guard tel != nil else {
                self.showInfo(withStatus:"联系方式不能为空")
                return
            }
        case 4:
            if distributionStartTime == nil{
                self.showInfo(withStatus:"开始营业时间不能为空")
                return
            }
            if distributionEndTime == nil{
                self.showInfo(withStatus:"结束营业时间不能为空")
                return
            }
            ///营业开始时间Date
            let startTimeDate=dateFormatter.date(from:distributionStartTime!)
            ///营业结束时间Date
            let endTimeDate=dateFormatter.date(from:distributionEndTime!)
            if startTimeDate != nil && endTimeDate != nil{
                if startTimeDate!.compare(endTimeDate!) == .orderedDescending{//如果开始时间 大于结束时间
                    self.showInfo(withStatus:"开始时间不能大于结束时间")
                    return
                }
            }
        case 5:
            guard memberDiscount != nil else {
                self.showInfo(withStatus:"折扣不能为空")
                return
            }
            if Int(memberDiscount!) == nil || Int(memberDiscount!)! < 10{
                self.showInfo(withStatus:"折扣不能小于10")
                return
            }
        default:break

        }
        SVProgressHUD.show(withStatus:"正在修改...")
        SVProgressHUD.setDefaultMaskType(.clear)

        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreInfoApi.updateStoreInfo(storeId:STOREID, storeMsg:nil, tel:tel, distributionScope:Int(distributionScope ?? ""),lowestMoney:Int(lowestMoney ?? ""), distributionStartTime:distributionStartTime, distributionEndTime:distributionEndTime,memberDiscount:Int(memberDiscount ?? "")), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                SVProgressHUD.showSuccess(withStatus:"修改成功")
                SVProgressHUD.setDefaultMaskType(.none)
                self.navigationController?.popViewController(animated:true)
                if self.type == 1{
                    userDefaults.set(Int(lowestMoney ?? ""), forKey:"lowestMoney")
                    userDefaults.synchronize()
                }
            }else if success == "memberDiscountMaxOrMin"{
                self.showError(withStatus:"填写的折扣数不能大于100 或小于 10")
            }else{
                self.showError(withStatus:"修改失败")
            }
        }) { (error) in
            self.showError(withStatus:error!)
        }
    }
}

