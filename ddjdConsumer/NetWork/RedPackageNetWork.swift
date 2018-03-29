//
//  RedPackageNetWork.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/26.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import Moya
///店铺授权用户相关功能
public enum RedPackageApi{
    ///充值红包 — 店铺永远只会发出去一个红包，所以永远是增加红包金额和个数
    case addRedPacket_store(storeId:Int,payType:Int,redPackCount:Int,redPackMoney:Int)
    ///店铺查询红包领取记录
    case queryStoreRedpackReceivereRecord_storeId(storeId:Int,pageNumber:Int,pageSize:Int)
    ///根据店铺ID查询店铺红包信息
    case queryStoreRedPacket(storeId:Int)

    ///查询店铺红包充值记录
    case queryStoreRedpackrechargerecord(storeId:Int,pageNumber:Int,pageSize:Int)

    ///会员查询红包领取记录
    case queryStoreRedpackReceivereRecord_memberId(memberId:Int,pageNumber:Int,pageSize:Int)
    ///领一个红包
    case getOneRedPacket(parameters:[String:Any])
}
extension RedPackageApi:TargetType{
    public var path: String {
        switch self {
        case .addRedPacket_store(_,_,_,_):
            return "/front/redPacket/addRedPacket_store"
        case .queryStoreRedpackReceivereRecord_storeId(_,_,_):
            return "/front/redPacket/queryStoreRedpackReceivereRecord_storeId"
        case .queryStoreRedPacket(_):
            return "/front/redPacket/queryStoreRedPacket"
        case .queryStoreRedpackrechargerecord(_,_,_):
            return "/front/redPacket/queryStoreRedpackrechargerecord"
        case .queryStoreRedpackReceivereRecord_memberId(_,_,_):
            return "/front/redPacket/queryStoreRedpackReceivereRecord_memberId"
        case .getOneRedPacket(_):
            return "/front/redPacket/getOneRedPacket"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .addRedPacket_store(_,_,_,_),.getOneRedPacket(_):
            return .post
        case .queryStoreRedpackReceivereRecord_storeId(_,_,_),.queryStoreRedPacket(_),.queryStoreRedpackrechargerecord(_,_,_),.queryStoreRedpackReceivereRecord_memberId(_,_,_):
            return .get
        }
    }

    public var sampleData: Data {
        return "".data(using:.utf8)!
    }

    public var task: Task {
        switch self {
        case let .addRedPacket_store(storeId, payType, redPackCount, redPackMoney):
            return .requestParameters(parameters:["storeId":storeId,"payType":payType,"redPackCount":redPackCount,"redPackMoney":redPackMoney], encoding: URLEncoding.default)
        case let .queryStoreRedpackReceivereRecord_storeId(storeId, pageNumber, pageSize):
            return .requestParameters(parameters:["storeId":storeId,"pageNumber":pageNumber,"pageSize":pageSize], encoding: URLEncoding.default)
        case let .queryStoreRedPacket(storeId):
            return .requestParameters(parameters:["storeId":storeId], encoding: URLEncoding.default)
        case let .queryStoreRedpackrechargerecord(storeId, pageNumber, pageSize):
            return .requestParameters(parameters:["storeId":storeId,"pageNumber":pageNumber,"pageSize":pageSize], encoding: URLEncoding.default)
        case let .queryStoreRedpackReceivereRecord_memberId(memberId, pageNumber, pageSize):
            return .requestParameters(parameters:["memberId":memberId,"pageNumber":pageNumber,"pageSize":pageSize], encoding: URLEncoding.default)
        case let .getOneRedPacket(parameters):
            return .requestParameters(parameters:parameters, encoding: URLEncoding.default)
        }
    }

    public var headers: [String : String]? {
        return nil
    }


}

