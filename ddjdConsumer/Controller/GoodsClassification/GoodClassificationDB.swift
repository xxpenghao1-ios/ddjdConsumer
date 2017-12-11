//
//  GoodClassificationDB.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/10.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import SQLite

///保存数据
class GoodClassificationDB:NSObject{
    static let shared = GoodClassificationDB()
    private var db:Connection?{
        get{
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let db = try? Connection("\(path)/db.sqlite3")
            return db
        }
    }
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
        try! self.db?.run(table.create(ifNotExists: true, block: { (t) in
            t.column(id, primaryKey:true)
            t.column(goodsCategoryId)
            t.column(goodsCategoryName)
            t.column(goodsCategoryPid)
            t.column(goodsCategoryIco)
        }))
    }
    ///查询数据
    func selectArr(pid:Int64) -> [GoodscategoryEntity]{
        var arr=[GoodscategoryEntity]()
        let alice=table.filter(goodsCategoryPid == pid)
        if db != nil{
            for value in (try! db!.prepare(alice)){
                let entity=GoodscategoryEntity()
                entity.goodsCategoryPid=Int(value[goodsCategoryPid])
                entity.goodsCategoryId=Int(value[goodsCategoryId])
                entity.goodsCategoryIco=value[goodsCategoryIco]
                entity.goodsCategoryName=value[goodsCategoryName]
                arr.append(entity)
            }
        }
        return arr
    }
    ///插入单条数据
    func insertEntity(entity:GoodscategoryEntity) {
        let count=try! db?.scalar("SELECT COUNT(goodsCategoryId) FROM GoodClassification WHERE goodsCategoryId = ?",entity.goodsCategoryId!) as? Int64
        if count == 0{
            let insert=table.insert(goodsCategoryPid <- Int64(entity.goodsCategoryPid!),goodsCategoryId <- Int64(entity.goodsCategoryId!),goodsCategoryIco <- entity.goodsCategoryIco,goodsCategoryName <- entity.goodsCategoryName)
            try! db?.run(insert)
        }
    }
    ///删除数据
    func deleteArrEntity(){
        try! db?.run(table.delete())
    }
}
