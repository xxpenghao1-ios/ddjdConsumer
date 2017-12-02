//
//  GoodSpecialPromotionsDetailsViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/23.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation

/// 商品详情页面
class  GoodSpecialPromotionsDetailsViewController:BaseViewController{
    /// 接收传入的商品信息
    var entity:GoodEntity?
    //可滑动容器
    @IBOutlet weak var scrollView: UIScrollView!
    ///幻灯片view
    @IBOutlet weak var slideView: UIView!
    /// 幻灯片
    fileprivate var cycleScrollView:WRCycleScrollView!

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
    //商品原价
    @IBOutlet weak var lblOriginalPrice: UILabel!
    //特价标识图片
    @IBOutlet weak var specialPriceImg: UIImageView!
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
    
    //商品列表(为你推荐)
    @IBOutlet weak var goodCollection: UICollectionView!
    //商品列表高度
    @IBOutlet weak var goodCollectionHeight: NSLayoutConstraint!
    
    //商品数组
    private var goodArr=[GoodEntity]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="商品详情"
        setUpView()
        setUpNav()
    }
    //添加商品数量
    @IBAction func addCount(_ sender: UIButton) {
    }
    //减少商品数量
    @IBAction func reduceCount(_ sender: UIButton) {
    }
    
}

// MARK: - 页面设置
extension GoodSpecialPromotionsDetailsViewController:WaterFlowViewLayoutDelegate{
    //设置页面
    private func setUpView(){
        scrollView.backgroundColor=UIColor.viewBackgroundColor()
        //设置底部购物车操作
        btnAddCar.backgroundColor=UIColor.applicationMainColor()
        lblCount.layer.borderWidth=1
        lblCount.layer.borderColor=UIColor.borderColor().cgColor
        lblCount.backgroundColor=UIColor.RGBFromHexColor(hexString: "f1f2f6")
        btnAddCount.setTitleColor(UIColor.color666(), for: UIControlState.normal)
        btnReduceCount.setTitleColor(UIColor.color666(), for: .normal)
        goodCountView.layer.borderWidth=1
        goodCountView.layer.borderColor=UIColor.borderColor().cgColor
        //设置幻灯片
        cycleScrollView=WRCycleScrollView(frame:CGRect(x:0, y:0, width:boundsWidth, height:348))
        cycleScrollView.pageControlAliment = .CenterBottom
        cycleScrollView.currentDotColor = .applicationMainColor()
        cycleScrollView.otherDotColor = .white
        cycleScrollView.autoScrollInterval=4
        cycleScrollView.localImgArray=["slide_default"]
        slideView.addSubview(cycleScrollView)
        
        //商品参数设置
        let str = NSMutableAttributedString(string:"￥10.0")
        let range = NSRange(location: 0, length: str.length)
        let number = NSNumber(value:NSUnderlineStyle.styleSingle.rawValue)//此处需要转换为NSNumber 不然不对,rawValue转换为integer
        str.addAttribute(NSAttributedStringKey.strikethroughStyle, value: number, range: range)
        str.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.textColor(), range: range)
        lblOriginalPrice.attributedText=str
        
        lblStock.textColor=UIColor.textColor()
        lblSales.textColor=UIColor.textColor()
        
        //商品列表设置
        //初始化UICollectionViewFlowLayout.init对象
        let layout = WaterFlowViewLayout()
        layout.margin=2.5
        layout.delegate=self
        goodCollection.collectionViewLayout = layout
        goodCollection.isScrollEnabled=false
        goodCollection.register(UINib(nibName: "GoodCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"goodCollectionViewCellId")
        goodCollection.backgroundColor=UIColor.viewBackgroundColor()
        //更新布局高度
        updateViewHeight()
    }
    //设置导航栏
    private func setUpNav(){
        let searchItem=UIBarButtonItem(barButtonSystemItem: .search, target:self, action: #selector(self.pushSearchVC))
        let btn=UIButton(type:.custom)
        btn.frame=CGRect(x:0, y:0, width:25, height:25)
        btn.setBackgroundImage(UIImage(named:"add_car")?.reSizeImage(reSize: CGSize(width:25,height:25)), for: UIControlState.normal)
        let carItem=UIBarButtonItem(customView:btn)
        self.navigationItem.rightBarButtonItems=[carItem,searchItem]
    }
    /// 更新布局高度
    func updateViewHeight(){
        let count=4
        let rowCount=count%2==0 ? count/2 : count/2+1
        goodCollectionHeight.constant=(boundsWidth/2+82.5)*CGFloat(rowCount)
    }
}
// MARK: goodCollection协议
extension GoodSpecialPromotionsDetailsViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell=goodCollection.dequeueReusableCell(withReuseIdentifier:"goodCollectionViewCellId", for:indexPath) as! GoodCollectionViewCell
            //            if self.advertisingURLArr.count > 0{
            //                let entity=self.advertisingURLArr[indexPath.row]
            //                cell.updateCell(entity:entity)
            //
            //            }
            return cell
        
        
    }
    func waterFlowViewLayout(waterFlowViewLayout: WaterFlowViewLayout, heightForWidth: CGFloat, atIndextPath: IndexPath) -> CGFloat {
        return boundsWidth/2+80
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
// MARK: - 跳转点击事件
extension GoodSpecialPromotionsDetailsViewController{
    /// 跳转到搜索页面
    @objc func pushSearchVC(){
        let vc=SearchViewController()
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
