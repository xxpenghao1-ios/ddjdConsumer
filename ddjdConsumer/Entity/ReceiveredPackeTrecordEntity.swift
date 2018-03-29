//
//  ReceiveredPackeTrecordEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/27.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
///红包领取记录
class ReceiveredPackeTrecordEntity:Mappable{
    var receiveTime:String?
    var memberId:Int?
    var receiveMoney:Double?
    var account:String?
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        receiveTime <- map["receiveTime"]
        memberId <- map["memberId"]
        receiveMoney <- map["receiveMoney"]
        account <- map["account"]
    }
}
