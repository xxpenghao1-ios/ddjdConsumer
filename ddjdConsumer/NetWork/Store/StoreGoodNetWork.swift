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
    case storeUploadGoodsInfo(goodsCode:String,storeId:Int,goodsName:String,goodsUnit:String,goodsLift:Int,goodUcode:String,fCategoryId:Int,sCategoryId:Int,tCategoryId:Int,goodsPic:String,goodsPrice:String,goodsFlag:Int,stock:Int,remark:String?,weight:Int?,brand:String?,goodsMixed:String?,offlineStock:Int)
    //图片上传
    case start(filePath:String,pathName:String)
    //验证条码是否存在；如果存在，就返回公共商品库的商品信息，且同时返回这个店铺是否已经拥有了这个商品（根据exist判断），如果值为true表明已经拥有，且同时返回店铺的商品信息（querySag），如果值为false，表明没有拥有;如果不存在，直接返回 notExist
    case queryGoodsCodeIsExist(goodsCode:String,storeId:Int)
    //店铺查询自己的商品
    case queryStoreAndGoodsList(storeId:Int,goodsFlag:Int,pageNumber:Int,pageSize:Int,tCategoryId:Int?)
    
    
    
}
extension StoreGoodApi:TargetType{
    public var baseURL: URL {
        return URL.init(string:url)!
    }
    
    public var path: String {
        switch self {
        case .storeUploadGoodsInfo(_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_):
            return "/front/storeUploadGoods/storeUploadGoodsInfo"
        case .start(_,_):
            return "/upload/start"
        case .queryGoodsCodeIsExist(_,_):
            return "/front/storeUploadGoods/queryGoodsCodeIsExist"
        case .queryStoreAndGoodsList(_,_,_,_,_):
            return "/front/storeAndGoods/queryStoreAndGoodsList"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .storeUploadGoodsInfo(_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_),.start(_,_):
            return .post
        case .queryGoodsCodeIsExist(_,_),.queryStoreAndGoodsList(_,_,_,_,_):
            return .get
        }
    }
    
    public var sampleData: Data {
        return "".data(using:.utf8)!
    }
    public var task: Task {
        switch self {
        case let .storeUploadGoodsInfo(goodsCode, storeId, goodsName, goodsUnit, goodsLift, goodUcode, fCategoryId, sCategoryId, tCategoryId, goodsPic, goodsPrice, goodsFlag, stock, remark, weight,brand, goodsMixed,offlineStock):
            return .requestParameters(parameters:["goodsCode":goodsCode,"storeId":storeId,"goodsName":goodsName,"goodsUnit":goodsUnit,"goodsLift":goodsLift,"goodUcode":goodUcode,"fCategoryId":fCategoryId,"sCategoryId":sCategoryId,"tCategoryId":tCategoryId,"goodsPic":goodsPic,"goodsPrice":goodsPrice,"goodsFlag":goodsFlag,"stock":stock,"remark":remark ?? "","weight":weight ?? "","brand":brand ?? "","goodsMixed":goodsMixed ?? "","offlineStock":offlineStock], encoding:URLEncoding.default)
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
