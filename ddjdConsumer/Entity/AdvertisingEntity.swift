//
//  AdvertisingEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/14.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
//广告entity
class AdvertisingEntity:Mappable{
    var advertisingName:String? //  广告名称
    var advertisingURL:String? //  图片路径
    var advertisingDisable:Int? //是否禁用此广告  ，默认1开启。2禁用
    var goodsId:Int? // 商品id  当advertisingFlag = 2时才起作用
    var goUrl:String? //跳转路径  当advertisingFlag = 3 才起作用
    var advertisingId:Int? //广告主键id
    var advertisingFlag:Int? // 默认状态为1，不跳转; 2，跳转商品详情  3. 跳转网页
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        advertisingName <- map["advertisingName"]
        advertisingURL <- map["advertisingURL"]
        advertisingDisable <- map["advertisingDisable"]
        goodsId <- map["goodsId"]
        goUrl <-  map["goUrl"]
        advertisingId <- map["advertisingId"]
        advertisingFlag <- map["advertisingFlag"]
    }
}
