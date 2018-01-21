//
//  StorePromotionGoodListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/8.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///店铺促销商品
class StorePromotionGoodListViewController:BaseViewController{
    ///table
    @IBOutlet weak var table: UITableView!
    private var pageNumber=1
    private var arr=[GoodEntity]()
    ///商品操作 遮罩层
    private var operatingGoodMaskView:UIView!
    ///商品操作table
    private var operatingTable:UITableView!
    ///商品操作table高度
    private var operatingTableHeight:CGFloat=100
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="促销商品管理"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        self.queryPromotiongoodsPaginate(pageNumber:self.pageNumber, pageSize:10, isRefresh:true)
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.queryPromotiongoodsPaginate(pageNumber:self.pageNumber, pageSize:10, isRefresh:false)
        })
        self.table.mj_footer.isHidden=true
    }
}

// MARK: - 页面设置
extension StorePromotionGoodListViewController{
    private func setUpView(){
        table.delegate=self
        table.dataSource=self
        table.tag=100
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        self.view.addSubview(table)

        //设置空视图显示加载状态
        self.setLoadingState(isLoading:true)
        //空视图提示内容
        self.setEmptyDataSetInfo(text:"还木有促销商品")
    }
    ///刷新数据
    private func reloadData(){
        self.table.mj_footer.endRefreshing()
        self.setLoadingState(isLoading:false)
        self.table.reloadData()
    }
}
// MARK: - table协议
extension StorePromotionGoodListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"StorePromotionGoodTableViewCellId") as? StorePromotionGoodTableViewCell
        if cell == nil{
            cell=Bundle.main.loadNibNamed("StorePromotionGoodTableViewCell", owner:self, options: nil)?.last as? StorePromotionGoodTableViewCell
        }
        if arr.count > 0{
            let entity=arr[indexPath.row]
            cell!.updateCell(entity:entity)
        }
        return cell!

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    //删除操作
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let entity=self.arr[indexPath.row]
            self.removePromotiongoods(storeAndGoodsId:entity.storeAndGoodsId ?? 0, index:indexPath)
        }
    }
    //把delete 该成中文
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "移除促销商品"
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
// MARK: - 网络请求
extension StorePromotionGoodListViewController{
    private func  queryPromotiongoodsPaginate(pageNumber:Int,pageSize:Int,isRefresh:Bool){
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy-MM-dd HH:mm:ss"
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.queryPromotiongoodsPaginateStore(storeId:STOREID, pageNumber: pageNumber, pageSize: pageSize, salesCountFlag:nil, priceFlag:nil), successClosure: { (json) in
            print(json)
            if isRefresh{
                self.arr.removeAll()
            }
            for(_,value) in json["goodsList"]["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object: value.object)
                let date=dfmatter.date(from:entity!.promotionEndTime ?? "")
                entity?.promotionEndTimeSeconds=date==nil ? 0 : Int(date!.timeIntervalSince1970) - Int(Date().timeIntervalSince1970)
                self.arr.append(entity!)
            }
            self.totalRow=json["goodsList"]["totalRow"].intValue
            if self.arr.count < self.totalRow{
                self.table.mj_footer.isHidden=false
            }else{
                self.table.mj_footer.isHidden=true
            }
            self.showBaseVCGoodCountPromptView(currentCount:self.arr.count, totalCount:self.totalRow,view:self.view)
            self.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.reloadData()
        }
    }
    ///移除促销商品
    private func removePromotiongoods(storeAndGoodsId:Int,index:IndexPath){
        self.showSVProgressHUD(status:"正在移除...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.removePromotiongoods(storeAndGoodsId:storeAndGoodsId, storeId:STOREID), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.arr.remove(at:index.row)
                self.table.deleteRows(at:[index], with: UITableViewRowAnimation.fade)
                self.showSVProgressHUD(status:"移除成功", type: HUD.success)
                self.totalRow=self.totalRow-1
                self.showBaseVCGoodCountPromptView(currentCount:self.arr.count, totalCount:self.totalRow)
                if self.arr.count == 0{//如果数据为空
                    self.table.reloadData()
                }
            }else if success == "notExist"{
                self.showSVProgressHUD(status:"商品不存在", type: HUD.error)
            }else if success == "storeDifferent"{
                self.showSVProgressHUD(status:"商品不是这个店铺的，不能移除", type: HUD.error)
            }else{
                self.showSVProgressHUD(status:"移除失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
