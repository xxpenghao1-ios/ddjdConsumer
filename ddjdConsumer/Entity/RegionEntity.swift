//
//  RegionEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/22.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
///区域信息
class PoiEntity:Mappable{
    var name:String?
    var city:String?
    var address:String?
    var lat:Double?
    var lon:Double?
    init(){}
    required init?(map: Map) {
        mapping(map: map)
    }
    func mapping(map: Map) {
    }
}
