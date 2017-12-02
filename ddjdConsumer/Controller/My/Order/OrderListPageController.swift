//
//  OrderListPageController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/27.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import WMPageController
//通知名称常量
let notificationOrderListrefresh=NSNotification.Name(rawValue:"orderListrefresh")
///订单分页页面
class OrderListPageController:WMPageController{
    //1. 待付款 2-待发货，3 已发货，4-已经完成
    var orderStatus:Int?
    let titleArr=["全部","待付款","待发货","待收货","已完成"]
    override func viewDidLoad() {
        setUpMenuView()
        super.viewDidLoad()
        self.title="我的订单"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //设置显示几个页面
    override func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return 5
    }
    //设置显示标题数量
    override func numbersOfTitles(in menu: WMMenuView!) -> Int {
        return 5
    }
    //显示对应的标题
    override func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        return titleArr[index]
    }
    //显示对应的页面
    override func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        let vc=storyboardViewController(type:.my, withIdentifier:"OrderListVC") as! OrderListViewController
        vc.orderStatus=index
        vc.pageSelectIndexClosure={ (i) in
            self.selectIndex=Int32(i)
            //发送通知 所有页面更新数据
            NotificationCenter.default.post(name:notificationOrderListrefresh, object: self,userInfo:nil)
        }
        return vc
    }
    //设置menuView frame
    override func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        menuView.backgroundColor=UIColor.white
        return CGRect(x:0, y:0, width:boundsWidth,height:44)
    }
    //设置contentView frame
    override func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        return CGRect(x:0, y:44, width:boundsWidth,height:boundsHeight-44-navHeight-bottomSafetyDistanceHeight)
    }
    
}
// MARK: - 设置页面
extension OrderListPageController{
    //设置分页控件
    private  func setUpMenuView(){
        self.menuViewStyle = .line
        self.titleColorSelected = .applicationMainColor()
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.menuItemWidth=60
        self.progressHeight=2
        self.titleColorNormal = UIColor.color333()
        if orderStatus != nil{
            self.selectIndex=Int32(orderStatus!)
        }
    }
}

