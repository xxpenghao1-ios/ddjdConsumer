//
//  LoginWithRegistrNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/11.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya
//登录与注册api
public enum LoginWithRegistrApi{
    //获取验证码 flag 1 注册，2改密码 传其他，代表其他业务发短信
    case duanxinValidate(account:String,flag:Int)
    //注册
    case reg(account:String,password:String)
    //登录
    case memberLogin(account:String,password:String,deviceToken:String,deviceName:String)
    //忘记密码
    case fingPwd(account:String,password:String)
    ///会员最后一次不同设备登录记录
    case queryMemberLastLoginRecord(memberId:Int)
    
}
extension LoginWithRegistrApi:TargetType{
    public var baseURL: URL {
        return URL(string:url)!
    }
    public var path: String {
        switch self {
        case .duanxinValidate(_,_):
            return "/front/member/duanxinValidate"
        case .reg(_,_):
            return "/front/member/reg"
        case .memberLogin(_,_,_,_):
            return "/front/login/memberLogin"
        case .fingPwd(_,_):
            return "/front/member/fingPwd"
        case .queryMemberLastLoginRecord(_):
            return "/front/login/queryMemberLastLoginRecord"
        }
    }
    
    public var method:Moya.Method {
        switch self {
        case .duanxinValidate(_,_),.reg(_,_),.memberLogin(_,_,_,_),.fingPwd(_,_):
            return .post
        case .queryMemberLastLoginRecord(_):
            return .get
        }
    }
    
    public var sampleData:Data{
        return "".data(using:.utf8)!
    }
    
    public var task: Task {
        switch self {
        case let .duanxinValidate(account, flag):
            return .requestParameters(parameters:["account":account,"flag":flag], encoding: URLEncoding.default)
        case let .reg(account,password):
            return .requestParameters(parameters:["account":account,"password":password], encoding: URLEncoding.default)
        case let .memberLogin(account, password,deviceToken,deviceName):
            return .requestParameters(parameters:["account":account,"password":password,"deviceToken":deviceToken,"deviceName":deviceName], encoding: URLEncoding.default)
        case let .fingPwd(account, password):
            return .requestParameters(parameters:["account":account,"password":password], encoding: URLEncoding.default)
        case let .queryMemberLastLoginRecord(memberId):
            return .requestParameters(parameters:["memberId":memberId], encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    
}
