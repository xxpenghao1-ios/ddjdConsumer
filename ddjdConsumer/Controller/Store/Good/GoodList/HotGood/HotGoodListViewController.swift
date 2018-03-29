//
//  HotGoodListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/22.
//  Copyright © 2017年 zltx. All rights reserved.
//
import Foundation
///热门推荐商品list
class HotGoodListViewController:BaseViewController{
    ///table
    @IBOutlet weak var table: UITableView!
    
    private var arr=[GoodEntity]()
    
    private var pageNumber=1

    override func viewDidLoad(){
        super.viewDidLoad()
        self.title="热门推荐商品管理"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        self.getIndexGoodList(pageSize:10, pageNumber:self.pageNumber, isRefresh: true)
        table.mj_header=PHNormalHeader(refreshingBlock: {
            self.pageNumber=1
            self.getIndexGoodList(pageSize:10, pageNumber:self.pageNumber, isRefresh: true)
        })
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.getIndexGoodList(pageSize:10, pageNumber:self.pageNumber, isRefresh: false)
        })
        table.mj_footer.isHidden=true
        
    }
}

// MARK: - 页面相关设置
extension HotGoodListViewController{

    /// 页面设置
    private func setUpView(){
        table.delegate=self
        table.dataSource=self
        table.emptyDataSetSource=self
        table.emptyDataSetSource=self
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        table.separatorInset=UIEdgeInsets.init(top:0, left:0, bottom:0,right:0)
        self.setEmptyDataSetInfo(text:"没有热门推荐商品")
        self.setLoadingState(isLoading:true)
    }
    
    /// 刷新table
    private func reloadTable(){
        self.setLoadingState(isLoading:false)
        self.table.mj_footer.endRefreshing()
        self.table.mj_header.endRefreshing()
        self.table.reloadData()
    }
}

// MARK: - table相关设置
extension HotGoodListViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=tableView.dequeueReusableCell(withIdentifier:"hotId") as? StoreGoodListTableViewCell
        if cell == nil{
            cell=getXibClass(name:"StoreGoodListTableViewCell", owner:self) as? StoreGoodListTableViewCell
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
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    //删除操作
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            self.deleteIndexGoods(storeAndGoodsId:arr[indexPath.row].storeAndGoodsId ?? 0, row:indexPath.row)
        }
    }
    //把delete 该成中文
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "移除首页推荐"
    }
    
}
///优化图片加载
extension HotGoodListViewController{
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
// MARK: - 网络请求
extension HotGoodListViewController{
    
    /// 查询店铺首页推荐商品
    private func getIndexGoodList(pageSize:Int,pageNumber:Int,isRefresh:Bool,index:IndexPath?=nil){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:IndexApi.indexGoods(bindstoreId:STOREID, pageSize: pageSize, pageNumber: pageNumber), successClosure: { (json) in
            if isRefresh{
                self.arr.removeAll()
            }
            var arrCount=[GoodEntity]()
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object: value.object)
                entity?.goodsFlag=nil
                entity?.indexGoodsId=1
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
                self.table.mj_header.isHidden=false
            }else{
                self.table.mj_header.isHidden=true
            }
            self.showBaseVCGoodCountPromptView(currentCount:self.arr.count, totalCount:self.totalRow)
            self.reloadTable()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.reloadTable()
        }
    }
    private func deleteIndexGoods(storeAndGoodsId:Int,row:Int){
        self.showSVProgressHUD(status:"正在移除", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.removeIndexGoods(storeAndGoodsId:storeAndGoodsId, storeId:STOREID), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"移除成功", type: HUD.success)
                if self.arr.count == self.totalRow{
                    self.arr.remove(at:row)
                    self.table.deleteRows(at:[IndexPath.init(row:row, section:0)], with: UITableViewRowAnimation.fade)
                    self.totalRow=self.totalRow-1
                    self.showBaseVCGoodCountPromptView(currentCount:self.arr.count, totalCount:self.totalRow)
                    if self.arr.count == 0{
                        self.table.reloadData()
                    }
                }else{
                    self.arr.remove(at:row)
                    self.table.deleteRows(at:[IndexPath.init(row:row, section:0)], with: UITableViewRowAnimation.fade)
                    self.getIndexGoodList(pageSize:10, pageNumber:self.pageNumber, isRefresh:false,index:IndexPath.init(row:row, section:0))
                }
            }else if success == "notExist" {
                self.showSVProgressHUD(status:"不存在，不是首页热门推荐商品", type: HUD.info)
            }else{
                self.showSVProgressHUD(status:"移除失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
