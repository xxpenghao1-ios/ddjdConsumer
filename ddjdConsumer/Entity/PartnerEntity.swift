//
//  PartnerEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/10.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
///众筹人
class PartnerEntity:Mappable {
    var storeAndPartnerId:Int?
    ///‘添加众筹人的时间’,
    var storeAndPartnerAddTime:String?
    /// ‘添加众筹人时填写的众筹人联系方式’,
    var storeAndPartnerMemberTel:String?
    ///‘联系名称’,
    var storeAndPartnerNickName:String?
    /// ‘众筹人占利润的百分比； 整数’,
    var storeAndPartnerBFB:Int?
    ///  ‘众筹人的出资金额 ； ‘,
    var storeAndPartneAmountOfPayment:Double?
    /// ‘为众筹人总共返回余额的月数’,
    var storeAndPartneMonthCount:Int?
    /// ‘还需要为众筹人返回多少月的余额’,
    var storeAndPartneSurplusMonthCount:Int?
    ///  ‘为众筹人每月返回多少余额’,
    var storeAndPartneMonthMoney:Double?
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        storeAndPartnerId <- map["storeAndPartnerId"]
        storeAndPartnerAddTime <- map["storeAndPartnerAddTime"]
        storeAndPartnerMemberTel <- map["storeAndPartnerMemberTel"]
        storeAndPartnerNickName <- map["storeAndPartnerNickName"]
        storeAndPartnerBFB <- map["storeAndPartnerBFB"]
        storeAndPartneAmountOfPayment <- map["storeAndPartneAmountOfPayment"]
        storeAndPartneMonthCount <- map["storeAndPartneMonthCount"]
        storeAndPartneSurplusMonthCount <- map["storeAndPartneSurplusMonthCount"]
        storeAndPartneMonthMoney <- map["storeAndPartneMonthMoney"]
    }
}
