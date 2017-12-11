//
//  GoodUploadEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/7.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
class GoodUploadEntity:Mappable {
    var goodsId:Int?
    var goodsName:String? //‘商品名称’,
    var goodsUnit:String? //‘商品单位’,
    var goodsMixed:String? //‘商品配料’,
    var goodsLift:String? //‘保质期（天）’,
    var goodsCode:String? //‘商品条码’,
    var remark:String?  //‘商品描述富文本描述’,
    var fCategoryId:Int? //‘一级分类(关联商品分类的一个Id)’,
    var sCategoryId:Int? //‘二级分类(关联商品分类的一个Id)’,
    var tCategoryId:Int? //‘三级分类(关联商品分类的一个Id)’,
    var goodsCategoryName:String? //分类名称
    var goodsPic:String? //‘商品展示首图（即封面图片）’,
    var ctime:String? //‘商品上传时间’,
    var goodsFlag:Int? //‘1：上架，2 下架 3. 审核中 4. 审核失败’,
    var goodUcode:String? //‘商品规格’,
    var provinceId:Int? //
    var provinceText:String? //
    var cityId:Int? //
    var countyId:Int? //
    var countyText:String? //
    var goodsPrice:String? //‘商品价格；参考价’,
    var weight:String? //‘重量’,
    var brand:String? // ‘商品品牌’,
    var stock:String? //线上库存
    var offlineStock:String? //线下库存
    var salesCount:Int? //销量
    var collectionStatu:Bool? //是否收藏  true收藏了 false 没有
    var storeAndGoodsId:Int? //店铺商品id
    var storeGoodsPrice:Double? //店铺商品价格
    var goodsCount:Int? //购物车商品数量
    var checkOrCance:Int? //是否选中 1. 选中  2. 不选中
    var shoppingCarId:Int? //购物车id
    var goodsMoney:Double? //订单商品价格
    var goodsCollectionId:Int? //商品收藏Id
    init(){}
    required init?(map: Map) {
        mapping(map: map)
    }
    func mapping(map: Map) {
        goodsId <- map["goodsId"]
        goodsName <- map["goodsName"]
        goodsUnit <- map["goodsUnit"]
        goodsMixed <- map["goodsMixed"]
        goodsLift <- map["goodsLift"]
        goodsCode <- map["goodsCode"]
        remark <- map["remark"]
        fCategoryId <- map["fCategoryId"]
        sCategoryId <- map["sCategoryId"]
        tCategoryId <- map["tCategoryId"]
        goodsCategoryName <- map["goodsCategoryName"]
        goodsPic <- map["goodsPic"]
        ctime <- map["ctime"]
        goodsFlag <- map["goodsFlag"]
        goodUcode <- map["goodUcode"]
        provinceId <- map["provinceId"]
        provinceText <- map["provinceText"]
        cityId <- map["cityId"]
        countyId <- map["countyId"]
        countyText <- map["countyText"]
        goodsPrice <- map["goodsPrice"]
        weight <- map["weight"]
        brand <- map["brand"]
        stock <- map["stock"]
        offlineStock <- map["offlineStock"]
        salesCount <- map["salesCount"]
        collectionStatu <- map["collectionStatu"]
        storeAndGoodsId <- map["storeAndGoodsId"]
        storeGoodsPrice <- map["storeGoodsPrice"]
        goodsCount <- map["goodsCount"]
        checkOrCance <- map["checkOrCance"]
        shoppingCarId <- map["shoppingCarId"]
        goodsMoney <- map["goodsMoney"]
        goodsCollectionId <- map["goodsCollectionId"]
    }
}
