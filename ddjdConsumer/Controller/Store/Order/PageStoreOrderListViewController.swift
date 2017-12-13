//
//  PageStoreOrderListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/13.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import WMPageController
///店铺订单
class PageStoreOrderListViewController:WMPageController{
    private let titleArr=["待发货","已发货","已完成"]
    override func viewDidLoad() {
        setUpMenuView()
        super.viewDidLoad()
        self.title="我的订单"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
    }
    //设置显示几个页面
    override func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return titleArr.count
    }
    //设置显示标题数量
    override func numbersOfTitles(in menu: WMMenuView!) -> Int {
        return titleArr.count
    }
    //显示对应的标题
    override func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        return titleArr[index]
    }
    //显示对应的页面
    override func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        let vc=storyboardViewController(type: .storeOrder, withIdentifier:"StoreOrderListVC") as! StoreOrderListViewController
        vc.pageSelectIndexClosure={ (index) in
            self.selectIndex=Int32(index)
            NotificationCenter.default.post(name:notificationStoreOrderListrefresh, object:nil)
        }
        vc.orderStatus=index+2
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
extension PageStoreOrderListViewController{
    //设置分页控件
    private  func setUpMenuView(){
        self.menuViewStyle = .line
        self.titleColorSelected = UIColor.applicationMainColor()
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.menuItemWidth=60
        self.progressHeight=2
        self.titleColorNormal = UIColor.color333()
    }
}
