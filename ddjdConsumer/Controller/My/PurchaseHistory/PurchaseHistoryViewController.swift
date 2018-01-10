//
//  PurchaseHistoryViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/1.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///购买历史
class PurchaseHistoryViewController:BaseViewController{
    @IBOutlet weak var table: UITableView!
    private var arr=[GoodEntity]()
    private var pageNumber=1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="购买历史"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        table.tableFooterView=UIView(frame: CGRect.zero)
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        self.setLoadingState(isLoading:true)
        self.setEmptyDataSetInfo(text:"还没有购买记录")
        self.getGoodsOfBuyed(pageSize:10, pageNumber:self.pageNumber)
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.getGoodsOfBuyed(pageSize:10, pageNumber:self.pageNumber)
        })
        table.mj_footer.isHidden=true
    }
}
extension PurchaseHistoryViewController{
    private func getGoodsOfBuyed(pageSize:Int,pageNumber:Int){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:GoodApi.getGoodsOfBuyed(memberId:MEMBERID, pageSize: pageSize, pageNumber:pageNumber), successClosure: { (json) in
            print(json)
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object: value.object)
                self.arr.append(entity!)
            }
            if self.arr.count < json["totalRow"].intValue{
                self.table.mj_footer.isHidden=false
            }else{
                self.table.mj_footer.isHidden=true
            }
            self.setLoadingState(isLoading:false)
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.setLoadingState(isLoading:false)
            self.table.reloadData()
        }
    }
    //加入购物车
    private func addCar(storeAndGoodsId:Int){
        self.showSVProgressHUD(status:"正在加入...",type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.addCar(memberId:MEMBERID, storeAndGoodsId:storeAndGoodsId,goodsCount:1,goodsStuta:1), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"成功加入购物车", type: HUD.success)
                //通知tab页面更新购物车角标
                NotificationCenter.default.post(name:updateCarBadgeValue,object:nil)
            }else if success == "underStock"{
                self.showSVProgressHUD(status:"库存不足", type: HUD.info)
            }else{
                self.showSVProgressHUD(status:"加入失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
///table协议
extension PurchaseHistoryViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"MyCollectGoodTableViewCellId") as? MyCollectGoodTableViewCell
        if cell == nil{
            cell=getXibClass(name:"MyCollectGoodTableViewCell", owner:self) as? MyCollectGoodTableViewCell
        }
        if arr.count > 0{
            let entity=arr[indexPath.row]
            cell!.updateCell(entity:entity)
            cell!.addCarClosure={
                self.addCar(storeAndGoodsId:entity.storeAndGoodsId ?? 0)
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
