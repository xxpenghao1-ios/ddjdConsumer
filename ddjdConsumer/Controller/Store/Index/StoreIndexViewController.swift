//
//  StoreIndexViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/19.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
//店铺首页
class StoreIndexViewController:BaseViewController{
    ///总营业额
    @IBOutlet weak var lblSumPrice: UILabel!
    ///日营业额
    @IBOutlet weak var lblTodayPirce: UILabel!
    
    @IBOutlet weak var collection: UICollectionView!
    private let imgArr=["store_index_good","store_index_order","store_index_xstj","store_index_tj","store_index_cx","store_index_zhmx","store_index_lxkf","store_index_qt"]
    private let strArr=["商品管理","订单管理","销售统计","热门推荐","限时促销","账户明细","联系客服","其他设置"]
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavColor()
        queryStoreTurnover()
        queryStoreBindWxOrAliStatu()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="门店首页"
        setUpView()
    }
}
///设置页面
extension StoreIndexViewController{
    private func setUpView(){
        collection.layer.cornerRadius=10
        //初始化UICollectionViewFlowLayout.init对象
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize=CGSize(width:boundsWidth/3, height:345/3)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0;//每个相邻layout的上下
        flowLayout.minimumInteritemSpacing = 0;//每个相邻layout的左右
        collection.collectionViewLayout = flowLayout
        collection.register(UINib(nibName: "StoreIndexCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"StoreIndexCollectionViewCellId")
    }
}
/// collection协议
extension StoreIndexViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collection.dequeueReusableCell(withReuseIdentifier:"StoreIndexCollectionViewCellId", for:indexPath) as! StoreIndexCollectionViewCell
        cell.updateCell(imgStr:imgArr[indexPath.item], str:strArr[indexPath.item])
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wxBindStatu=userDefaults.object(forKey:"wxBindStatu") as? Bool
        let aliBindStatu=userDefaults.object(forKey:"aliBindStatu") as? Bool
        if aliBindStatu == true && wxBindStatu == true{//如果微信或者支付宝都绑定了
            if indexPath.item == 0{//商品管理
                let vc=PageStoreGoodListViewController()
                self.navigationController?.pushViewController(vc, animated:true)
            }else if indexPath.item == 1{//订单
                let vc=PageStoreOrderListViewController()
                self.navigationController?.pushViewController(vc, animated:true)
            }else if indexPath.item == 3{//热门推荐商品
                let vc=self.storyboardPushView(type:.storeGood, storyboardId:"HotGoodListVC") as! HotGoodListViewController
                self.navigationController?.pushViewController(vc, animated:true)
            }else if indexPath.item == 4{//限时促销
                let vc=self.storyboardPushView(type:.storeGood, storyboardId:"StorePromotionGoodListVC") as! StorePromotionGoodListViewController
                self.navigationController?.pushViewController(vc, animated:true)
            }else if indexPath.item == 5{//账户明细
                let vc=self.storyboardPushView(type:.store, storyboardId:"AccountDetailsVC") as! AccountDetailsViewController
                self.navigationController?.pushViewController(vc, animated:true)
            }else if indexPath.item == 6{//联系客服
                UIApplication.shared.openURL(Foundation.URL(string :"tel://4008356878")!)
            }else if indexPath.item == 7{//其他设置
                let vc=self.storyboardPushView(type:.store, storyboardId:"OtherSettingsVC") as! OtherSettingsViewController
                self.navigationController?.pushViewController(vc, animated:true)
            }else{
                let vc=self.storyboardPushView(type:.storeOrder, storyboardId:"OrderStatisticsTextVC") as! OrderStatisticsTextViewController
                vc.orderSumPrice=lblSumPrice.text
                self.navigationController?.pushViewController(vc, animated:true)
            }
        }else{
            UIAlertController.showAlertYes(self, title:"重要提示", message:"您的微信或者支付宝还没有绑定店铺", okButtonTitle:"去绑定", okHandler: { (action) in
                let vc=self.storyboardPushView(type:.store, storyboardId:"BindWxAndAliVC") as! BindWxAndAliViewController
                self.navigationController?.pushViewController(vc, animated:true)
            })
        }
    }
}
///网络请求
extension StoreIndexViewController{
    ///年月日的总金额和店铺总金额
    private func queryStoreTurnover(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreInfoApi.queryStoreTurnover(storeId:STOREID), successClosure: { (json) in
            print(json)
            self.lblSumPrice.text=json["sumPrice"].double?.description
            self.lblTodayPirce.text=json["today"].double?.description
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    //查询店铺是否绑定微信或者支付宝 ，并返回相应的基本信息
    private func queryStoreBindWxOrAliStatu(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreBindWxOrAlipayApi.queryStoreBindWxOrAliStatu(storeId:STOREID), successClosure: { (json) in
            userDefaults.set(json["wxBindStatu"].bool, forKey:"wxBindStatu")
            userDefaults.set(json["aliBindStatu"].bool, forKey:"aliBindStatu")
            userDefaults.synchronize()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
