//
//  GoodListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/2.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import MJRefresh
import SnapKit
import JNDropDownMenu
///商品列表
class GoodListViewController:BaseViewController{
    //接收搜索名称 或者分类名称
    var name:String?
    //分类id
    var tCategoryId:Int?
    //搜索文本框
    private var txtSearch:UITextField!
    //顶部view(用于排序)
    var menu: JNDropDownMenu!
    //商品list
    var goodCollection: UICollectionView!
    //返回顶部
    var returnTopImg: UIImageView!
    
    private var goodArr=[GoodEntity]()
    
    private var pageNumber=1
    
    ///价格排序 1.降序 2. 升序
    private var priceFlag:Int?=2
    ///销量排序1.降序 2. 升序
    private var salesCountFlag:Int?=nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpNav()
        setUpView()
        txtSearch.text=name
        loadList()
        goodCollection.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.loadList()
        })
        goodCollection.mj_footer.isHidden=true
    }
    //加载数据
    private func loadList(){
        //默认按价格排序从低到高
        if self.tCategoryId == nil{
            self.searchGood(pageSize:10, pageNumber: self.pageNumber, goodsName: self.name!)
        }else{
            self.goodListByCategoryId(pageSize:10,pageNumber:self.pageNumber)
        }
    }
}
///页面设置
extension GoodListViewController{
    ///设置页面
    private func setUpView(){
        menu=JNDropDownMenu(origin: CGPoint.init(x:0, y:0), height:44, width:boundsWidth)
        //设置排序控件
        menu.datasource=self
        menu.delegate=self
        self.view.addSubview(menu)
        //设置空视图显示加载状态
        self.setLoadingState(isLoading:true)
        //设置空视图显示
        self.setDisplay(isDisplay:true)
        //空视图提示内容
        self.setEmptyDataSetInfo(text:"还木有相关商品")
        //商品列表设置
        //初始化UICollectionViewFlowLayout.init对象
        let layout = WaterFlowViewLayout()
        layout.margin=2.5
        layout.delegate=self
        goodCollection=UICollectionView(frame:CGRect.init(x:0, y:menu.frame.maxY, width:boundsWidth,height:boundsHeight-menu.frame.maxY-bottomSafetyDistanceHeight-navHeight), collectionViewLayout:layout)
        goodCollection.delegate=self
        goodCollection.dataSource=self
        goodCollection.emptyDataSetSource=self
        goodCollection.emptyDataSetDelegate=self
        goodCollection.backgroundColor=UIColor.clear
        goodCollection.register(UINib(nibName: "GoodCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"goodCollectionViewCellId")
        self.view.addSubview(goodCollection)
        //返回顶部
        returnTopImg=UIImageView(frame:CGRect.init(x:boundsWidth-50, y:boundsHeight-45-bottomSafetyDistanceHeight-10-navHeight, width:45, height: 45))
        returnTopImg.image=UIImage.init(named:"return_top")
        self.view.addSubview(returnTopImg)
        returnTopImg.isUserInteractionEnabled=true
        returnTopImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(returnTop)))
        returnTopImg.isHidden=true
    }
    ///设置导航
    private func setUpNav(){
        //直接创建一个文本框
        txtSearch=UITextField(frame:CGRect(x:0,y:0, width:boundsWidth-100, height:30))
        txtSearch.backgroundColor=UIColor.RGBFromHexColor(hexString:"f0f2f5")
        txtSearch.placeholder="请输入您要搜索的商品"
        txtSearch.font=UIFont.systemFont(ofSize: 14)
        txtSearch.tintColor=UIColor.clear
        txtSearch.delegate=self
        txtSearch.returnKeyType = .search
        txtSearch.clearButtonMode = .whileEditing
        txtSearch.resignFirstResponder()
        txtSearch.layer.cornerRadius=15
        //左边搜索图片
        let leftView=UIView(frame:CGRect(x:0,y:0, width:30, height:30))
        let leftImageView=UIImageView(frame:CGRect(x:10,y:8.5,width:13.5,height:13))
        leftImageView.image=UIImage(named:"search")
        leftView.addSubview(leftImageView)
        txtSearch.leftView=leftView
        txtSearch.leftViewMode=UITextFieldViewMode.always
        let searchTxtItem=UIBarButtonItem(customView:txtSearch)
        let carItem=UIBarButtonItem(image:UIImage(named:"add_car")?.reSizeImage(reSize:CGSize(width:25, height:25)), style: UIBarButtonItemStyle.done, target:self, action:#selector(pushCarVC))
        self.navigationItem.rightBarButtonItems=[carItem,searchTxtItem]
    }
}

// MARK: - 滑动协议
extension GoodListViewController{
    //监听滑动事件
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > (boundsWidth/2+80*2){//滑动2排商品距离显示返回顶部按钮
            returnTopImg.isHidden=false
        }else{
            returnTopImg.isHidden=true
        }
    }
}
// MARK: goodCollection协议
extension GoodListViewController:UICollectionViewDelegate,UICollectionViewDataSource,WaterFlowViewLayoutDelegate{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell=goodCollection.dequeueReusableCell(withReuseIdentifier:"goodCollectionViewCellId", for:indexPath) as! GoodCollectionViewCell
        if goodArr.count > 0{
            let entity=goodArr[indexPath.item]
            cell.updateCell(entity:entity)
            //检查图片状态
            switch (entity.state){
            case .new, .downloaded:
                //只有停止拖动的时候才加载
                if (!goodCollection.isDragging && !goodCollection.isDecelerating) {
                    self.startOperationsForMovieRecord(entity, indexPath: indexPath, completion:{
                        UIView.performWithoutAnimation({
                            UIView.animate(withDuration:1, delay:0, options:.transitionCrossDissolve, animations: {
                                self.goodCollection.reloadItems(at:[indexPath])
                            }, completion: nil)
                        })
                    })
                }
            case .failed:
                NSLog("do nothing")
            }
            cell.pushGoodDetailsVCClosure={
                self.pushGoodDetailsVC(entity:entity)
            }
            cell.goodAddCarClosure={
                self.addCar(storeAndGoodsId:entity.storeAndGoodsId ?? 0)
            }
        }
        return cell
        
        
    }
    func waterFlowViewLayout(waterFlowViewLayout: WaterFlowViewLayout, heightForWidth: CGFloat, atIndextPath: IndexPath) -> CGFloat {
        return boundsWidth/2+80
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodArr.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
///优化图片加载
extension GoodListViewController{
    //视图开始滚动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //一旦用户开始滚动屏幕，你将挂起所有任务并留意用户想要看哪些行。
        suspendAllOperations()
    }

    //视图停止拖动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        //如果减速（decelerate）是 false ，表示用户停止拖拽scrollView。
        //此时你要继续执行之前挂起的任务，撤销不在屏幕中的cell的任务并开始在屏幕中的cell的任务。
        if !decelerate {
            resumeAllOperationsAndloadImagesForOnscreenCells(type:.collectView, scrollView: self.goodCollection, arr:goodArr)
        }
    }
    //视图停止减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //这个代理方法告诉你scrollView停止滚动，执行操作同上
        resumeAllOperationsAndloadImagesForOnscreenCells(type:.collectView, scrollView:self.goodCollection,arr:goodArr)
    }
}
///JND协议
extension GoodListViewController:JNDropDownMenuDelegate,JNDropDownMenuDataSource{
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
        self.setLoadingState(isLoading:true)
        self.goodArr.removeAll()
        self.goodCollection.reloadData()
        self.pageNumber=1
        loadList()
    }
}
///页面逻辑
extension GoodListViewController:UITextFieldDelegate{
    //实现导航控制器文本框的协议 跳转到搜索页面
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //点击文本框不让键盘弹出来
        textField.resignFirstResponder()
        let vc=SearchViewController()
        vc.searchNameClosure={ (str) in //接收到参数后 重新加载数据
            textField.text=str
            self.name=str
            self.tCategoryId=nil
            //设置空视图显示加载状态
            self.setLoadingState(isLoading:true)
            self.goodArr.removeAll()
            self.goodCollection.reloadData()
            self.pageNumber=1
            self.loadList()
        }
        vc.flag=1
        let nav=UINavigationController(rootViewController:vc)
        self.present(nav,animated:true, completion: nil)
    }
    //跳转到购物车页面
    @objc private func pushCarVC(){
        let vc=self.storyboardPushView(type: .shoppingCar, storyboardId:"ShoppingCarVC") as! ShoppingCarViewController
        self.navigationController?.pushViewController(vc, animated:true)
    }
    //点击view隐藏键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //返回顶部
    @objc private func returnTop(){
        let at=IndexPath(item:0, section:0)
        self.goodCollection.scrollToItem(at:at,at: UICollectionViewScrollPosition.bottom, animated:true)
    }
    //跳转到商品详情
    func pushGoodDetailsVC(entity: GoodEntity) {
        let vc=self.storyboardPushView(type: .index, storyboardId:"GoodDetailsVC") as! GoodDetailsViewController
        vc.storeAndGoodsId=entity.storeAndGoodsId
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
//网络请求
extension GoodListViewController{
    //搜索商品
    func searchGood(pageSize:Int,pageNumber:Int,goodsName:String){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target: GoodApi.searchGood(memberId:MEMBERID, pageSize:pageSize, pageNumber: pageNumber, bindstoreId:BINDSTOREID, goodsName: goodsName, priceFlag:priceFlag, salesCountFlag:salesCountFlag), successClosure: { (json) in
            
            for(_,value) in json["goodsList"]["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object:value.object)
                self.goodArr.append(entity!)
            }
            self.totalRow=json["goodsList"]["totalRow"].intValue
            if self.goodArr.count >= self.totalRow{
                self.goodCollection.mj_footer.isHidden=true
            }else{
                self.goodCollection.mj_footer.isHidden=false
            }
            self.endRefreshing()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.endRefreshing()
        }
    }
    //根据3级分类查询商品
    func goodListByCategoryId(pageSize:Int,pageNumber:Int){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:GoodApi.goodListByCategoryId(memberId:MEMBERID, pageSize: pageSize, pageNumber: pageNumber, bindstoreId:BINDSTOREID, tCategoryId:tCategoryId!, priceFlag: priceFlag,salesCountFlag:salesCountFlag), successClosure: { (json) in
            for(_,value) in json["goodsList"]["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object:value.object)
                self.goodArr.append(entity!)
            }
            self.totalRow=json["goodsList"]["totalRow"].intValue
            if self.goodArr.count >= self.totalRow{
                self.goodCollection.mj_footer.isHidden=true
            }else{
                self.goodCollection.mj_footer.isHidden=false
            }
            self.endRefreshing()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.endRefreshing()
        }
    }
    //关闭刷新加载状态
    private func endRefreshing(){
        self.setLoadingState(isLoading:false)
        self.goodCollection.mj_footer.endRefreshing()
        DispatchQueue.main.async(execute: {
            self.goodCollection.reloadData()
        })
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
