//
//  StoreBindWxOrAlipayNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/23.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya
///绑定微信或者支付宝
public enum StoreBindWxOrAlipayApi{
    //查询店铺是否绑定微信或者支付宝 ，并返回相应的基本信息
    case queryStoreBindWxOrAliStatu(storeId:Int)
}
extension StoreBindWxOrAlipayApi:TargetType{
    public var baseURL: URL {
        return URL.init(string:url)!
    }
    
    public var path: String {
        switch self {
        case .queryStoreBindWxOrAliStatu(_):
            return "front/wxOrAli/queryStoreBindWxOrAliStatu"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .queryStoreBindWxOrAliStatu(_):
            return .get
        }
    }
    
    public var sampleData: Data {
        return "".data(using:.utf8)!
    }
    public var task: Task {
        switch self {
        case let .queryStoreBindWxOrAliStatu(storeId):
            return .requestParameters(parameters:["storeId":storeId], encoding:URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
}
