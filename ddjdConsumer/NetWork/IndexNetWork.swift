//
//  IndexNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/8.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya

/// 首页数据请求
public enum IndexApi{
    //首页推荐商品
    case indexGoods(bindstoreId:Int,pageSize:Int,pageNumber:Int)
    //查询首页广告
    case getAllAdvertising()
    ///成为VIP或众筹人资料
    case ddjdvip(storeId:Int)
}

extension IndexApi:TargetType{
    public var headers: [String : String]? {
        return nil
    }
    
    ///请求URL
    public var baseURL:URL{
        return URL(string:url)!
    }
    ///URL详细路径
    public var path:String{
        switch self {
        case .indexGoods(_,_,_):
            return "/front/goods/indexGoods"
        case .getAllAdvertising():
            return "/front/advertising/getAllAdvertising"
        case .ddjdvip(_):
            return "/front/ddjdvip"
        }
    }
    ///请求方式
    public var method:Moya.Method{
        switch  self {
        case .getAllAdvertising(),.indexGoods(_,_,_),.ddjdvip(_):
            return .get
//        case .indexGoods(_,_,_):
//            return .post
        }
    }
    //单元测试用
    public var sampleData:Data{
        return "".data(using:.utf8)!
    }
    //任务
    public var task: Task {
        switch self {
        case let .indexGoods(bindstoreId,pageSize,pageNumber):
            return .requestParameters(parameters:["bindstoreId":bindstoreId,"pageSize":pageSize,"pageNumber":pageNumber],encoding: URLEncoding.default)
        case .getAllAdvertising():
            return .requestPlain
        case let .ddjdvip(storeId):
            return .requestParameters(parameters:["storeId":storeId], encoding: URLEncoding.default)
        }
    }
}
