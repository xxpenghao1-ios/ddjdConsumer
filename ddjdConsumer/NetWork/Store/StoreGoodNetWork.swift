//
//  StoreGoodNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/20.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya
//店铺商品相关api
public enum StoreGoodApi{
    //商品上传
    case storeUploadGoodsInfo(goodsCode:String,storeId:Int,goodsName:String,goodsUnit:String,goodsLift:Int,goodUcode:String,fCategoryId:Int,sCategoryId:Int,tCategoryId:Int,goodsPic:String,goodsPrice:String,goodsFlag:Int,stock:Int,remark:String?,weight:Int?,brand:String?,goodsMixed:String?,purchasePrice:String,offlineStock:Int)
    //图片上传
    case start(filePath:String,pathName:String)
    //验证条码是否存在；如果存在，就返回公共商品库的商品信息，且同时返回这个店铺是否已经拥有了这个商品（根据exist判断），如果值为true表明已经拥有，且同时返回店铺的商品信息（querySag），如果值为false，表明没有拥有;如果不存在，直接返回 notExist
    case queryGoodsCodeIsExist(goodsCode:String,storeId:Int)
    //店铺查询自己的商品
    case queryStoreAndGoodsList(storeId:Int,goodsFlag:Int,pageNumber:Int,pageSize:Int,tCategoryId:Int?)
    //店铺商品上下架
    case updateGoodsFlagByStoreAndGoodsId(storeAndGoodsId:Int,goodsFlag:Int)
    //修改店铺信息
    case updateGoodsByStoreAndGoodsId(storeAndGoodsId:Int,goodsFlag:Int?,storeGoodsPrice:String?,stock:String?,offlineStock:String?,purchasePrice:String?)
    //查询店铺商品详情
    case queryStoreAndGoodsDetail(storeAndGoodsId:Int,storeId:Int)
    ///分配到店铺商品库 单个商品
    case addGoodsInfoGoToStoreAndGoods_detail(storeId:Int,goodsId:Int,storeGoodsPrice:String,goodsFlag:Int,stock:Int,offlineStock:Int,purchasePrice:String)
    ///店铺查询公共商品库 ； 不包括当前店铺已经添加的商品
    case queryGoodsInfoList_store(storeId:Int,pageNumber:Int,pageSize:Int,goodsName:String?,tCategoryId:Int?)
    ///店铺查询公共商品库商品详情
    case queryGoodsInfoByGoodsId_store(goodsId:Int)
    ///店铺选择公共商品库的商品，添加到店铺自己的商品库 ; 列表单选或多选添加，只是单纯的添加到店铺商品库，并没有上架，也没有价格，库存等属性。
    case addGoodsInfoGoToStoreAndGoods(storeId:Int,goodsId:String)
    ///店铺添加首页商品 sort
    case addIndexGoods(storeAndGoodsId:Int,storeId:Int,sort:Int)
    ///删除首页商品
    case removeIndexGoods(storeAndGoodsId:Int,storeId:Int)
    ///添加促销商品
    case addPromotiongoods(storeAndGoodsId:Int,storeId:Int,promotionStartTime:String,promotionEndTime:String,promotionMsg:String,promotionStock:Int)
    ///移除店铺促销商品
    case removePromotiongoods(storeAndGoodsId:Int,storeId:Int)
    ///查询促销商品列表-店铺
    case queryPromotiongoodsPaginateStore(storeId:Int,pageNumber:Int,pageSize:Int,salesCountFlag:Int?,priceFlag:Int?)
    
    
}
extension StoreGoodApi:TargetType{
    public var baseURL: URL {
        return URL.init(string:url)!
    }
    
