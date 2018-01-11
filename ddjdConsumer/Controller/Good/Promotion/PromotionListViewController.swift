//
//  PromotionListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/5.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import JNDropDownMenu
///促销商品列表
class PromotionListViewController:BaseViewController{

    private var arr=[GoodEntity]()

    private var table:UITableView!

    private var menu:JNDropDownMenu!

    private var pageNumber=1

    ///价格排序 1.降序 2. 升序
    private var priceFlag:Int?=2
    ///销量排序1.降序 2. 升序
    private var salesCountFlag:Int?=nil
    /// 定时器
    private var timer:Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="促销专区"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        self.queryPromotiongoodsPaginate(pageNumber:self.pageNumber, pageSize:10, isRefresh:true)
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.queryPromotiongoodsPaginate(pageNumber:self.pageNumber, pageSize:10, isRefresh:false)
        })
        self.table.mj_footer.isHidden=true
        // 启动倒计时管理
        OYCountDownManager.sharedManager.start()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 废除定时器
        OYCountDownManager.sharedManager.invalidate()
    }
}

// MARK: - 页面设置
extension PromotionListViewController{

    private func setUpView(){
        menu=JNDropDownMenu(origin: CGPoint.init(x:0, y:0), height:44, width:boundsWidth)
        //设置排序控件
        menu.datasource=self
        menu.delegate=self
        self.view.addSubview(menu)

        table=UITableView(frame: CGRect.init(x:0, y:menu.frame.maxY, width:boundsWidth, height:boundsHeight-menu.frame.maxY-bottomSafetyDistanceHeight-navHeight))
        table.delegate=self
        table.dataSource=self
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        table.backgroundColor=UIColor.clear
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
        ///刷新倒计时
        OYCountDownManager.sharedManager.reload()
        self.table.reloadData()
    }
}

// MARK: - table协议
extension PromotionListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"SpecialPriceTableViewCellId") as? SpecialPriceTableViewCell
        if cell == nil{
            cell=Bundle.main.loadNibNamed("SpecialPriceTableViewCell", owner:self, options: nil)?.last as? SpecialPriceTableViewCell
        }
        if arr.count > 0{
            let entity=arr[indexPath.row]
            cell!.updateCell(entity:entity)
            cell!.addCarClosure={
                self.addCar(storeAndGoodsId:entity.storeAndGoodsId ?? 0)
            }
//            cell!.pushGoodDetailClosure={
//                let vc=self.storyboardPushView(type:.index, storyboardId:"PromotionGoodDetailVC") as! PromotionGoodDetailViewController
//                vc.storeAndGoodsId=entity.storeAndGoodsId
//                vc.goodsStuta=3
//                self.navigationController?.pushViewController(vc, animated:true)
//            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity=arr[indexPath.row]
        let vc=self.storyboardPushView(type:.index, storyboardId:"PromotionGoodDetailVC") as! PromotionGoodDetailViewController
        vc.storeAndGoodsId=entity.storeAndGoodsId
        vc.goodsStuta=3
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
// MARK: - 网络请求
extension PromotionListViewController{
    private func  queryPromotiongoodsPaginate(pageNumber:Int,pageSize:Int,isRefresh:Bool){
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy-MM-dd HH:mm:ss"
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:GoodApi.queryPromotiongoodsPaginate(memberId:MEMBERID, bindstoreId:BINDSTOREID, pageNumber: pageNumber,pageSize:pageSize,salesCountFlag:salesCountFlag, priceFlag:priceFlag), successClosure: { (json) in
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
            if self.arr.count < json["goodsList"]["totalRow"].intValue{
                self.table.mj_footer.isHidden=false
            }else{
                self.table.mj_footer.isHidden=true
            }
            self.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.reloadData()
        }
    }
    /// 加入购物车
    private func addCar(storeAndGoodsId:Int){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.addCar(memberId:MEMBERID, storeAndGoodsId:storeAndGoodsId,goodsCount:1, goodsStuta:3), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"成功加入购物车", type: HUD.success)
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
extension PromotionListViewController:JNDropDownMenuDelegate,JNDropDownMenuDataSource{
    func numberOfColumns(in menu: JNDropDownMenu) -> NSInteger {
        return 2
    }
    func numberOfRows(in column: NSInteger, for menu: JNDropDownMenu) -> Int {
        return 3
    }
    func titleForRow(at indexPath: JNIndexPath, for menu: JNDropDownMenu) -> String {
        if indexPath.column == 0{
            if indexPath.row == 0{
                return "销量"
            }else if indexPath.row == 1{
                return "销量从低到高"
            }else{
                return "销量从高到低"
            }
        }else{
            if indexPath.row == 0{
                return "价格"
            }else if indexPath.row == 1{
                return "价格从低到高"
            }else{
                return "价格从高到低"
            }
        }
    }
    func didSelectRow(at indexPath: JNIndexPath, for menu: JNDropDownMenu) {
        if indexPath.column == 0{
            if indexPath.row == 0{
                salesCountFlag=1
                priceFlag=nil
            }else if indexPath.row == 1{
                salesCountFlag=2
                priceFlag=nil
            }else{
                salesCountFlag=1
                priceFlag=nil
            }
        }else{
            if indexPath.row == 0{
                priceFlag=2
                salesCountFlag=nil
            }else if indexPath.row == 1{
                priceFlag=2
                salesCountFlag=nil
            }else{
                priceFlag=1
                salesCountFlag=nil
            }
        }
        self.pageNumber=1
        self.setLoadingState(isLoading:true)
        self.arr.removeAll()
        self.reloadData()
        self.queryPromotiongoodsPaginate(pageNumber:self.pageNumber, pageSize:10, isRefresh:true)
    }
}
