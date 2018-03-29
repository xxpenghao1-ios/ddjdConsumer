//
//  StoreAuthorizationMemberRelatedNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/22.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import Moya
///店铺授权用户相关功能
public enum StoreAuthorizationMemberRelatedApi{
    ///查询店铺已经授权的会员
    case queryAllStoreAuthMmeber(storeId:Int)
    ///删除会员授权功能
    case deleteMemberAuth(memberId:Int)
    ///查询店铺所有可以授权的功能
    case queryAllAuthList()
    ///验证账号 并为账号授权
    case validateAccAndInertAuth(storeId:Int,acc:String,authStr:String)
    ///查询为某会员授权的所有功能
    case queryMemberAuthList(memberId:Int)
}
extension StoreAuthorizationMemberRelatedApi:TargetType{
    public var path: String {
        switch self {
        case .queryAllStoreAuthMmeber(_):
            return "/front/auth/queryAllStoreAuthMmeber"
        case .deleteMemberAuth(_):
            return "/front/auth/deleteMemberAuth"
        case .queryAllAuthList():
            return "/front/auth/queryAllAuthList"
        case .validateAccAndInertAuth(_,_,_):
            return "/front/auth/validateAccAndInertAuth"
        case .queryMemberAuthList(_):
            return "/front/auth/queryMemberAuthList"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .queryAllStoreAuthMmeber(_),.deleteMemberAuth(_),.queryAllAuthList(),.validateAccAndInertAuth(_,_,_),.queryMemberAuthList(_):
            return .get
        }
    }

    public var sampleData: Data {
        return "".data(using:.utf8)!
    }

    public var task: Task {
        switch self {
        case let .queryAllStoreAuthMmeber(storeId):
            return .requestParameters(parameters:["storeId":storeId], encoding: URLEncoding.default)
        case let .deleteMemberAuth(memberId):
            return .requestParameters(parameters:["memberId":memberId], encoding: URLEncoding.default)
        case .queryAllAuthList():
            return .requestPlain
        case let .validateAccAndInertAuth(storeId, acc, authStr):
            return .requestParameters(parameters:["storeId":storeId,"acc":acc,"authStr":authStr], encoding: URLEncoding.default)
        case let .queryMemberAuthList(memberId):
            return .requestParameters(parameters:["memberId":memberId], encoding: URLEncoding.default)
        }
    }

    public var headers: [String : String]? {
        return nil
    }


}
