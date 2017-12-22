//
//  DDJDCSign.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/18.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///点单即到C端签名
class DDJDCSign:NSObject{
    static let shared = DDJDCSign()
    ///公钥
    private let publicKey=PUBLICKEY
    ///私钥
    private let ddjdc_privateKey=PRIVATEKEY
    ///凭证
    private var token=TOKEN
    ///字典 保存需要签名的字段
    private var dic=[String:Any]()
    private override init() {
        self.dic=["publicKey":publicKey,"token":token]
    }
    ///获取签名后的请求参数
    func getRequestParameters(timestamp:String,dicAny:[String:Any]?=nil)->[String:Any]{
        var signStr=""
        ///时间戳
        self.dic["timestamp"]=timestamp
        let keys=self.dic.keys
        //排序
        let sortedArray=keys.sorted { (t1,t2) -> Bool in
            //            orderedAscending（-1）：左操作数小于右操作数。
            //
            //            orderedSame（0）：两个操作数相等。
            //
            //            orderedDescending（1）：左操作数大于右操作数。
            ///按照字符串大小升序排序
            return t1.compare(t2).rawValue == -1 ? true : false
        }
        //拼接字符串
        for key in sortedArray{
            signStr+=key+"="+"\(self.dic[key]!)"+"&"
        }
        print("timestamp=\(timestamp)")
        print("token=\(token)")
        signStr+="ddjdc_privateKey=\(ddjdc_privateKey)"
        self.dic["sign"]=signStr.MD5().uppercased()
        if dicAny != nil{//如果数组有值 添加进字典
            for item in dicAny!{
                self.dic[item.key]=dicAny![item.key]
            }
        }
        return self.dic
    }
}
