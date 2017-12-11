//
//  MyNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/8.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya
//个人中心api
public enum MyApi{
    //获取所有地址信息
    case getAllShippaddress(memberId:Int)
    //修改 新增收货地址
    case saveShippAddress(lat:String,lon:String,address:String,detailAddress:String,shippName:String,phoneNumber:String,memberId:Int,shippAddressId:Int?,defaultFlag:Int)
    //获取省市区
    case queryRegion(pid:Int)
    //删除收货地址
    case delShippaddress(memberId:Int,shippAddressId:Int)
    //设置默认地址
    case setDefault(memberId:Int,shippAddressId:Int)
    // orderStatus 订单状态 ‘1. 待付款 2-待发货，3 已发货，4-已经完成
    case queryOrderPaginate(memberId:Int,orderStatus:Int,pageSize:Int,pageNumber:Int)
    // 查询订单详情
    case queryOrderById(orderId:Int)
    //查询待付和待收订单数量
    case queryOrderNum(memberId:Int)
    //待支付的订单支付
    case pendingPaymentSubmit(orderId:Int,memberId:Int,platform:Int,payType:Int)
    //查询会员信息
    case getMember(memberId:Int)
    //修改头像和名称
    case updateHeadportraiturl(memberId:Int,headportraiturl:String?,nickName:String?)
    //绑定店铺
    case bindStore(memberId:Int,bindstoreId:Int)
    //解绑店铺
    case unBindStore(memberId:Int)
    //修改密码
    case updatePwd(memberId:Int,oldpassword:String,password:String)
    //问题或意见接口
    case saveQuestionsorsuggestions(memberId:Int,questionsOrSuggestionsType:Int,questionsOrSuggestionsText:String,questionsOrSuggestionsPic:String)

}
extension MyApi:TargetType{
    public var baseURL: URL {
        return URL(string:url)!
    }
    
    public var path: String {
        switch self {
        case .getAllShippaddress(_):
            return "/front/shopAddress/getAllShippaddress"
        case .saveShippAddress(_,_,_,_,_,_,_,_,_):
            return "/front/shopAddress/saveShippAddress"
        case .queryRegion(_):
            return "/back/region/queryRegion"
        case .delShippaddress(_,_):
            return "/front/shopAddress/delShippaddress"
        case .queryOrderPaginate(_,_,_,_):
            return "/front/order/queryOrderPaginate"
        case .queryOrderById(_):
            return "/front/order/queryOrderById"
        case .queryOrderNum(_):
            return "/front/order/queryOrderNum"
        case .pendingPaymentSubmit(_,_,_,_):
            return "/front/order/pendingPaymentSubmit"
        case .setDefault(_,_):
            return "/front/shopAddress/setDefault"
        case .getMember(_):
            return "/front/member/getMember"
        case .updateHeadportraiturl(_,_,_):
            return "/front/member/updateHeadportraiturl"
        case .bindStore(_,_):
            return "/front/member/bindStore"
        case .unBindStore(_):
            return "/front/member/unBindStore"
        case .updatePwd(_,_,_):
            return "/front/member/updatePwd"
        case .saveQuestionsorsuggestions(_,_,_,_):
            return "/front/questionsOrSuggestions/saveQuestionsorsuggestions"
            
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getAllShippaddress(_),.queryRegion(_),.queryOrderPaginate(_,_,_,_),.queryOrderById(_),.queryOrderNum(_),.getMember(_):
            return .get
        case .saveShippAddress(_,_,_,_,_,_,_,_,_),.delShippaddress(_,_),.pendingPaymentSubmit(_,_,_,_),.setDefault(_,_),.updateHeadportraiturl(_,_,_),.bindStore(_,_),.unBindStore(_),.updatePwd(_,_,_),.saveQuestionsorsuggestions(_,_,_,_):
            return .post
        }
    }
    public var sampleData:Data{
        return "".data(using:.utf8)!
    }
    
    public var task: Task {
        switch self {
        case let .getAllShippaddress(memberId):
            return .requestParameters(parameters:["memberId":memberId], encoding: URLEncoding.default)
        case let .saveShippAddress(lat,lon,address,detailAddress, shippName, phoneNumber, memberId, shippAddressId,defaultFlag):
            if shippAddressId == nil{
                return .requestParameters(parameters:["lat":lat,"lon":lon,"address":address,"detailAddress":detailAddress,"shippName":shippName,"phoneNumber":phoneNumber,"memberId":memberId,"defaultFlag":defaultFlag], encoding: URLEncoding.default)
            }else{
                return .requestParameters(parameters:["lat":lat,"lon":lon,"address":address,"detailAddress":detailAddress,"shippName":shippName,"phoneNumber":phoneNumber,"memberId":memberId,"shippAddressId":shippAddressId!,"defaultFlag":defaultFlag], encoding: URLEncoding.default)
            }
        case let .queryRegion(pid):
            return .requestParameters(parameters:["pid":pid], encoding: URLEncoding.default)
        case let .delShippaddress(memberId, shippAddressId):
            return .requestParameters(parameters:["memberId":memberId,"shippAddressId":shippAddressId], encoding: URLEncoding.default)
        case let .queryOrderPaginate(memberId, orderStatus, pageSize, pageNumber):
            return .requestParameters(parameters:["memberId":memberId,"orderStatus":orderStatus,"pageSize":pageSize,"pageNumber":pageNumber], encoding: URLEncoding.default)
        case let .queryOrderById(orderId):
            return .requestParameters(parameters:["orderId":orderId], encoding: URLEncoding.default)
        case let .queryOrderNum(memberId):
            return .requestParameters(parameters:["memberId":memberId], encoding: URLEncoding.default)
        case let .pendingPaymentSubmit(orderId, memberId, platform, payType):
            return .requestParameters(parameters:["orderId":orderId,"memberId":memberId,"platform":platform,"payType":payType], encoding:URLEncoding.default)
        case let .setDefault(memberId, shippAddressId):
            return .requestParameters(parameters:["memberId":memberId,"shippAddressId":shippAddressId], encoding: URLEncoding.default)
        case let .getMember(memberId):
            return .requestParameters(parameters:["memberId":memberId], encoding: URLEncoding.default)
        case let .updateHeadportraiturl(memberId, headportraiturl, nickName):
            if headportraiturl != nil{
                return .requestParameters(parameters:["memberId":memberId,"headportraiturl":headportraiturl!], encoding: URLEncoding.default)
            }else{
                return .requestParameters(parameters:["memberId":memberId,"nickName":nickName!], encoding: URLEncoding.default)
            }
        case let .bindStore(memberId, bindstoreId):
            return .requestParameters(parameters:["memberId":memberId,"bindstoreId":bindstoreId], encoding: URLEncoding.default)
        case let .unBindStore(memberId):
            return .requestParameters(parameters:["memberId":memberId], encoding: URLEncoding.default)
        case let .updatePwd(memberId, oldpassword, password):
            return .requestParameters(parameters:["memberId":memberId,"oldpassword":oldpassword,"password":password], encoding: URLEncoding.default)
        case let .saveQuestionsorsuggestions(memberId, questionsOrSuggestionsType, questionsOrSuggestionsText, questionsOrSuggestionsPic):
            return .requestParameters(parameters:["memberId":memberId,"questionsOrSuggestionsType":questionsOrSuggestionsType,"questionsOrSuggestionsText":questionsOrSuggestionsText,"questionsOrSuggestionsPic":questionsOrSuggestionsPic], encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    
}