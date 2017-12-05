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
    case storeUploadGoodsInfo(goodsCode:String,storeId:Int,goodsName:String,goodsUnit:String,goodsLift:Int,goodUcode:String,fCategoryId:Int,sCategoryId:Int,tCategoryId:Int,goodsPic:String,goodsPrice:String,goodsFlag:Int,stock:Int,remark:String,weight:Int,brand:String,goodsMixed:String)
    //图片上传
    case start(filePath:String,pathName:String)
    
    
}
extension StoreGoodApi:TargetType{
    public var baseURL: URL {
        return URL.init(string:url)!
    }
    
    public var path: String {
        switch self {
        case .storeUploadGoodsInfo(_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_):
            return "/front/storeUploadGoods/storeUploadGoodsInfo"
        case .start(_,_):
            return "/upload/start"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .storeUploadGoodsInfo(_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_),.start(_,_):
            return .post
        }
    }
    
    public var sampleData: Data {
        return "".data(using:.utf8)!
    }
    public var task: Task {
        switch self {
        case let .storeUploadGoodsInfo(goodsCode, storeId, goodsName, goodsUnit, goodsLift, goodUcode, fCategoryId, sCategoryId, tCategoryId, goodsPic, goodsPrice, goodsFlag, stock, remark, weight,brand, goodsMixed):
            return .requestParameters(parameters:[:], encoding:URLEncoding.default)
        case let .start(filePath,pathName):
            let imgData = MultipartFormData(provider: MultipartFormData.FormDataProvider.file(Foundation.URL(fileURLWithPath:filePath)),name:"file")
            let urlParameters = ["path":pathName]
            return .uploadCompositeMultipart([imgData],urlParameters: urlParameters)
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
