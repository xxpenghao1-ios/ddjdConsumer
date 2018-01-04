//
//  ShoppingCartNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/8.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Moya
//购物车
public enum CarApi{
    ///查询购物车商品
    case getAllCarGood(memberId:Int,pageSize:Int,pageNumber:Int)
    ///加入购物车
    case addCar(memberId:Int,storeAndGoodsId:Int,goodsCount:Int)
    ///清除购物车所有商品
    case clearCar(memberId:Int)
    ///删除购物车某个商品
    case removeCar(shoppingCarId:Int,memberId:Int)
    ///修改购物车商品数量接口
    case changeCarNumForGoods(shoppingCarId:Int,goodsCount:Int)
    ///查询购物车商品的数量 queryStatu1，查询购物车商品的总数量； 2 ，查询购物车商品的种类数量； (比如：A用户购物车加入了10包辣条，传1查询结果为10，传2查询结果为1)
    case queryShoppingCarGoodsSumCount(memberId:Int,queryStatu:Int)
    ///选中或取消某个商品
    case chooseCarGoods(shoppingCarId:Int,checkOrCance:Int)
    ///查询商品总金额
    case queryCarSumMoney(memberId:Int)
    ///购物车全选或全不选  1. 全选，2 全不选
    case checkOrCanceAllShoppingCarGoods(memberId:Int,checkOrCance:Int)
    // platform1.安卓 2. 苹果 3.其他  payType支付方式 1. 微信 2.支付宝 4余额支付
    case saveOrder(memberId:Int,shipaddressId:Int,platform:Int,payType:Int,moblieSumPrice:String,payMessage:String)
    //待支付的订单支付
    case pendingPaymentSubmit(orderId:Int,memberId:Int,platform:Int,payType:Int,memberbalancePaySumPrice:String)
    //确认收货
    case updateMemberOrderInfoStatusThe4(orderId:Int,memberId:Int)
    //取消订单
    case removeOrder(orderId:Int,memberId:Int)
}
extension CarApi:TargetType{
    public var baseURL: URL {
        return URL(string:url)!
    }
    public var path: String {
        switch self {
        case .getAllCarGood(_,_,_):
            return "/front/shopCar/getGoodsWithShoppingCar"
        case .addCar(_,_,_):
            return "/front/shopCar/addCar"
        case .clearCar(_):
            return "/front/shopCar/clearCar"
        case .removeCar(_,_):
            return "/front/shopCar/removeCar"
        case .changeCarNumForGoods(_,_):
            return "/front/shopCar/changeCarNumForGoods"
        case .queryShoppingCarGoodsSumCount(_,_):
            return "/front/shopCar/queryShoppingCarGoodsSumCount"
        case .chooseCarGoods(_,_):
            return "/front/shopCar/chooseCarGoods"
        case .queryCarSumMoney(_):
            return "/front/shopCar/queryCarSumMoney"
        case .checkOrCanceAllShoppingCarGoods(_,_):
            return "/front/shopCar/checkOrCanceAllShoppingCarGoods"
        case .saveOrder(_,_,_,_,_,_):
            return "/front/order/saveOrder"
        case .pendingPaymentSubmit(_,_,_,_,_):
            return "/front/order/pendingPaymentSubmit"
        case .updateMemberOrderInfoStatusThe4(_,_):
            return "/front/order/updateMemberOrderInfoStatusThe4"
        case .removeOrder(_,_):
            return "front/order/removeOrder"
        }
    }
    
    public var method:Moya.Method {
        switch self {
        case .getAllCarGood(_,_,_),.addCar(_,_,_),.clearCar(_),.removeCar(_,_),.changeCarNumForGoods(_,_),.chooseCarGoods(_,_),.queryCarSumMoney(_),.checkOrCanceAllShoppingCarGoods(_,_),.saveOrder(_,_,_,_,_,_),.pendingPaymentSubmit(_,_,_,_,_),.updateMemberOrderInfoStatusThe4(_,_),.removeOrder(_,_):
            return .post
        case .queryShoppingCarGoodsSumCount(_,_):
            return .get
        }
    }
    
    public var sampleData:Data{
        return "".data(using:.utf8)!
    }
    
    public var task: Task {
        switch self {
        case let .getAllCarGood(memberId, pageSize, pageNumber):
            return .requestParameters(parameters:["memberId":memberId,"pageSize":pageSize,"pageNumber":pageNumber], encoding: URLEncoding.default)
        case let .addCar(memberId, storeAndGoodsId,goodsCount):
            return .requestParameters(parameters:["memberId":memberId,"storeAndGoodsId":storeAndGoodsId,"goodsCount":goodsCount], encoding: URLEncoding.default)
        case let .clearCar(memberId):
            return .requestParameters(parameters:["memberId":memberId], encoding: URLEncoding.default)
        case let .removeCar(shoppingCarId, memberId):
            return .requestParameters(parameters:["shoppingCarId":shoppingCarId,"memberId":memberId], encoding: URLEncoding.default)
        case let .changeCarNumForGoods(shoppingCarId, goodsCount):
            return .requestParameters(parameters:["shoppingCarId":shoppingCarId,"goodsCount":goodsCount], encoding: URLEncoding.default)
        case let .queryShoppingCarGoodsSumCount(memberId, queryStatu):
            return .requestParameters(parameters:["memberId":memberId,"queryStatu":queryStatu], encoding: URLEncoding.default)
        case let .chooseCarGoods(shoppingCarId, checkOrCance):
            return .requestParameters(parameters:["shoppingCarId":shoppingCarId,"checkOrCance":checkOrCance], encoding: URLEncoding.default)
        case let .queryCarSumMoney(memberId):
            return .requestParameters(parameters:["memberId":memberId], encoding: URLEncoding.default)
        case let .checkOrCanceAllShoppingCarGoods(memberId, checkOrCance):
            return .requestParameters(parameters:["memberId":memberId,"checkOrCance":checkOrCance],encoding: URLEncoding.default)
        case let .saveOrder(memberId, shipaddressId, platform, payType, moblieSumPrice,payMessage):
            return .requestParameters(parameters:["memberId":memberId,"shipaddressId":shipaddressId,"platform":platform,"payType":payType,"moblieSumPrice":moblieSumPrice,"payMessage":payMessage], encoding: URLEncoding.default)
        case let .pendingPaymentSubmit(orderId, memberId, platform, payType,memberbalancePaySumPrice):
            return .requestParameters(parameters:["orderId":orderId,"memberId":memberId,"platform":platform,"payType":payType,"memberbalancePaySumPrice":memberbalancePaySumPrice], encoding:URLEncoding.default)
        case let .updateMemberOrderInfoStatusThe4(orderId, memberId):
            return .requestParameters(parameters:["orderId":orderId,"memberId":memberId], encoding: URLEncoding.default)
        case let .removeOrder(orderId, memberId):
            return .requestParameters(parameters:["orderId":orderId,"memberId":memberId], encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
}

