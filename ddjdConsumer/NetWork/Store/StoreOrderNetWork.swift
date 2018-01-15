//
//  StoreOrderNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/12.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya
///店铺订单api
enum StoreOrderApi{
    ///查询订单信息
    case queryStoreOrderInfo(storeId:Int,orderStatus:Int,pageSize:Int,pageNumber:Int)
    ///店铺发货
    case updateStoreOrderInfoTheOrderStatus(storeId:Int,orderId:Int)
    ///查询店铺订单详情
    case queryStoreOrderInfoDetails(orderId:Int)
    ///订单统计 按月
    case queryStoreOrderCountForMonth(storeId:Int,date:String)
    
}
extension StoreOrderApi:TargetType{
    var baseURL: URL {
        return URL.init(string:url)!
    }
    var path: String {
        switch self {
        case .queryStoreOrderInfo(_,_,_,_):
            return "/front/storeAndOrderInfo/queryStoreOrderInfo"
        case .updateStoreOrderInfoTheOrderStatus(_,_):
            return "/front/storeAndOrderInfo/updateStoreOrderInfoTheOrderStatus"
        case .queryStoreOrderInfoDetails(_):
            return "/front/storeAndOrderInfo/queryStoreOrderInfoDetails"
        case .queryStoreOrderCountForMonth(_,_):
            return "/front/storeStatistics/queryStoreOrderCountForMonth"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .queryStoreOrderInfo(_,_,_,_),.queryStoreOrderInfoDetails(_),.queryStoreOrderCountForMonth(_,_):
            return .get
        case .updateStoreOrderInfoTheOrderStatus(_,_):
            return .post
        }
    }
    
    public var sampleData: Data {
        return "".data(using:.utf8)!
    }
    
    var task: Task {
        switch self {
        case let .queryStoreOrderInfo(storeId, orderStatus, pageSize, pageNumber):
            return .requestParameters(parameters:["storeId":storeId,"orderStatus":orderStatus,"pageSize":pageSize,"pageNumber":pageNumber], encoding: URLEncoding.default)
        case let .updateStoreOrderInfoTheOrderStatus(storeId, orderId):
            return .requestParameters(parameters:["storeId":storeId,"orderId":orderId], encoding: URLEncoding.default)
        case let .queryStoreOrderInfoDetails(orderId):
            return .requestParameters(parameters:["orderId":orderId], encoding: URLEncoding.default)
        case let .queryStoreOrderCountForMonth(storeId, date):
            return .requestParameters(parameters:["storeId":storeId,"date":date], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
