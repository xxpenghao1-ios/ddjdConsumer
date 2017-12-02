//
//  OrderDetailsEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/29.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
///订单详情entity
class OrderDetailsEntity:Mappable {
    ///下单订单的类型； 1，购物车中提交 ； 2，待付款中提交
    var orderType:Int?
    ///  店铺名称
    var storeName:String?
    ///  店铺电话
    var storeTel:String?
    ///下单时间
    var addTime:String?
    /// 订单id
    var orderId:Int?
    /// 订单编号
    var orderSN:String?
    ///  支付时间
    var payTime:String?
    ///商品总数
    var goodsAmount:Int?
    ///发货时间
    var shipTime:String?
    ///收货地址
    var shipaddress:String?
    ///1. 待付款 2-待发货，3 已发货，4-已经完成 5. 申请退货，6 已退货，7已取消，8.已失效
    var orderStatus:Int?
    ///  收货人姓名
    var shippName:String?
    ///订单失效时间
    var invalidTime:String?
    ///  店铺id
    var storeId:Int?
    ///支付方式，1.微信，2支付宝
    var payType:Int?
    ///订单完成日期
    var finishedTime:String?
    ///  '订单总价
    var orderPrice:Double?
    ///  收货人电话
    var tel:String?
    ///留言
    var payMessage:String?
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    
    func mapping(map: Map) {
        orderType <- map["orderType"]
        storeName <- map["storeName"]
        storeTel <- map["storeTel"]
        addTime <- map["addTime"]
        orderId <- map["orderId"]
        orderSN <- map["orderSN"]
        payTime <- map["payTime"]
        goodsAmount <- map["goodsAmount"]
        shipTime <- map["shipTime"]
        shipaddress <- map["shipaddress"]
        orderStatus <- map["orderStatus"]
        shippName <- map["shippName"]
        invalidTime <- map["invalidTime"]
        storeId <- map["storeId"]
        payType <- map["payType"]
        finishedTime <- map["finishedTime"]
        orderPrice <- map["orderPrice"]
        tel <- map["tel"]
        payMessage <- map["payMessage"]
    }
}