    public var path: String {
        switch self {
        case .storeUploadGoodsInfo(_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_):
            return "/front/storeUploadGoods/storeUploadGoodsInfo"
        case .start(_,_):
            return "/upload/start"
        case .queryGoodsCodeIsExist(_,_):
            return "/front/storeUploadGoods/queryGoodsCodeIsExist"
        case .queryStoreAndGoodsList(_,_,_,_,_):
            return "/front/storeAndGoods/queryStoreAndGoodsList"
        case .updateGoodsFlagByStoreAndGoodsId(_,_):
            return "/front/storeAndGoods/updateGoodsFlagByStoreAndGoodsId"
        case .updateGoodsByStoreAndGoodsId(_,_,_,_,_,_):
            return "/front/storeAndGoods/updateGoodsByStoreAndGoodsId"
        case .queryStoreAndGoodsDetail(_,_):
            return "/front/storeAndGoods/queryStoreAndGoodsDetail"
        case .addGoodsInfoGoToStoreAndGoods_detail(_,_,_,_,_,_,_):
            return "/front/storeAndGoods/addGoodsInfoGoToStoreAndGoods_detail"
        case .queryGoodsInfoList_store(_,_,_,_,_):
            return "/front/storeAndGoods/queryGoodsInfoList_store"
        case .queryGoodsInfoByGoodsId_store(_):
            return "/front/storeAndGoods/queryGoodsInfoByGoodsId_store"
        case .addGoodsInfoGoToStoreAndGoods(_,_):
            return "/front/storeAndGoods/addGoodsInfoGoToStoreAndGoods"
        case .addIndexGoods(_,_,_):
            return "/front/storeAndGoods/addIndexGoods"
        case .removeIndexGoods(_,_):
            return "/front/storeAndGoods/removeIndexGoods"
        case .addPromotiongoods(_,_,_,_,_,_):
            return "/front/promotiongoods/addPromotiongoods"
        case .removePromotiongoods(_,_):
            return "/front/promotiongoods/removePromotiongoods"
        case .queryPromotiongoodsPaginateStore(_,_,_,_,_):
            return "/front/promotiongoods/queryPromotiongoodsPaginateStore"

        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .storeUploadGoodsInfo(_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_),.start(_,_),.updateGoodsFlagByStoreAndGoodsId(_,_),.updateGoodsByStoreAndGoodsId(_,_,_,_,_,_),.addGoodsInfoGoToStoreAndGoods_detail(_,_,_,_,_,_,_),.addGoodsInfoGoToStoreAndGoods(_,_),.addIndexGoods(_,_,_),.removeIndexGoods(_,_),.addPromotiongoods(_,_,_,_,_,_),.removePromotiongoods(_,_):
            return .post
        case .queryGoodsCodeIsExist(_,_),.queryStoreAndGoodsList(_,_,_,_,_),.queryStoreAndGoodsDetail(_,_),.queryGoodsInfoList_store(_,_,_,_,_),.queryGoodsInfoByGoodsId_store(_),.queryPromotiongoodsPaginateStore(_,_,_,_,_):
            return .get
        }
    }
    
