//
//  MemberAuthInfoEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/23.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
///授权用户信息
class MemberAuthInfoEntity:Mappable{
    var account:String?
    var nickName:String?
    var memberId:Int?
    var arr:[AuthEntity]?
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        account <- map["account"]
        nickName <- map["nickName"]
        memberId <- map["memberId"]
    }
}
