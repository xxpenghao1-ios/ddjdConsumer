//
//  GoodEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/22.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper

//// 这个枚举包含所有图片的状态
//public enum MovieRecordState {
//    case new, downloaded, filtered, failed
//}
/// 商品entity
class GoodEntity:Mappable{
    var goodsId:Int?
    var goodsName:String? //‘商品名称’,
    var goodsUnit:String? //‘商品单位’,
    var goodsMixed:String? //‘商品配料’,
    var goodsLift:Int? //‘保质期（天）’,
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
    var goodsPrice:Double? //‘商品价格；参考价’,
    var weight:String? //‘重量’,
    var brand:String? // ‘商品品牌’,
    var stock:Int? //线上库存
    var offlineStock:Int? //线下库存
    var salesCount:Int? //销量
    var collectionStatu:Bool? //是否收藏  true收藏了 false 没有
    var storeAndGoodsId:Int? //店铺商品id
    var storeGoodsPrice:Double? //店铺商品价格
    var goodsCount:Int? //购物车商品数量
    var checkOrCance:Int? //是否选中 1. 选中  2. 不选中
    var shoppingCarId:Int? //购物车id
    var goodsMoney:Double? //订单商品价格
    var goodsCollectionId:Int? //商品收藏Id
    var indexGoodsId:Int? //不为空就表示该商品已经加入了首页商品
    var goodsStutas:Int? //3促销 1普通 2特价
    var promotionStock:Int? //促销库存
    var promotionMsg:String? //促销信息
    var promotionStartTime:String? //促销开始时间
    var promotionEndTime:String? //促销结束时间
    var promotionEndTimeSeconds:Int? //促销结束时间秒
    var purchasePrice:Double?//店铺进货价
    var examineInfo:String? //‘审核信息； 如果审核失败，此处要填入审核失败的原因’,
    var examineGoodsFlag:Int? //1. 审核中 2. 审核失败 3 审核成功’,
    var examineGoodsId:Int? ///审核商品id
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
        indexGoodsId <- map["indexGoodsId"]
        goodsStutas <- map["goodsStutas"]
        promotionStock <- map["promotionStock"]
        promotionMsg <- map["promotionMsg"]
        promotionStartTime <- map["promotionStartTime"]
        promotionEndTime <- map["promotionEndTime"]
        purchasePrice <- map["purchasePrice"]
        examineInfo <- map["examineInfo"]
        examineGoodsFlag <- map["examineGoodsFlag"]
        examineGoodsId <- map["examineGoodsId"]
    }
}
