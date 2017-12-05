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
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .queryStoreById(_),.queryStoreForLocation(_,_,_):
            return .get
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
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    
}
