//
//  StoreRedPackInfoEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/27.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper

/// 店铺红包信息
class StoreRedPackInfoEntity:Mappable{
    var storeRedPackId:Int?
    var storeId:Int?
    var storeRedPackCount:Int? //红包总数量’,
    var storeRedPackMoney:Double? //‘红包金额’,
    var storeRedPackAddTime:String? //店铺红包添加时间
    var storeRedPackSurplusCount:Int? //红包剩余数量
    var storeRedPackStatu:Int? //默认1是不可使用；2正常使用
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        storeRedPackId <- map["storeRedPackId"]
        storeId <- map["storeId"]
        storeRedPackCount <- map["storeRedPackCount"]
        storeRedPackMoney <- map["storeRedPackMoney"]
        storeRedPackAddTime <- map["storeRedPackAddTime"]
        storeRedPackSurplusCount <- map["storeRedPackSurplusCount"]
        storeRedPackStatu <- map["storeRedPackStatu"]
    }
}
