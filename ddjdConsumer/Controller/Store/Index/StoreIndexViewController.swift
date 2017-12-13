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

    @IBOutlet weak var collection: UICollectionView!
    private let imgArr=["store_index_good","store_index_order","store_index_xstj","store_index_tj","store_index_cx","store_index_zhmx","store_index_lxkf","store_index_qt"]
    private let strArr=["商品管理","订单管理","销售统计","特价活动","限时促销","账户明细","联系客服","其他设置"]
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="店铺首页"
        setUpView()
    }
}
///设置页面
extension StoreIndexViewController{
    //设置导航栏颜色
    private func setUpNavColor(){
        self.navigationController?.navigationBar.barTintColor=UIColor.applicationMainColor()
        self.navigationController?.navigationBar.titleTextAttributes=NSDictionary(object:UIColor.white, forKey:NSAttributedStringKey.foregroundColor as NSCopying) as? [NSAttributedStringKey : Any]
        self.navigationController?.navigationBar.tintColor=UIColor.white
        //改掉导航栏黑线颜色
        self.navigationController?.navigationBar.shadowImage=UIImage.imageFromColor(UIColor.applicationMainColor())
    }
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
        if aliBindStatu == true{//如果微信或者支付宝都绑定了
            if indexPath.item == 1{
                let vc=PageStoreOrderListViewController()
                self.navigationController?.pushViewController(vc, animated:true)
            }else if indexPath.item == 7{
                let vc=self.storyboardPushView(type:.store, storyboardId:"OtherSettingsVC") as! OtherSettingsViewController
                self.navigationController?.pushViewController(vc, animated:true)
            }else{
                let vc=PageStoreGoodListViewController()
                self.navigationController?.pushViewController(vc, animated:true)
            }
        }else{
            let vc=self.storyboardPushView(type:.store, storyboardId:"BindWxAndAliVC") as! BindWxAndAliViewController
            self.navigationController?.pushViewController(vc, animated:true)
        }
    }
    
}
