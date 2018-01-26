//
//  MemberEntity.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/11.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import ObjectMapper
//会员
class MemberEntity:Mappable{
    var memberId:Int? //‘会员id’,
    var nickName:String? //‘昵称’,
    var account:String? //‘账号’,
    var password:String?//‘密码’,
    var realName:String? //‘真实姓名’,
    var regtime:String? //‘注册时间’,
    var activation:Int? //‘是否激活(1，激活，2未激活)’,
    var headportraiturl:String? //‘头像路径’,
    var bindstoreId:Int? //‘绑定购买东西时的店铺id’,
    var storeFlag:Int?  //‘是否是店铺的标识 1. 是店铺 2. 不是店铺’,
    var storeId:Int?  //‘storeFlag 为1 时，才处理这个字段，绑定店铺，也就是这个会员是店铺’,
    var token:String? //用户对外标识； 用户在登录成功后，返回的token字段； 此字段每次登录成功都会重新生成；长度在32位—40位；
    var payPw:String? //用户支付密码
    var vipStatu:Int? //是否为vip; 默认1不是；2是； ‘,
    var partnerStatu:Int? // ‘是否为店铺众筹人；默认1不是；2是’,
    init(){}
    required init?(map: Map) {
        mapping(map:map)
    }
    func mapping(map: Map) {
        memberId <- map["memberId"]
        nickName <- map["nickName"]
        account <- map["account"]
        password <- map["password"]
        realName <- map["realName"]
        regtime <- map["regtime"]
        activation <- map["activation"]
        headportraiturl <- map["headportraiturl"]
        bindstoreId <- map["bindstoreId"]
        storeFlag <- map["storeFlag"]
        storeId <- map["storeId"]
        token <- map["token"]
        payPw <- map["payPw"]
        vipStatu <- map["vipStatu"]
        partnerStatu <- map["partnerStatu"]
    }
    
}
