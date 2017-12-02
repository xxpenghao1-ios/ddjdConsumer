//
//  GoodscategoryEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/12.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
///商品分类
class GoodscategoryEntity:Mappable{
    var goodsCategoryId:Int?
    var goodsCategoryName:String? //‘分类名称’,
    var goodsCategoryPid:Int?  //‘父级ID’,
    var goodsCategoryIco:String? //‘分类图片’,
    var goodsCategorySort:Int? //‘分类排序’,
    var goodsCategoryFlag:Int? //1显示，2不显示’,
    var arr2:[GoodscategoryEntity]? //保存下级分类
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    
    func mapping(map: Map) {
        goodsCategoryId <- map["goodsCategoryId"]
        goodsCategoryName <- map["goodsCategoryName"]
        goodsCategoryPid <- map["goodsCategoryPid"]
        goodsCategoryIco <- map["goodsCategoryIco"]
        goodsCategorySort <- map["goodsCategorySort"]
        goodsCategoryFlag <- map["goodsCategoryFlag"]
    }
    
    
}
