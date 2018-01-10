//
//  BalanceRecordEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/4.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
///余额记录
class BalanceRecordEntity:Mappable {

    ///记录id
    var memberBalanceRecordId:Int?
    /// ‘1，充值获得；2，赠送获得；3，下单使用扣除；4提现扣除’,
    var memberBalanceRecordType:Int?
    /// ‘操作余额’,
    var memberBalanceRecordMoney:Double?
    /// 会员id
    var memberBalanceRecordMemberId:Int?
    ///‘增加余额还是减少余额 ；1 增加； 2 减少’,
    var memberBalanceRecordStatu:Int?
    /// 时间
    var memberBalanceRecordTime:String?
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }

    func mapping(map: Map) {
        memberBalanceRecordId <- map["memberBalanceRecordId"]
        memberBalanceRecordType <- map["memberBalanceRecordType"]
        memberBalanceRecordMoney <- map["memberBalanceRecordMoney"]
        memberBalanceRecordMemberId <- map["memberBalanceRecordMemberId"]
        memberBalanceRecordStatu <- map["memberBalanceRecordStatu"]
        memberBalanceRecordTime <- map["memberBalanceRecordTime"]
    }
}
