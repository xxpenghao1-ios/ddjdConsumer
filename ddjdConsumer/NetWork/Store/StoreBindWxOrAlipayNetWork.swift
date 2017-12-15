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
    ///店铺绑定支付宝 绑定前先验证手机号
    case updateStoreBindAli(storeId:Int,auth_code:String)
    ///获取支付宝授权参数 调起支付宝授权所需的请求参数
    case query_ali_AuthParams(storeId:Int)
    ///店铺绑定微信
    case updateStoreBindWx(storeId:Int,code:String)
}
extension StoreBindWxOrAlipayApi:TargetType{
    public var baseURL: URL {
        return URL.init(string:url)!
    }
    
    public var path: String {
        switch self {
        case .queryStoreBindWxOrAliStatu(_):
            return "/front/wxOrAli/queryStoreBindWxOrAliStatu"
        case .updateStoreBindAli(_,_):
            return "/front/wxOrAli/updateStoreBindAli"
        case .query_ali_AuthParams(_):
            return "/front/queryCommInfo/query_ali_AuthParams"
        case .updateStoreBindWx(_,_):
            return "/front/wxOrAli/updateStoreBindWx"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .queryStoreBindWxOrAliStatu(_),.query_ali_AuthParams(_):
            return .get
        case .updateStoreBindAli(_,_),.updateStoreBindWx(_,_):
            return .post
        }
    }
    
    public var sampleData: Data {
        return "".data(using:.utf8)!
    }
    public var task: Task {
        switch self {
        case let .queryStoreBindWxOrAliStatu(storeId):
            return .requestParameters(parameters:["storeId":storeId], encoding:URLEncoding.default)
        case let .updateStoreBindAli(storeId, auth_code):
            return .requestParameters(parameters:["storeId":storeId,"auth_code":auth_code], encoding: URLEncoding.default)
        case let .query_ali_AuthParams(storeId):
            return .requestParameters(parameters:["storeId":storeId], encoding: URLEncoding.default)
        case let .updateStoreBindWx(storeId, code):
            return .requestParameters(parameters:["storeId":storeId,"code":code], encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
}
