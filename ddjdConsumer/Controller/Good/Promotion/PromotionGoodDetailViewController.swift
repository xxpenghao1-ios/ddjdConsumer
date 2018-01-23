//
//  PromotionGoodDetailViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/11.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import Kingfisher
///促销详情页面
class PromotionGoodDetailViewController:BaseViewController{
    /// 接收传入的商品Id
    var storeAndGoodsId:Int?
    ///1普通商品 3促销商品
    var goodsStuta:Int?
    //可滑动容器
    @IBOutlet weak var scrollView: UIScrollView!
    ///商品图片
    @IBOutlet weak var goodImg: UIImageView!

    /*********底部购物车操作***********/
    //加入购物车按钮
    @IBOutlet weak var btnAddCar: UIButton!
    //商品数量
    @IBOutlet weak var lblCount: UILabel!
    //增加商品数量
    @IBOutlet weak var btnAddCount: UIButton!
    //减少购物商品数量
    @IBOutlet weak var btnReduceCount: UIButton!
    //商品数量加减view
    @IBOutlet weak var goodCountView: UIView!
    /*********end底部购物车操作***********/

    /**********商品参数**********/
    //商品名称
    @IBOutlet weak var lblGoodName: UILabel!
    //商品价格(现价)
    @IBOutlet weak var lblGoodPrice: UILabel!
    //商品库存
    @IBOutlet weak var lblStock: UILabel!
    //商品销量
    @IBOutlet weak var lblSales: UILabel!
    //商品收藏图片
    @IBOutlet weak var collectImg: UIImageView!
    //商品单位
    @IBOutlet weak var lblUnit: UILabel!
    //商品规格
    @IBOutlet weak var lblUcode: UILabel!
    //商品品牌
    @IBOutlet weak var lblBrands: UILabel!
    //保质期
    @IBOutlet weak var lblShelfLife: UILabel!
    //条码
    @IBOutlet weak var lblBarcode: UILabel!
    /**********end商品参数**********/

    /**********促销信息*********/
    ///促销信息view高度
    @IBOutlet weak var promotionViewHeight: NSLayoutConstraint!
    ///促销信息view
    @IBOutlet weak var promotionView: UIView!
    ///促销时间
    @IBOutlet weak var lblPromotionTime: UILabel!
    ///促销内容
    @IBOutlet weak var lblPromotionMsg: UILabel!
    /**********end促销信息*******/
    //商品列表(为你推荐)
    @IBOutlet weak var goodCollection: UICollectionView!
    //商品列表高度
    @IBOutlet weak var goodCollectionHeight: NSLayoutConstraint!

    //保存推荐商品数组
    private var goodArr=[GoodEntity]()
    //保存商品详细信息
    private var goodEntity:GoodEntity?
    //商品数量默认等于1
    private var goodCount=1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="商品详情"
        storeAndGoodsId=storeAndGoodsId ?? 0
        setUpView()
        setUpNav()
        getGoodsDetail(goodsStuta:goodsStuta ?? 3)
    }
    //添加商品数量
    @IBAction func addCount(_ sender: UIButton) {
        goodCount+=1
        lblCount.text="\(goodCount)"
    }
    //减少商品数量
    @IBAction func reduceCount(_ sender: UIButton) {
        if goodCount > 1{
            goodCount-=1
            lblCount.text="\(goodCount)"
        }
    }
}

