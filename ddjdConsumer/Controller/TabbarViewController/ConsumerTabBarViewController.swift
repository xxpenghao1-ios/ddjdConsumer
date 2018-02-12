//
//  ConsumerTabBarViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/12.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import UIKit
/// 消费者tabbar
class ConsumerTabBarViewController:UITabBarController{
    var shoppingCarViewController=storyboardViewController(type:.shoppingCar, withIdentifier:"ShoppingCarId") as! UINavigationController
    override func viewDidLoad() {
        super.viewDidLoad()
        //首页
        let indexViewController = storyboardViewController(type:.index, withIdentifier:"IndexId") as! UINavigationController
        addChildViewController(childController:indexViewController, title:"首页", imageName:"index")
        //点单VIP
        let VIPViewController=storyboardViewController(type:.index, withIdentifier:"VIPId") as! UINavigationController
        addChildViewController(childController:VIPViewController, title:"点单VIP", imageName:"vip")
        //购物车
        addChildViewController(childController:shoppingCarViewController, title:"购物车", imageName:"car")
        //我的
        let myViewController=storyboardViewController(type:.my, withIdentifier:"MyId") as! UINavigationController
        addChildViewController(childController:myViewController, title:"我的", imageName:"my")
        self.tabBar.backgroundColor=UIColor.clear
        let viewImg=UIView(frame:CGRect(x:0, y:0, width:boundsWidth, height:49))
        viewImg.backgroundColor=UIColor.white
        self.tabBar.insertSubview(viewImg, at:0)
        self.tabBar.isOpaque=true
        self.tabBar.tintColor=UIColor.applicationMainColor()
        //接收通知 更新购物车角标
        NotificationCenter.default.addObserver(self, selector:#selector(updateBadgeValue), name:updateCarBadgeValue, object:nil)
        updateBadgeValue()
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    ///设置购物车角标
    @objc private func updateBadgeValue(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.queryShoppingCarGoodsSumCount(memberId:MEMBERID, queryStatu:1), successClosure: { (json) in
            let count=json["goodsCount"].intValue
            if count > 0{
                self.shoppingCarViewController.tabBarItem.badgeValue="\(count)"
            }else{
                self.shoppingCarViewController.tabBarItem.badgeValue=nil
            }
        }) { (error) in
            
        }
    }
    /**
     初始化子控制器
     
     - parameter childController: 需要初始化的子控制器
     - parameter title:           子控制器的标题
     - parameter imageName:       子控制器的图片
     */
    private func addChildViewController(childController:UINavigationController, title:String?, imageName:String) {
        
        // 1.设置子控制器对应的数据
        childController.tabBarItem.image = UIImage(named:imageName+"_default")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        childController.tabBarItem.selectedImage = UIImage(named:imageName+"_selected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        // 2.设置底部工具栏标题
        childController.tabBarItem.title=title
        // 4.将子控制器添加到当前控制器上
        addChildViewController(childController)
    }

}
