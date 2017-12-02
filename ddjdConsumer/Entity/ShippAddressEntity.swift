//
//  ShippAddressEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/13.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
//收货地址管理
class ShippAddressEntity:Mappable{
    var shippAddressId:Int? //‘收货地址的主键’,
    var lat:String? //‘地图坐标 纬度
    var lon:String? //地图坐标 经度
    var address:String? //‘收货地址（选中的那个地址）’,
    var detailAddress:String? //‘详细地址(会员自己填写的门牌号等等)’,
    var shippName:String? //‘收货人姓名’,
    var phoneNumber:String?//‘联系电话’,
    var defaultFlag:Int? //‘是否为默认，1—是，2—否’,
    var memberId:Int? //‘会员id’,
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        shippAddressId <- map["shippAddressId"]
        lat <- map["lat"]
        lon <- map["lon"]
        address <- map["address"]
        detailAddress <- map["detailAddress"]
        shippName <- map["shippName"]
        phoneNumber <- map["phoneNumber"]
        defaultFlag <- map["defaultFlag"]
        memberId <- map["memberId"]
    }
}
