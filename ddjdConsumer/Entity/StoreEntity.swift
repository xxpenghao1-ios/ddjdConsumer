//
//  StoreEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/29.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
///店铺信息
class StoreEntity:Mappable{
    var storeId:Int?
    ///‘店铺名称’
    var storeName:String?
    ///‘店主名字’,
    var ownerName:String?
    ///‘联系电话’,
    var tel:String?
    ///‘店铺描述’,
    var applyRemark:String?
    ///‘状态 开启-1；关闭-2’,
    var state:Int?
    ///‘创建时间’,
    var ctime:String?
//    provinceId int(11) DEFAULT NULL COMMENT ‘省会Id’,
//    provinceText varchar(30) DEFAULT NULL COMMENT ‘省会名’,
//    cityId int(11) DEFAULT NULL COMMENT ‘城市ID’,
//    cityText varchar(30) DEFAULT NULL COMMENT ‘城市名’,
//    countyId int(11) DEFAULT NULL COMMENT ‘区县Id’,
//    countyText varchar(30) DEFAULT NULL COMMENT ‘区县名’,
    var address:String? //‘详细地址’,
    /// ‘店铺二维码’,
    var storeQRcode:String?
    ///‘配送范围（Km）’,
    var distributionScope:Int?
    /// ‘店铺设置的最低起送额； 整数’,
    var lowestMoney:Int?
    ///‘配送时间范围；开始时间’,
    var distributionStartTime:String?
    ///‘配送时间范围；结束时间’,
    var distributionEndTime:String?
    ///‘老板留言； 展示在消费者端’,
    var storeMsg:String?
    ///‘是否被会员绑定了 1. 未绑定 2. 绑定’,
    var bindFlag:Int?
    ///‘纬度’,
    var lat:String?
    ///‘经度’,
    var lon:String?
    /// 配送费
    var deliveryFee:Int?
    /// 店铺折扣
    var memberDiscount:Int?
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        storeId <- map["storeId"]
        storeName <- map["storeName"]
        ownerName <- map["ownerName"]
        tel <- map["tel"]
        applyRemark <- map["applyRemark"]
        state <- map["state"]
        ctime <- map["ctime"]
        address <- map["address"]
        storeQRcode <- map["storeQRcode"]
        distributionScope <- map["distributionScope"]
        lowestMoney <- map["lowestMoney"]
        distributionStartTime <- map["distributionStartTime"]
        distributionEndTime <- map["distributionEndTime"]
        storeMsg <- map["storeMsg"]
        bindFlag <- map["bindFlag"]
        lat <- map["lat"]
        lon <- map["lon"]
        deliveryFee <- map["deliveryFee"]
        memberDiscount <- map["memberDiscount"]
    }
}
