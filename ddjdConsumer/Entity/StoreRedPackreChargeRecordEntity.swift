//
//  StoreRedPackreChargeRecordEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/27.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper

/// 红包充值记录
class StoreRedPackreChargeRecordEntity:Mappable{
    var storeRedPackRechargeRecordId:Int?
    var rechargeMoney:Double? //充值金额
    var backRechargeMoney:Double? //充值金额 ； 会员扣除手续费后，实际到账金额；’,
    var redPackCount:Int? //充值时设置的红包数量
    var rechargeTime:String? //充值时间
    var rechargeStatu:Int? //默认1等待付款； 2充值成功
    var rechargeStoreId:Int? //充值店铺id
    var rechargeSN:String?  //系统充值单号
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        storeRedPackRechargeRecordId <- map["storeRedPackRechargeRecordId"]
        rechargeMoney <- map["rechargeMoney"]
        backRechargeMoney <- map["backRechargeMoney"]
        redPackCount <- map["redPackCount"]
        rechargeTime <- map["rechargeTime"]
        rechargeStatu <- map["rechargeStatu"]
        rechargeStoreId <- map["rechargeStoreId"]
        rechargeSN <- map["rechargeSN"]
    }
}
