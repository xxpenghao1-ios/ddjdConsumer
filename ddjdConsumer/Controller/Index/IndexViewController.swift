//
//  IndexViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/11.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import MJRefresh
/// 首页
class IndexViewController:BaseViewController{
    /// 可滑动容器
    @IBOutlet weak var scrollView: UIScrollView!
    //幻灯片view
    @IBOutlet weak var slideView:UIView!
    //幻灯片
    fileprivate var cycleScrollView:WRCycleScrollView!
    //分类高度
    @IBOutlet weak var classityCollectionViewHeight: NSLayoutConstraint!
    //商品list高度
    @IBOutlet weak var goodCollectionViewHeight: NSLayoutConstraint!
    //分类
    @IBOutlet weak var indexClassifyCollectionView: UICollectionView!
    //店长推荐view
    @IBOutlet weak var recommendView: UIView!
    @IBOutlet weak var lblRecommend: UILabel!
    //营业时间
    @IBOutlet weak var lblBusinessTime: UILabel!
    //商品list
    @IBOutlet weak var goodCollectionView: UICollectionView!
    //分类数据源
    fileprivate let classifyName=["促销专区","点单VIP","我的订单","购买历史"]
    //幻灯片数组
    private var advertisingURLArr=[String]()
    //推荐商品
    private var goodArr=[GoodEntity]()
    private var pageNumber=1
    fileprivate let calssifyImg=["classify_promotions","classify_ddvip","classify_order","classify_record"]
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MEMBERID != -1{
            ///每次进首页获取店铺信息
            self.getStoreInfo()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpNav()
        setUpView()
        //刷新
        scrollView.mj_header=PHNormalHeader(refreshingBlock: {
            self.pageNumber=1
            self.getAllAdvertising()
            self.getIndexGoodList(pageSize:10, pageNumber:self.pageNumber,isRefresh:true)
        })
        scrollView.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.getIndexGoodList(pageSize:10,pageNumber:self.pageNumber,isRefresh:false)
        })
        scrollView.mj_footer.isHidden=true
        scrollView.mj_header.beginRefreshing()
    }
    
}

