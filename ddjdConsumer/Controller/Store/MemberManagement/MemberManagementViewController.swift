//
//  MemberManagementViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/23.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///会员管理
class MemberManagementViewController:BaseViewController{
    ///普通会员
    @IBOutlet weak var lblMemberOrdinary: UILabel!
    ///VIP会员
    @IBOutlet weak var lblMemberVIP: UILabel!
    ///合伙人会员
    @IBOutlet weak var lblMemberPartner: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="会员管理"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        queryBindStoreMemberCount()
    }
}
///网络请求
extension MemberManagementViewController{
    ///包括绑定了店铺的总会员数量； 其中包括多少合伙人数量，多少会员数量
    private func queryBindStoreMemberCount(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreInfoApi.queryBindStoreMemberCount(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description, dicAny: ["storeId":STOREID])), successClosure: { (json) in
            let bindSum=json["bindSum"].intValue
            let vipSum=json["vipSum"].intValue
            let partnerSum=json["partnerSum"].intValue
            self.lblMemberOrdinary.text=(bindSum-vipSum-partnerSum).description
            self.lblMemberVIP.text=vipSum.description
            self.lblMemberPartner.text=partnerSum.description
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