// MARK: - 页面设置
extension PromotionGoodDetailViewController:WaterFlowViewLayoutDelegate{
    //设置页面
    private func setUpView(){
        scrollView.backgroundColor=UIColor.viewBackgroundColor()
        //设置底部购物车操作
        btnAddCar.backgroundColor=UIColor.applicationMainColor()
        lblCount.layer.borderWidth=1
        lblCount.layer.borderColor=UIColor.borderColor().cgColor
        lblCount.text="\(goodCount)"
        lblCount.backgroundColor=UIColor.RGBFromHexColor(hexString: "f1f2f6")
        btnAddCount.setTitleColor(UIColor.color666(), for: UIControlState.normal)
        btnReduceCount.setTitleColor(UIColor.color666(), for: .normal)
        goodCountView.layer.borderWidth=1
        goodCountView.layer.borderColor=UIColor.borderColor().cgColor


        lblStock.textColor=UIColor.textColor()
        lblSales.textColor=UIColor.textColor()

        //加入收藏
        collectImg.isUserInteractionEnabled=true
        collectImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addCollect)))

        //加入购物车
        btnAddCar.addTarget(self, action:#selector(addCar), for: UIControlEvents.touchUpInside)

        //商品列表设置
        //初始化UICollectionViewFlowLayout.init对象
        let layout = WaterFlowViewLayout()
        layout.margin=2.5
        layout.delegate=self
        goodCollection.collectionViewLayout = layout
        goodCollection.isScrollEnabled=false
        goodCollection.delegate=self
        goodCollection.dataSource=self
        goodCollection.register(UINib(nibName: "GoodCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"goodCollectionViewCellId")
        goodCollection.backgroundColor=UIColor.viewBackgroundColor()
    }
    //设置导航栏
    private func setUpNav(){
        let searchItem=UIBarButtonItem(barButtonSystemItem: .search, target:self, action: #selector(self.pushSearchVC))
        let btn=UIButton(type:.custom)
        btn.frame=CGRect(x:0, y:0, width:25, height:25)
        btn.setBackgroundImage(UIImage(named:"add_car")?.reSizeImage(reSize: CGSize(width:25,height:25)), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(pushCar), for: UIControlEvents.touchUpInside)
        let carItem=UIBarButtonItem(customView:btn)
        self.navigationItem.rightBarButtonItems=[carItem,searchItem]
    }
    //更新页面
    func updateView(){
        if goodEntity != nil{
            goodImg.kf.setImage(with:URL.init(string:urlImg+(goodEntity!.goodsPic ?? "")), placeholder:UIImage.init(named:goodDefaultImg),options:[.transition(ImageTransition.fade(1))])
            //商品名称
            lblGoodName.text=goodEntity!.goodsName
            //商品价格
            if goodEntity!.storeGoodsPrice != nil{//如果商品价格不为空
                lblGoodPrice.text="￥\(goodEntity!.storeGoodsPrice!)"
            }
            //商品单位
            lblUnit.text=goodEntity!.goodsUnit
            //商品规格
            lblUcode.text=goodEntity!.goodUcode
            //商品品牌
            lblBrands.text=goodEntity!.brand
            //保质期
            if goodEntity!.goodsLift != nil{
                lblShelfLife.text="\(goodEntity!.goodsLift!)天"
            }
            //条形码
            lblBarcode.text=goodEntity!.goodsCode
            //商品销量
            goodEntity!.salesCount=goodEntity!.salesCount ?? 0
            lblSales.text="销量:\(goodEntity!.salesCount!)"
            //商品是否收藏
            goodEntity!.collectionStatu=goodEntity!.collectionStatu ?? false
            if goodEntity!.collectionStatu!{
                collectImg.image=UIImage(named:"y_collect")
            }else{
                collectImg.image=UIImage(named:"collect")
            }
            if goodsStuta == 3{//如果是促销
                lblStock.text="库存:\(goodEntity!.promotionStock ?? 0)"
                let dateFormatter=DateFormatter()
                dateFormatter.dateFormat="yyyy-MM-dd HH:mm:ss"
                let date=dateFormatter.date(from:goodEntity!.promotionEndTime ?? "")
                self.lblPromotionTime.text=dateFormatter.string(from:date ?? Date())+"结束"
                self.lblPromotionMsg.text=goodEntity!.promotionMsg
            }
            updateViewHeight()
        }
    }
    /// 更新布局高度
    func updateViewHeight(){
        let count=goodArr.count
        let rowCount=count%2==0 ? count/2 : count/2+1
        goodCollectionHeight.constant=(boundsWidth/2+82.5)*CGFloat(rowCount)
        //        一定要显式在主线程调用刷新 不然会有cell不显示情况stackoverflow上很多人说这是UICollectionView的一个bug  目前没有好的解决方案
        DispatchQueue.main.async(execute: {
            self.goodCollection.reloadData()
        })
    }
}
//发送网络请求
extension PromotionGoodDetailViewController{
    ///1普通商品 3促销商品
    private func getGoodsDetail(goodsStuta:Int){
        self.showSVProgressHUD(status:"正在加载...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:GoodApi.getGoodsDetail(memberId:MEMBERID, storeAndGoodsId:storeAndGoodsId!, bindstoreId:BINDSTOREID, goodsStuta:goodsStuta), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                for(_,value) in json["gg"]{//获取推荐商品信息
                    let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object:value.object)
                    self.goodArr.append(entity!)
                }
                //获取商品信息
                self.goodEntity=self.jsonMappingEntity(entity:GoodEntity.init(), object:json["goods"].object)
                //是否已经收藏
                self.goodEntity?.collectionStatu=json["collectionStatu"].bool
                self.goodEntity?.goodsCollectionId=json["goodsCollectionId"].int
                self.updateView()
                self.dismissHUD()
            }else{
                self.showSVProgressHUD(status:"商品已经不存在", type: HUD.error)
                self.navigationController?.popViewController(animated:true)
            }
            
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.navigationController?.popViewController(animated:true)
        }
    }
    //加入收藏
    @objc private func addCollect(){
        if self.goodEntity!.collectionStatu!{
            PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:GoodApi.removeCollection(memberId:MEMBERID, goodsCollectionId:self.goodEntity?.goodsCollectionId ?? 0), successClosure: { (json) in
                let success=json["success"].stringValue
                if success == "success"{
                    self.showSVProgressHUD(status:"已取消收藏", type: HUD.success)
                    self.collectImg.image=UIImage(named:"collect")
                    self.goodEntity!.collectionStatu=false
                }
            }, failClosure: { (error) in
                self.showSVProgressHUD(status:error!, type: HUD.error)
            })
        }else{
            PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:GoodApi.addCollection(memberId:MEMBERID, storeAndGoodsId:storeAndGoodsId!), successClosure: { (json) in
                let success=json["success"].stringValue
                self.goodEntity?.goodsCollectionId=json["goodsCollectionId"].intValue
                if success == "success"{
                    self.showSVProgressHUD(status:"收藏成功", type: HUD.success)
                    self.collectImg.image=UIImage(named:"y_collect")
                    self.goodEntity!.collectionStatu=true
                }else{
                    self.showSVProgressHUD(status:"收藏失败", type: HUD.error)
                }
            }) { (error) in
                self.showSVProgressHUD(status:error!, type: HUD.error)
            }
        }
    }
    //请求加入购物车
    private func requestAddCar(count:Int,storeAndGoodsId:Int,goodsStuta:Int){
        self.showSVProgressHUD(status:"正在加入...",type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.addCar(memberId:MEMBERID, storeAndGoodsId:storeAndGoodsId,goodsCount:count,goodsStuta:goodsStuta), successClosure: { (json) in
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
// MARK: goodCollection协议
extension PromotionGoodDetailViewController:UICollectionViewDelegate,UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell=goodCollection.dequeueReusableCell(withReuseIdentifier:"goodCollectionViewCellId", for:indexPath) as! GoodCollectionViewCell
        if goodArr.count > 0{
            let entity=goodArr[indexPath.row]
            cell.updateCell(entity:entity)
            cell.pushGoodDetailsVCClosure={
                self.pushGoodDetailsVC(entity:entity)
            }
            cell.goodAddCarClosure={
                self.requestAddCar(count:1, storeAndGoodsId:entity.storeAndGoodsId!, goodsStuta:1)
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
// MARK: - 点击事件
extension PromotionGoodDetailViewController{
    //加入购物车
    @objc private func addCar(){
        requestAddCar(count:goodCount,storeAndGoodsId:storeAndGoodsId!, goodsStuta:3)
    }
    /// 跳转到搜索页面
    @objc private func pushSearchVC(){
        let vc=SearchViewController()
        self.navigationController?.pushViewController(vc, animated:true)
    }
    //跳转到商品详情页面
    private func pushGoodDetailsVC(entity:GoodEntity){
        let vc=self.storyboardPushView(type: .index, storyboardId:"GoodDetailsVC") as! GoodDetailsViewController
        vc.storeAndGoodsId=entity.storeAndGoodsId
        self.navigationController?.pushViewController(vc, animated:true)
    }
    ///跳转到购物车
    @objc private func pushCar(){
        let vc=self.storyboardPushView(type:.shoppingCar, storyboardId:"ShoppingCarVC") as! ShoppingCarViewController
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
