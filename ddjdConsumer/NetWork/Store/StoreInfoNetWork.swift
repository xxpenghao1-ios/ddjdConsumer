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
    case queryStoreById(storeId:Int)
}
extension StoreInfoApi:TargetType{
    public var baseURL: URL {
        return URL.init(string:url)!
    }
    
    public var path: String {
        switch self {
        case .queryStoreById(_):
            return "/front/store/queryStoreById"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .queryStoreById(_):
            return .get
        }
    }
    
    public var sampleData: Data {
        return "".data(using:.utf8)!
    }
    
    public var task: Task {
        switch self {
        case let .queryStoreById(storeId):
            return .requestParameters(parameters:["storeId":storeId], encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    
}
