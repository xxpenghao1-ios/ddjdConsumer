//
//  GoodsClassificationNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/8.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya

/// 商品分类数据请求
public enum GoodsClassifiationApi{
    //查询所有分类
    case queryGoodsCateGoryList()
}
extension GoodsClassifiationApi:TargetType{
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
        case .queryGoodsCateGoryList():
            return "/front/goodsCateGory/queryGoodsCateGoryList"
        }
    }
    ///请求方式
    public var method:Moya.Method{
        switch  self {
        case .queryGoodsCateGoryList():
            return .get
        }
    }
    //单元测试用
    public var sampleData:Data{
        return "".data(using:.utf8)!
    }
    //任务
    public var task: Task {
        switch self {
        case .queryGoodsCateGoryList():
            return .requestPlain
        }
    }
}
