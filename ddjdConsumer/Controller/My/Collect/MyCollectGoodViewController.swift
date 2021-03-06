//
//  MyCollectGoodViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/18.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
//我的收藏
class MyCollectGoodViewController:BaseViewController{
    //table
    @IBOutlet weak var table: UITableView!
    private var arr=[GoodEntity]()
    private var pageNumber=1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="我的收藏"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        table.tableFooterView=UIView(frame: CGRect.zero)
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        table.estimatedRowHeight = 0;
        table.estimatedSectionHeaderHeight = 0;
        table.estimatedSectionFooterHeight = 0;
        self.setLoadingState(isLoading:true)
        self.setEmptyDataSetInfo(text:"还没有收藏商品")
        self.getCollectGoodList(pageSize:10, pageNumber:self.pageNumber)
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.getCollectGoodList(pageSize:10, pageNumber:self.pageNumber)
        })
        table.mj_footer.isHidden=true
    }
}

///网络请求
extension MyCollectGoodViewController{
    ///请求收藏商品
    private func getCollectGoodList(pageSize:Int,pageNumber:Int,index:IndexPath?=nil){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:GoodApi.getAllCollection(memberId:MEMBERID, pageSize: pageSize, pageNumber: pageNumber), successClosure: { (json) in
            var arrCount=[GoodEntity]()
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object: value.object)
                if index != nil{
                    arrCount.append(entity!)
                }else{
                    self.arr.append(entity!)
                }
            }
            if index != nil{
                if arrCount.count > 0{
                    self.arr.append(arrCount.last!)
                }
            }
            self.totalRow=json["totalRow"].intValue
            if self.arr.count < self.totalRow{
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
    ///删除收藏商品
    private func delCollectGood(goodsCollectionId:Int,index:IndexPath){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:GoodApi.removeCollection(memberId:MEMBERID, goodsCollectionId: goodsCollectionId), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                let cell=self.table.cellForRow(at:index)
                if cell != nil{
                    self.showSVProgressHUD(status:"删除成功", type: HUD.success)
                    if self.arr.count == self.totalRow{
                        self.arr.remove(at:index.row)
                        self.table.deleteRows(at:[index], with: UITableViewRowAnimation.fade)
                        self.totalRow-=1
                        if self.arr.count == 0{
                            self.table.reloadData()
                        }
                    }else{
                        self.arr.remove(at:index.row)
                        self.table.deleteRows(at:[index], with: UITableViewRowAnimation.fade)
                        self.getCollectGoodList(pageSize:10, pageNumber:self.pageNumber, index:index)
                    }
                }
            }else{
                self.showSVProgressHUD(status:"删除失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status: error!, type: HUD.error)
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
extension MyCollectGoodViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"MyCollectGoodTableViewCellId") as? MyCollectGoodTableViewCell
        if cell == nil{
            cell=getXibClass(name:"MyCollectGoodTableViewCell", owner:self) as? MyCollectGoodTableViewCell
        }
        if arr.count > 0{
            let entity=arr[indexPath.row]
            cell!.updateCell(entity:entity)
            //检查图片状态
            switch (entity.state){
            case .new, .downloaded:
                //只有停止拖动的时候才加载
                if (!tableView.isDragging && !tableView.isDecelerating) {
                    self.startOperationsForMovieRecord(entity, indexPath: indexPath, completion:{
                        self.table.reloadRows(at:[indexPath], with: UITableViewRowAnimation.fade)
                    })
                }
            case .failed:
                NSLog("do nothing")
            }
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
    //删除操作
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            self.delCollectGood(goodsCollectionId:self.arr[indexPath.row].goodsCollectionId ?? 0, index:indexPath)
        }
    }
    //把delete 该成中文
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "删除"
    }
}
///优化图片加载
extension MyCollectGoodViewController{
    //视图开始滚动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //一旦用户开始滚动屏幕，你将挂起所有任务并留意用户想要看哪些行。
        suspendAllOperations()
    }

    //视图停止拖动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        //如果减速（decelerate）是 false ，表示用户停止拖拽tableview。
        //此时你要继续执行之前挂起的任务，撤销不在屏幕中的cell的任务并开始在屏幕中的cell的任务。
        if !decelerate {
            resumeAllOperationsAndloadImagesForOnscreenCells(type:.tableView, scrollView: self.table, arr:arr)
        }
    }
    //视图停止减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //这个代理方法告诉你tableview停止滚动，执行操作同上
        resumeAllOperationsAndloadImagesForOnscreenCells(type:.tableView, scrollView: self.table, arr:arr)
    }
}
