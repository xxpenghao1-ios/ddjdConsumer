//
//  AuthEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/22.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
///店铺可授权功能
class AuthEntity:Mappable{
    var authId:Int? //
    var authName:String? //‘授权功能名称’,
    var authNo:Int? // ‘授权编号； 比如 1 对应商品管理’,
    var isSelected:Bool? //是否选中授权功能  true选中 false未选中
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        authId <- map["authId"]
        authName <- map["authName"]
        authNo <- map["authNo"]
    }
}