    public var sampleData: Data {
        return "".data(using:.utf8)!
    }
    public var task: Task {
        switch self {
        case let .storeUploadGoodsInfo(goodsCode, storeId, goodsName, goodsUnit, goodsLift, goodUcode, fCategoryId, sCategoryId, tCategoryId, goodsPic, goodsPrice, goodsFlag, stock, remark, weight,brand, goodsMixed,purchasePrice,offlineStock):
            return .requestParameters(parameters:["goodsCode":goodsCode,"storeId":storeId,"goodsName":goodsName,"goodsUnit":goodsUnit,"goodsLift":goodsLift,"goodUcode":goodUcode,"fCategoryId":fCategoryId,"sCategoryId":sCategoryId,"tCategoryId":tCategoryId,"goodsPic":goodsPic,"goodsPrice":goodsPrice,"goodsFlag":goodsFlag,"stock":stock,"remark":remark ?? "","weight":weight ?? "","brand":brand ?? "","goodsMixed":goodsMixed ?? "","purchasePrice":purchasePrice,"offlineStock":offlineStock], encoding:URLEncoding.default)
        case let .start(filePath,pathName):
            let imgData = MultipartFormData(provider: MultipartFormData.FormDataProvider.file(Foundation.URL(fileURLWithPath:filePath)),name:"file")
            let urlParameters = ["path":pathName]
            return .uploadCompositeMultipart([imgData],urlParameters: urlParameters)
        case let .queryGoodsCodeIsExist(goodsCode, storeId):
            return .requestParameters(parameters:["goodsCode":goodsCode,"storeId":storeId], encoding:URLEncoding.default)
        case let .queryStoreAndGoodsList(storeId, goodsFlag, pageNumber, pageSize,tCategoryId):
            if tCategoryId == nil{
                return .requestParameters(parameters:["storeId":storeId,"goodsFlag":goodsFlag,"pageNumber":pageNumber,"pageSize":pageSize],encoding:URLEncoding.default)
            }else{
                return .requestParameters(parameters:["storeId":storeId,"goodsFlag":goodsFlag,"pageNumber":pageNumber,"pageSize":pageSize,"tCategoryId":tCategoryId!],encoding:URLEncoding.default)
            }
        case let .updateGoodsFlagByStoreAndGoodsId(storeAndGoodsId, goodsFlag):
            return .requestParameters(parameters:["storeAndGoodsId":storeAndGoodsId,"goodsFlag":goodsFlag], encoding: URLEncoding.default)
        case let .updateGoodsByStoreAndGoodsId(storeAndGoodsId, goodsFlag, storeGoodsPrice, stock, offlineStock,purchasePrice):
            return .requestParameters(parameters:["storeAndGoodsId":storeAndGoodsId,"goodsFlag":goodsFlag ?? "","storeGoodsPrice":storeGoodsPrice ?? "","stock":stock ?? "","offlineStock":offlineStock ?? "","purchasePrice":purchasePrice ?? ""], encoding: URLEncoding.default)
        case let .queryStoreAndGoodsDetail(storeAndGoodsId, storeId):
            return .requestParameters(parameters:["storeAndGoodsId":storeAndGoodsId,"storeId":storeId], encoding: URLEncoding.default)
        case let .addGoodsInfoGoToStoreAndGoods_detail(storeId, goodsId, storeGoodsPrice, goodsFlag, stock, offlineStock,purchasePrice):
            
            return .requestParameters(parameters: ["storeId":storeId,"goodsId":goodsId,"storeGoodsPrice":storeGoodsPrice,"goodsFlag":goodsFlag,"stock":stock,"offlineStock":offlineStock,"purchasePrice":purchasePrice], encoding:URLEncoding.default)
        case let .queryGoodsInfoList_store(storeId, pageNumber, pageSize, goodsName, tCategoryId):
            if tCategoryId == nil{
                return .requestParameters(parameters:["storeId":storeId,"pageNumber":pageNumber,"pageSize":pageSize,"goodsName":goodsName ?? ""], encoding: URLEncoding.default)
            }else{
                return .requestParameters(parameters:["storeId":storeId,"pageNumber":pageNumber,"pageSize":pageSize,"goodsName":goodsName ?? "","tCategoryId":tCategoryId!], encoding: URLEncoding.default)
            }
        case let .queryGoodsInfoByGoodsId_store(goodsId):
            return .requestParameters(parameters:["goodsId":goodsId], encoding: URLEncoding.default)
        case let .addGoodsInfoGoToStoreAndGoods(storeId, goodsId):
            return .requestParameters(parameters:["storeId":storeId,"goodsId":goodsId], encoding: URLEncoding.default)
        case let .addIndexGoods(storeAndGoodsId, storeId, sort):
            return .requestParameters(parameters:["storeAndGoodsId":storeAndGoodsId,"storeId":storeId,"sort":sort],encoding: URLEncoding.default)
        case let .removeIndexGoods(storeAndGoodsId, storeId):
            return .requestParameters(parameters:["storeAndGoodsId":storeAndGoodsId,"storeId":storeId],encoding: URLEncoding.default)
        case let .addPromotiongoods(storeAndGoodsId, storeId, promotionStartTime, promotionEndTime, promotionMsg, promotionStock):
            return .requestParameters(parameters:["storeAndGoodsId":storeAndGoodsId,"storeId":storeId,"promotionStartTime":promotionStartTime,"promotionEndTime":promotionEndTime,"promotionMsg":promotionMsg,"promotionStock":promotionStock], encoding: URLEncoding.default)
        case let .removePromotiongoods(storeAndGoodsId, storeId):
            return .requestParameters(parameters:["storeAndGoodsId":storeAndGoodsId,"storeId":storeId], encoding: URLEncoding.default)
        case let .queryPromotiongoodsPaginateStore(storeId, pageNumber, pageSize, salesCountFlag, priceFlag):
            return .requestParameters(parameters:["storeId":storeId,"pageNumber":pageNumber,"pageSize":pageSize,"salesCountFlag":salesCountFlag ?? "","priceFlag":priceFlag ?? ""], encoding: URLEncoding.default)
        }
        
    }
    
    public var headers: [String : String]? {
        switch self {
        case .start(_):
            return ["Content-type":"multipart/form-data"]
        default:return nil
        }
    }
    
    
}
