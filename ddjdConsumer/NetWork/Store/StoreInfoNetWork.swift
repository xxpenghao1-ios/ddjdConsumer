//
//  StoreInfoNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/29.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya
///店铺信息
public enum StoreInfoApi{
    ///查询店铺信息
    case queryStoreById(bindstoreId:Int)
    ///查询消费者选中位置可配送到位的店铺传0
    case queryStoreForLocation(distributionScope:Int,lat:Double,lon:Double)
    ///查询年月日的总金额和店铺总金额
    case queryStoreTurnover(storeId:Int)
    ///查询店铺收入明细（转账明细）记录
    case queryStoreTransferaccountsrecord(storeId:Int,pageNumber:Int,pageSize:Int,queryStatu:Int)
    ///修改店铺信息
    case updateStoreInfo(storeId:Int,storeMsg:String?,tel:String?,distributionScope:Int?,lowestMoney:Int?,distributionStartTime:String?,distributionEndTime:String?)
}
extension StoreInfoApi:TargetType{
    public var baseURL: URL {
        return URL.init(string:url)!
    }
    
    public var path: String {
        switch self {
        case .queryStoreById(_):
            return "/front/store/queryStoreById"
        case .queryStoreForLocation(_,_,_):
            return "/front/location/queryStoreForLocation"
        case .queryStoreTurnover(_):
            return "/front/storeStatistics/queryStoreTurnover"
        case .queryStoreTransferaccountsrecord(_,_,_,_):
            return "/front/storeStatistics/queryStoreTransferaccountsrecord"
        case .updateStoreInfo(_,_,_,_,_,_,_):
            return "/front/storeInfo/updateStoreInfo"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .queryStoreById(_),.queryStoreForLocation(_,_,_),.queryStoreTurnover(_),.queryStoreTransferaccountsrecord(_,_,_,_):
            return .get
        case .updateStoreInfo(_,_,_,_,_,_,_):
            return .post
        }
    }
    
    public var sampleData: Data {
        return "".data(using:.utf8)!
    }
    
    public var task: Task {
        switch self {
        case let .queryStoreById(bindstoreId):
            return .requestParameters(parameters:["bindstoreId":bindstoreId], encoding: URLEncoding.default)
        case let .queryStoreForLocation(distributionScope,lat,lon):
            return .requestParameters(parameters:["distributionScope":distributionScope,"lat":lat,"lon":lon], encoding: URLEncoding.default)
        case let .queryStoreTurnover(storeId):
            return .requestParameters(parameters:["storeId":storeId], encoding: URLEncoding.default)
        case let .queryStoreTransferaccountsrecord(storeId, pageNumber, pageSize, queryStatu):
            return .requestParameters(parameters:["storeId":storeId,"pageNumber":pageNumber,"pageSize":pageSize,"queryStatu":queryStatu], encoding: URLEncoding.default)
        case let .updateStoreInfo(storeId, storeMsg, tel, distributionScope, lowestMoney, distributionStartTime, distributionEndTime):
            var parameters:[String:Any]=[:]
                parameters["storeId"]=storeId
            if storeMsg != nil{
                parameters["storeMsg"]=storeMsg!
            }
            if tel != nil{
                parameters["tel"]=tel!
            }
            if distributionScope != nil{
                parameters["distributionScope"]=distributionScope!
            }
            if lowestMoney != nil{
                parameters["lowestMoney"]=lowestMoney!
            }
            if distributionStartTime != nil{
                parameters["distributionStartTime"]=distributionStartTime!
            }
            if distributionEndTime != nil{
                parameters["distributionEndTime"]=distributionEndTime!
            }
            return .requestParameters(parameters:parameters, encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    
}
