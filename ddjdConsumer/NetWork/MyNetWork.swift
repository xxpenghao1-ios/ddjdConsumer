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
    ///获取会员剩余余额
    case queryMemberBalanceMoney(parameters:[String:Any])
    ///会员充值  rechargeMoney会员充值的金额；充值金额限制为 最小1元，最大1万元； 正整数 paymentInstrument 会员充值使用的支付工具； 1微信；2支付宝
    case memberRechargeBalance(parameters:[String:Any])
    ///会员余额记录
    case queryMemberBalanceRecord(parameters:[String:Any])
    ///修改支付密码
    case updateMemberBalancePayPassword(parameters:[String:Any])
    ///查询会员绑定的充值支付工具 memberId 查询会员绑定的充值支付工具 ; 如果没有绑定，就可以使用全部的支付方式充值； 如果有绑定，就只能使用绑定的支付工具充值；如：炮神今天第一次充值，页面提示可以用支付宝和微信，他使用了微信充值了500元， 那么，以后他每次充值都将只能使用微信进行充值，将看不到支付宝充值的按钮；
    case queryMemberbindrechargepaymenttools(memberId:Int)
    ///查询可提现余额 同时返回系统设置最小和最大提现范围 ； — 众筹人不能提现
    case queryMemberWithdrawalsBalance(parameters:[String:Any])
    ///绑定会员提现信息 payType 1 微信 ； 2 支付宝  code 第三方支付工具，授权登录时的code；支付宝的叫‘auth_code’
    case updateBindMemberWithdrawalsInfo(parameters:[String:Any])
    ///开始提现 withdrawalsMoney 提现金额 serviceCharge 手续费
    case memberStartWithdrawalsBalance(parameters:[String:Any])
    ///会员当前是众筹人，查询基本信息
    case queryPartnerInfoByMemberId(parameters:[String:Any])
    ///ios app 是否正在审核中。 默认1不在审核中； 2 正在审核中
    case queryIosExamineStatu()

}
extension MyApi:TargetType{
    
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
        case .queryMemberBalanceMoney(_):
            return "/front/memberBalance/queryMemberBalanceMoney"
        case .memberRechargeBalance(_):
            return "/front/memberBalance/memberRechargeBalance"
        case .queryMemberBalanceRecord(_):
            return "/front/memberBalance/queryMemberBalanceRecord"
        case .updateMemberBalancePayPassword(_):
            return "/front/memberBalance/updateMemberBalancePayPassword"
        case .queryMemberbindrechargepaymenttools(_):
            return "/front/memberBalance/queryMemberbindrechargepaymenttools"
        case .queryMemberWithdrawalsBalance(_):
            return "/front/memberWithdrawals/queryMemberWithdrawalsBalance"
        case .updateBindMemberWithdrawalsInfo(_):
            return "/front/memberWithdrawals/updateBindMemberWithdrawalsInfo"
        case .memberStartWithdrawalsBalance(_):
            return "/front/memberWithdrawals/memberStartWithdrawalsBalance"
        case .queryPartnerInfoByMemberId(_):
            return "/front/partner/queryPartnerInfoByMemberId"
        case .queryIosExamineStatu():
            return "/front/queryCommInfo/queryIosExamineStatu"
            
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getAllShippaddress(_),.queryRegion(_),.queryOrderPaginate(_,_,_,_),.queryOrderById(_),.queryOrderNum(_),.getMember(_),.queryMemberBalanceMoney(_),.queryMemberBalanceRecord(_),.queryMemberbindrechargepaymenttools(_),.queryMemberWithdrawalsBalance(_),.queryPartnerInfoByMemberId(_),.queryIosExamineStatu():
            return .get
        case .saveShippAddress(_,_,_,_,_,_,_,_,_),.delShippaddress(_,_),.pendingPaymentSubmit(_,_,_,_),.setDefault(_,_),.updateHeadportraiturl(_,_,_),.bindStore(_,_),.unBindStore(_),.updatePwd(_,_,_),.saveQuestionsorsuggestions(_,_,_,_),.memberRechargeBalance(_),.updateMemberBalancePayPassword(_),.updateBindMemberWithdrawalsInfo(_),.memberStartWithdrawalsBalance(_):
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

        case let .queryMemberBalanceMoney(parameters):
            return .requestParameters(parameters:parameters, encoding: URLEncoding.default)

        case let .memberRechargeBalance(parameters):
            return .requestParameters(parameters:parameters, encoding: URLEncoding.default)

        case let .queryMemberBalanceRecord(parameters):
            return .requestParameters(parameters:parameters, encoding: URLEncoding.default)
        case let .updateMemberBalancePayPassword(parameters):
            return .requestParameters(parameters:parameters, encoding: URLEncoding.default)
        case let .queryMemberbindrechargepaymenttools(memberId):
            return .requestParameters(parameters:["memberId":memberId], encoding: URLEncoding.default)
        case let .queryMemberWithdrawalsBalance(parameters):
            return .requestParameters(parameters:parameters, encoding: URLEncoding.default)
        case let .updateBindMemberWithdrawalsInfo(parameters):
            return .requestParameters(parameters:parameters, encoding: URLEncoding.default)
        case let .memberStartWithdrawalsBalance(parameters):
            return .requestParameters(parameters:parameters, encoding: URLEncoding.default)
        case let .queryPartnerInfoByMemberId(parameters):
            return .requestParameters(parameters:parameters, encoding: URLEncoding.default)
        case .queryIosExamineStatu():
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    
}