// MARK: - 设置页面
extension IndexViewController{
    //设置页面
    private func setUpView(){
        //幻灯片
        cycleScrollView=WRCycleScrollView(frame:CGRect(x:0, y:0, width:boundsWidth, height:150))
        cycleScrollView.delegate = self
        cycleScrollView.backgroundColor=UIColor.viewBackgroundColor()
        cycleScrollView.pageControlAliment = .CenterBottom
        cycleScrollView.currentDotColor = .white
        cycleScrollView.autoScrollInterval=4
        cycleScrollView.localImgArray=[slide_default]
        slideView.addSubview(cycleScrollView)
        
        //分类
        //初始化UICollectionViewFlowLayout.init对象
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize=CGSize(width:boundsWidth/4, height: boundsWidth/4)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0;//每个相邻layout的上下
        flowLayout.minimumInteritemSpacing = 0;//每个相邻layout的左右
        indexClassifyCollectionView.collectionViewLayout = flowLayout
        indexClassifyCollectionView.showsHorizontalScrollIndicator=false
        indexClassifyCollectionView.register(UINib(nibName: "IndexClassifyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"indexClassifyId")
        indexClassifyCollectionView.tag=1
        classityCollectionViewHeight.constant=boundsWidth/4
        recommendView.backgroundColor=UIColor.viewBackgroundColor()
        lblRecommend.textColor=UIColor.applicationMainColor()
        
        //热门商品
        //初始化UICollectionViewFlowLayout.init对象
        let layout = WaterFlowViewLayout()
        layout.margin=2.5
        layout.delegate=self
        goodCollectionView.collectionViewLayout = layout
        goodCollectionView.isScrollEnabled=false
        goodCollectionView.register(UINib(nibName: "GoodCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"goodCollectionViewCellId")
        goodCollectionView.tag=2
        goodCollectionView.backgroundColor=UIColor.viewBackgroundColor()
        //更新布局高度
        updateViewHeight()
    }
    
    //设置导航栏
    private func setUpNav(){
        //log图片
        let logItem=UIBarButtonItem(image:UIImage(named:"log")?.reSizeImage(reSize: CGSize(width:81, height:25)), style:.done, target:self, action:nil)
        //直接创建一个文本框
        let txt=UITextField(frame:CGRect(x:0,y:0, width:boundsWidth-130, height:30))
        txt.backgroundColor=UIColor.RGBFromHexColor(hexString:"f0f2f5")
        txt.delegate=self
        txt.placeholder="请输入您要搜索的商品"
        txt.font=UIFont.systemFont(ofSize: 14)
        txt.tintColor=UIColor.clear
        txt.resignFirstResponder()
        txt.layer.cornerRadius=15
        let leftView=UIView(frame:CGRect(x:0,y:0, width:30, height:30))
        let leftImageView=UIImageView(frame:CGRect(x:10,y:8.5,width:13.5,height:13))
        leftImageView.image=UIImage(named:"search")
        leftView.addSubview(leftImageView)
        txt.leftView=leftView
        txt.leftViewMode=UITextFieldViewMode.always
        let searchItem=UIBarButtonItem(customView:txt)
        self.navigationItem.leftBarButtonItems=[logItem,searchItem]
    }
    /// 更新布局高度
    func updateViewHeight(){
        let count=goodArr.count
        let rowCount=count%2==0 ? count/2 : count/2+1
        goodCollectionViewHeight.constant=(boundsWidth/2+82.5)*CGFloat(rowCount)
//        一定要显式在主线程调用刷新 不然会有cell不显示情况stackoverflow上很多人说这是UICollectionView的一个bug  目前没有好的解决方案
        DispatchQueue.main.async(execute: {
            self.goodCollectionView.reloadData()
        })
    }
}
// MARK: - UICollectionView实现
extension IndexViewController:UICollectionViewDelegate,UICollectionViewDataSource,WaterFlowViewLayoutDelegate{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1{//分类
            let cell=indexClassifyCollectionView.dequeueReusableCell(withReuseIdentifier:"indexClassifyId", for:indexPath) as! IndexClassifyCollectionViewCell
            
            cell.updateCell(name:classifyName[indexPath.row], imgStr:calssifyImg[indexPath.row])
            return cell
        }else{//商品cell
            let cell=goodCollectionView.dequeueReusableCell(withReuseIdentifier:"goodCollectionViewCellId", for:indexPath) as! GoodCollectionViewCell
            if goodArr.count > 0{
                let entity=goodArr[indexPath.row]
                cell.updateCell(entity:goodArr[indexPath.row])
                cell.pushGoodDetailsVCClosure={
                    if MEMBERID == -1{
                        self.present(UINavigationController.init(rootViewController:app.returnLoginVC()), animated:true, completion:nil)
                    }else{
                        self.pushGoodDetailsVC(entity:entity)
                    }
                }
                cell.goodAddCarClosure={
                    if MEMBERID == -1{
                        self.present(UINavigationController.init(rootViewController:app.returnLoginVC()), animated:true, completion:nil)
                    }else{
                        self.addCar(storeAndGoodsId:entity.storeAndGoodsId ?? 0)
                    }
                }
            }
            return cell
        }
    
    }
    func waterFlowViewLayout(waterFlowViewLayout: WaterFlowViewLayout, heightForWidth: CGFloat, atIndextPath: IndexPath) -> CGFloat {
        return boundsWidth/2+80
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1{
            return classifyName.count
        }else{
            return goodArr.count
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if MEMBERID != -1{
            if collectionView.tag == 1{
                if indexPath.item == 0{
                    let vc=PromotionListViewController()
                    vc.hidesBottomBarWhenPushed=true
                    self.navigationController?.pushViewController(vc, animated:true)
                }else if indexPath.item == 1{//跳转促销区
                    let vc=self.storyboardPushView(type:.index, storyboardId:"DDVIPVC") as! DDVIPViewCcontroller
                    vc.hidesBottomBarWhenPushed=true
                    self.navigationController?.pushViewController(vc, animated:true)
                }else if indexPath.item == 2{//跳转到订单
                    let vc=OrderListPageController()
                    vc.orderStatus=0
                    vc.hidesBottomBarWhenPushed=true
                    self.navigationController?.pushViewController(vc, animated:true)
                }else if indexPath.item == 3{
                    let vc=self.storyboardPushView(type:.my, storyboardId:"PurchaseHistoryVC") as! PurchaseHistoryViewController
                    vc.hidesBottomBarWhenPushed=true
                    self.navigationController?.pushViewController(vc, animated:true)

                }
            }
        }else{
            self.present(UINavigationController.init(rootViewController:app.returnLoginVC()), animated:true, completion:nil)
        }
    }
}

// MARK: - 幻灯片协议
extension IndexViewController:WRCycleScrollViewDelegate{
    /// 点击图片回调
    func cycleScrollViewDidSelect(at index:Int, cycleScrollView:WRCycleScrollView)
    {
        
    }
    /// 图片滚动回调
    func cycleScrollViewDidScroll(to index:Int, cycleScrollView:WRCycleScrollView)
    {
        
    }

}

// MARK: - 跳转到搜索页面
extension IndexViewController:UITextFieldDelegate{
    //实现导航控制器文本框的协议
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //点击文本框不让键盘弹出来
        textField.resignFirstResponder()
        let vc=SearchViewController()
        vc.hidesBottomBarWhenPushed=true;
        self.navigationController?.pushViewController(vc, animated:true);
    }
    //跳转到商品详情
    func pushGoodDetailsVC(entity: GoodEntity) {
        let vc=self.storyboardPushView(type: .index, storyboardId:"GoodDetailsVC") as! GoodDetailsViewController
        vc.storeAndGoodsId=entity.storeAndGoodsId
        vc.hidesBottomBarWhenPushed=true
        self.navigationController?.pushViewController(vc, animated:true)
    }
    
}
// MARK: - 网络请求
extension IndexViewController{
    //请求幻灯片数据
    private func getAllAdvertising(){
        self.advertisingURLArr.removeAll()
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:IndexApi.getAllAdvertising(), successClosure: { (json) in
            for(_,value) in json{
                let entity=self.jsonMappingEntity(entity:AdvertisingEntity.init(), object:value.object)
                entity!.advertisingURL=entity!.advertisingURL ?? ""
                self.advertisingURLArr.append(urlImg+entity!.advertisingURL!)
            }
            if self.advertisingURLArr.count > 0{
                self.cycleScrollView.serverImgArray=self.advertisingURLArr
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: .error)
            
        }
    }
    //请求首页推荐商品
    private func getIndexGoodList(pageSize:Int,pageNumber:Int,isRefresh:Bool){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target: IndexApi.indexGoods(bindstoreId:BINDSTOREID, pageSize:pageSize,pageNumber:pageNumber),successClosure: { (json) in
            if isRefresh{
                self.goodArr.removeAll()
            }
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object: value.object)
                self.goodArr.append(entity!)
            }
            self.totalRow=json["totalRow"].intValue
            if self.goodArr.count < self.totalRow{
                self.scrollView.mj_footer.isHidden=false
            }else{
                self.scrollView.mj_footer.isHidden=true
            }
            self.updateViewHeight()
            self.scrollView.mj_header.endRefreshing()
            self.scrollView.mj_footer.endRefreshing()
        }) { (error) in
            self.showSVProgressHUD(status:error!,type: HUD.error)
            self.scrollView.mj_header.endRefreshing()
            self.scrollView.mj_footer.endRefreshing()
        }
    }
    //加入购物车
    private func addCar(storeAndGoodsId:Int){
        self.showSVProgressHUD(status:"正在加入...",type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.addCar(memberId:MEMBERID, storeAndGoodsId:storeAndGoodsId,goodsCount:1, goodsStuta:1), successClosure: { (json) in
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
    //获取店铺信息
    private func getStoreInfo(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreInfoApi.queryStoreById(bindstoreId:BINDSTOREID), successClosure: { (json) in
            let success=json["success"].stringValue
            
            if success == "success"{
                let entity=self.jsonMappingEntity(entity:StoreEntity.init(), object:json["store"].object)
                if entity != nil{
                    if entity!.distributionStartTime != nil && entity!.distributionEndTime != nil{
                        self.lblBusinessTime.text=entity!.distributionStartTime!+"-"+entity!.distributionEndTime!
                    }else{
                        self.lblBusinessTime.text="24小时营业"
                    }
                    ///把最低起送额保存
                    userDefaults.set(entity?.lowestMoney, forKey:"lowestMoney")
                    userDefaults.set(entity?.deliveryFee, forKey:"deliveryFee")
                    userDefaults.set(entity?.storeName, forKey:"storeName")
                    userDefaults.set(entity?.tel, forKey:"storeTel")
                    userDefaults.synchronize()
                }
            }
        }) { (error) in
            
        }
    }
}
