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
            cell!.updateCell(entity:arr[indexPath.row])
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
        return "移除"
    }
}

// MARK: - 网络请求
extension HotGoodListViewController{
    
    /// 查询店铺首页推荐商品
    private func getIndexGoodList(pageSize:Int,pageNumber:Int,isRefresh:Bool){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:IndexApi.indexGoods(bindstoreId:STOREID, pageSize: pageSize, pageNumber: pageNumber), successClosure: { (json) in
            if isRefresh{
                self.arr.removeAll()
            }
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object: value.object)
                entity?.goodsFlag=nil
                entity?.indexGoodsId=1
                self.arr.append(entity!)
            }
            if self.arr.count < json["totalRow"].intValue{
                self.table.mj_header.isHidden=false
            }else{
                self.table.mj_header.isHidden=true
            }
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
                self.arr.remove(at:row)
                self.table.deleteRows(at:[IndexPath.init(row:row, section:0)], with: UITableViewRowAnimation.fade)
                if self.arr.count == 0{
                    self.table.reloadData()
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
