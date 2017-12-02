//
//  SpecialPriceListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/2.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import WMPageController
///特价商品父页面(控制分页)
class SpecialPriceListViewController:WMPageController{
//    private var menu:WMPageController!
    let titleArr=["销量","价格"]
    override func viewDidLoad() {
        setUpMenuView()
        super.viewDidLoad()
        self.title="特价专区"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpNav()
    }
    //设置显示几个页面
    override func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return 2
    }
    //设置显示标题数量
    override func numbersOfTitles(in menu: WMMenuView!) -> Int {
        return 2
    }
    //显示对应的标题
    override func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        return titleArr[index]
    }
    //显示对应的页面
    override func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        return storyboardViewController(type:.index, withIdentifier:"SpecialPriceVC") as! SpecialPriceViewController
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
extension SpecialPriceListViewController{
    //设置导航栏
    private func setUpNav(){
    self.navigationItem.rightBarButtonItem=UIBarButtonItem(image:UIImage(named:"add_car")?.reSizeImage(reSize:CGSize(width:25,height:25)), style: UIBarButtonItemStyle.done, target:self, action:#selector(pushCarVC))
    }
    //设置分页控件
    private  func setUpMenuView(){
        self.menuViewStyle = .line
        self.titleColorSelected = .applicationMainColor()
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.menuItemWidth=50
        self.progressHeight=2
        self.titleColorNormal = UIColor.color333()
    }
}
// MARK: - 跳转页面
extension SpecialPriceListViewController{
    //跳转到购物车
    @objc private func pushCarVC(){
        let vc=storyboardViewController(type:.shoppingCar, withIdentifier:"ShoppingCarVC") as! ShoppingCarViewController
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
