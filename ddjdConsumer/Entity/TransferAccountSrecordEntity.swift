//
//  TransferAccountSrecordEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/25.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
///转账记录表
class TransferAccountSrecordEntity:Mappable{
    var transferAccountsRecordId:Int?
    /// ‘1 ,wx 2 ali’,
    var transferAccountsRecordType:Int?
    ///‘转账成功的时间’,
    var transferAccountsRecordPayDate:String?
    ///‘转账的单据号； 原样接收wx和ali的单据号 ； 不是系统中的订单号’,
    var transferAccountsRecordSn:String?
    ///  ‘转账的金额； 以分为单位；ali的需要转换’,
    var transferAccountsRecordAmount:Int?
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        transferAccountsRecordId <- map["transferAccountsRecordId"]
        transferAccountsRecordType <- map["transferAccountsRecordType"]
        transferAccountsRecordPayDate <- map["transferAccountsRecordPayDate"]
        transferAccountsRecordSn <- map["transferAccountsRecordSn"]
        transferAccountsRecordAmount <- map["transferAccountsRecordAmount"]
    }
}
