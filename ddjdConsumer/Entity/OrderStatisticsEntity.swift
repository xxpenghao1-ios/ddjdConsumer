//
//  OrderStatisticsEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/18.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
///订单统计
class OrderStatisticsEntity:Mappable{
    var orderPrice:Double?
    var dateStr:String?
    var orderCount:Int?
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    
    func mapping(map: Map) {
        orderPrice <- map["orderPrice"]
        dateStr <- map["dateStr"]
        orderCount <- map["orderCount"]
    }
    
    
}
