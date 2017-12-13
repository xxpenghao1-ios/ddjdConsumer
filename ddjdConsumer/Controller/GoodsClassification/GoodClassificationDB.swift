//
//  GoodClassificationDB.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/10.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import SQLite
import SwiftyJSON

///保存数据
class GoodClassificationDB:NSObject{
    static let shared = GoodClassificationDB()
    private var db:Connection!
    let table = Table("GoodClassification")
    let id=Expression<Int64>("id")
    let goodsCategoryId=Expression<Int64>("goodsCategoryId")
    let goodsCategoryName=Expression<String?>("goodsCategoryName")
    let goodsCategoryPid=Expression<Int64>("goodsCategoryPid")
    let goodsCategoryIco=Expression<String?>("goodsCategoryIco")
    private override init() {
        super.init()
        self.tableLampCreate()
    }
    private func tableLampCreate(){
        do{
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            db=try Connection("\(path)/db.sqlite3")
            try self.db.run(table.create(ifNotExists: true, block: { (t) in
                t.column(id, primaryKey:true)
                t.column(goodsCategoryId)
                t.column(goodsCategoryName)
                t.column(goodsCategoryPid)
                t.column(goodsCategoryIco)
        }))
        } catch {
            print("创建数据库失败--\(error)")
        }
    }
    ///查询数据
    func selectArr(pid:Int64) -> [GoodscategoryEntity]{
        var arr=[GoodscategoryEntity]()
        let alice=table.filter(goodsCategoryPid == pid)
        do{
            for value in (try db.prepare(alice)){
                let entity=GoodscategoryEntity()
                entity.goodsCategoryPid=Int(value[goodsCategoryPid])
                entity.goodsCategoryId=Int(value[goodsCategoryId])
                entity.goodsCategoryIco=value[goodsCategoryIco]
                entity.goodsCategoryName=value[goodsCategoryName]
                arr.append(entity)
            }
        }catch{
            print("查询数据错误--\(error)")
        }
        if pid == 9999{//如果查询一级分类
            if arr.count == 0{//如果没有数据
                refreshClassificationData() //重新请求分类数据刷新
            }
        }
        return arr
    }
    ///插入单条数据
    func insertEntity(entity:GoodscategoryEntity) {
        do{
            let count=try db.scalar("SELECT COUNT(goodsCategoryId) FROM GoodClassification WHERE goodsCategoryId = ?",entity.goodsCategoryId!) as? Int64
            if count == 0{
                let insert=table.insert(goodsCategoryPid <- Int64(entity.goodsCategoryPid!),goodsCategoryId <- Int64(entity.goodsCategoryId!),goodsCategoryIco <- entity.goodsCategoryIco,goodsCategoryName <- entity.goodsCategoryName)
                    try db.run(insert)
            }
        }catch{
            print("插入数据错误---\(error)")
        }
    }
    ///删除数据
    func deleteArrEntity(){
        do{
            try db.run(table.delete())
        }catch{
            print("删除数据错误---\(error)")
        }
    }
    ///刷新分类数据
    func refreshClassificationData(){
        
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:GoodsClassifiationApi.queryGoodsCateGoryList(), successClosure: { (json) in
            self.deleteArrEntity()
            //放到异步线程中操作
            DispatchQueue.global().async(execute: {
                for(_,value) in json{
                    let entity=self.returnEntity(json: value)
                    entity.goodsCategoryPid=9999
                    for(_,value2) in value["list"]{
                        let entity2=self.returnEntity(json:value2)
                        entity2.goodsCategoryPid=entity.goodsCategoryId
                        GoodClassificationDB.shared.insertEntity(entity:entity2)
                        for(_,value3) in value2["list"]{
                            let entity3=self.returnEntity(json:value3)
                            entity3.goodsCategoryPid=entity2.goodsCategoryId
                            GoodClassificationDB.shared.insertEntity(entity:entity3)
                        }
                    }
                    GoodClassificationDB.shared.insertEntity(entity:entity)
                }
            })
        }) { (error) in
        }
    }
    private func returnEntity(json:JSON) ->GoodscategoryEntity{
        let entity=GoodscategoryEntity()
        entity.goodsCategoryIco=json["goodsCategoryIco"].stringValue
        entity.goodsCategoryId=json["goodsCategoryId"].intValue
        entity.goodsCategoryName=json["goodsCategoryName"].stringValue
        entity.goodsCategoryPid=json["goodsCategoryPid"].int
        return entity
    }
}
