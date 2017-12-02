//
//  OrderEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/26.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
class OrderEntity:Mappable{
    ///订单ID
    var orderId:Int?
    ///订单标号
    var orderSN:String?
    ///商品总数量
    var goodsAmount:Int?
    var goodsList:[GoodEntity]?
    ///订单状态 1. 待付款 2-待发货，3 已发货，4-已经完成 5. 申请退货，6 已退货
    var orderStatus:Int?
    ///订单总价
    var orderPrice:Double?
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        orderId <- map["orderId"]
        orderSN <- map["orderSN"]
        goodsAmount <- map["goodsAmount"]
        orderStatus <- map["orderStatus"]
        orderPrice <- map["orderPrice"]
    }
}
