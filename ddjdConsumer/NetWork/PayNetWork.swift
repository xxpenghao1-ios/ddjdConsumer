//
//  PayNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/10.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya
//微信请求
public enum PayApi{
    //通过code获取access_token
    case accessToken(code:String)
    
    //填写通过access_token获取到的refresh_token参数(刷新refresh_token)
    case refreshToken(refresh_token:String)
    
    //检验授权凭证（access_token）是否有效
    case isAccessToken(access_token:String,openid:String)
    
    //获取用户信息
    case getUserinfo(access_token:String,openid:String)
}
extension PayApi:TargetType{
    public var baseURL: URL {
        return URL(string:"https://api.weixin.qq.com")!
    }
    
    public var path: String {
        switch self {
        case .accessToken(_):
            return "/front/sns/oauth2/access_token"
        case .refreshToken(_):
            return "/front/sns/oauth2/refresh_token"
        case .isAccessToken(_,_):
            return "/front/sns/auth"
        case .getUserinfo(_,_):
            return "/front/sns/userinfo"
        }
    }
    
    public var method:Moya.Method {
        return .get
    }
    public var sampleData:Data{
        return "".data(using:.utf8)!
    }
    
    public var task: Task {
        switch self {
        case let .accessToken(code):
            return .requestParameters(parameters:["appid":WX_APPID,"secret":SECRET,"code":code,"grant_type":"authorization_code"], encoding:URLEncoding.default)
        case let .refreshToken(refresh_token):
            return .requestParameters(parameters:["appid":WX_APPID,"grant_type":"refresh_token","refresh_token":refresh_token], encoding: URLEncoding.default)
        case let .isAccessToken(access_token,openid):
            return .requestParameters(parameters:["access_token":access_token,"openid":openid], encoding: URLEncoding.default)
        case let .getUserinfo(access_token, openid):
            return .requestParameters(parameters:["access_token":access_token,"openid":openid],encoding: URLEncoding.default)
    
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    
}

