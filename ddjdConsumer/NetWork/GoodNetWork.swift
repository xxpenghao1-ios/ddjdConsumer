//
//  GoodNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/15.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya
//商品相关请求
public enum GoodApi{
    //查询商品详情  会员id  店铺商品id  会员绑定的店铺id 商品状态：1普通，3促销，只有促销是才会返回促销信息
    case getGoodsDetail(memberId:Int,storeAndGoodsId:Int,bindstoreId:Int,goodsStuta:Int)
    //收藏商品
    case addCollection(memberId:Int,storeAndGoodsId:Int)
    //搜索商品  priceFlag 价格排序 1.降序 2. 升序  salesCountFlag 销量排序1.降序 2. 升序
    case searchGood(memberId:Int,pageSize:Int,pageNumber:Int,bindstoreId:Int,goodsName:String,priceFlag:Int?,salesCountFlag:Int?)
    //根据3级分类id查询商品列表
    case goodListByCategoryId(memberId:Int,pageSize:Int,pageNumber:Int,bindstoreId:Int,tCategoryId:Int,priceFlag:Int?,salesCountFlag:Int?)
    ///删除收藏商品
    case removeCollection(memberId:Int,goodsCollectionId:Int)
    ///查询收藏商品
    case getAllCollection(memberId:Int,pageSize:Int,pageNumber:Int)
    ///历史购买
    case getGoodsOfBuyed(memberId:Int,pageSize:Int,pageNumber:Int)
    ///通过商品条码查询商品id
    case queryStoreAndGoodsByGoodsCode(goodsCode:String,bindstoreId:Int)
    ///查询促销商品列表
    case queryPromotiongoodsPaginate(memberId:Int,bindstoreId:Int,pageNumber:Int,pageSize:Int,salesCountFlag:Int?,priceFlag:Int?)
    
}
extension GoodApi:TargetType{
    public var headers: [String : String]? {
        return nil
    }
    ///URL详细路径
    public var path:String{
        switch self {
        case .getGoodsDetail(_,_,_,_):
            return "/front/goods/getGoodsDetail"
        case .addCollection(_,_):
            return "/front/collection/addCollection"
        case .searchGood(_,_,_,_,_,_,_),.goodListByCategoryId(_,_,_,_,_,_,_):
            return "/front/goods/getGoodsPaginate"
        case .removeCollection(_,_):
            return "/front/collection/removeCollection"
        case .getAllCollection(_,_,_):
            return "/front/collection/getAllCollection"
        case .getGoodsOfBuyed(_,_,_):
            return "/front/goods/getGoodsOfBuyed"
        case .queryStoreAndGoodsByGoodsCode(_,_):
            return "/front/goods/queryStoreAndGoodsByGoodsCode"
        case .queryPromotiongoodsPaginate(_,_,_,_,_,_):
            return "front/promotiongoods/queryPromotiongoodsPaginate"
        }
    }
    ///请求方式
    public var method:Moya.Method{
        switch  self {
        case .getGoodsDetail(_,_,_,_),.searchGood(_,_,_,_,_,_,_),.goodListByCategoryId(_,_,_,_,_,_,_),.getAllCollection(_,_,_),.getGoodsOfBuyed(_,_,_),.queryStoreAndGoodsByGoodsCode(_,_),.queryPromotiongoodsPaginate(_,_,_,_,_,_):
            return .get
        case .addCollection(_,_),.removeCollection(_,_):
            return .post
        }
    }
    //单元测试用
    public var sampleData:Data{
        return "".data(using:.utf8)!
    }
    //任务
    public var task: Task {
        switch self {
        case let .getGoodsDetail(memberId, storeAndGoodsId, bindstoreId,goodsStuta):
            return .requestParameters(parameters:["memberId":memberId,"storeAndGoodsId":storeAndGoodsId,"bindstoreId":bindstoreId,"goodsStuta":goodsStuta], encoding: URLEncoding.default)
        case let .addCollection(memberId, storeAndGoodsId):
            return .requestParameters(parameters:["memberId":memberId,"storeAndGoodsId":storeAndGoodsId], encoding: URLEncoding.default)
        case let .searchGood(memberId, pageSize, pageNumber, bindstoreId, goodsName, priceFlag,salesCountFlag):
            if priceFlag != nil{//按价格排序查
                return .requestParameters(parameters:["memberId":memberId,"pageSize":pageSize,"pageNumber":pageNumber,"bindstoreId":bindstoreId,"goodsName":goodsName,"priceFlag":priceFlag!], encoding:URLEncoding.default)
            }else{//按销量排序查
                return .requestParameters(parameters:["memberId":memberId,"pageSize":pageSize,"pageNumber":pageNumber,"bindstoreId":bindstoreId,"goodsName":goodsName,"salesCountFlag":salesCountFlag!], encoding:URLEncoding.default)
            }
        case let .goodListByCategoryId(memberId, pageSize, pageNumber,bindstoreId, tCategoryId, priceFlag,salesCountFlag):
            if priceFlag != nil{//按价格排序查
                return .requestParameters(parameters:["memberId":memberId,"pageSize":pageSize,"pageNumber":pageNumber,"bindstoreId":bindstoreId,"tCategoryId":tCategoryId,"priceFlag":priceFlag!], encoding:URLEncoding.default)
            }else{//按销量排序查
                return .requestParameters(parameters:["memberId":memberId,"pageSize":pageSize,"pageNumber":pageNumber,"bindstoreId":bindstoreId,"tCategoryId":tCategoryId,"salesCountFlag":salesCountFlag!], encoding:URLEncoding.default)
            }
        case let .removeCollection(memberId, goodsCollectionId):
            return .requestParameters(parameters:["memberId":memberId,"goodsCollectionId":goodsCollectionId], encoding: URLEncoding.default)
        case let .getAllCollection(memberId, pageSize, pageNumber):
            return .requestParameters(parameters:["memberId":memberId,"pageSize":pageSize,"pageNumber":pageNumber], encoding: URLEncoding.default)
        case let .getGoodsOfBuyed(memberId, pageSize, pageNumber):
            return .requestParameters(parameters:["memberId":memberId,"pageSize":pageSize,"pageNumber":pageNumber], encoding: URLEncoding.default)
        case let .queryStoreAndGoodsByGoodsCode(goodsCode,bindstoreId):
            return .requestParameters(parameters:["goodsCode":goodsCode,"bindstoreId":bindstoreId], encoding: URLEncoding.default)
        case let .queryPromotiongoodsPaginate(memberId, bindstoreId, pageNumber, pageSize, salesCountFlag, priceFlag):
            return .requestParameters(parameters:["memberId":memberId,"bindstoreId":bindstoreId,"pageNumber":pageNumber,"pageSize":pageSize,"salesCountFlag":salesCountFlag ?? "","priceFlag":priceFlag ?? ""],encoding:URLEncoding.default)
        }
    }
}
