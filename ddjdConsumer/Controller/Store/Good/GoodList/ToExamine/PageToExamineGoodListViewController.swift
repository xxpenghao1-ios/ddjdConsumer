//
//  PageToExamineGoodListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/17.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import WMPageController
class PageToExamineGoodListViewController:WMPageController{
    var examineGoodsFlag:Int? //1. 审核中 2. 审核失败 3 审核成功
    private let titleArr=["审核中","审核失败","审核成功"]
    override func viewDidLoad() {
        setUpMenuView()
        super.viewDidLoad()
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
        let vc=storyboardViewController(type: .storeGood, withIdentifier:"ToExamineGoodListVC") as! ToExamineGoodListViewController
        vc.examineGoodsFlag=index+1
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
extension PageToExamineGoodListViewController{
    //设置分页控件
    private  func setUpMenuView(){
        self.menuViewStyle = .line
        self.titleColorSelected = UIColor.applicationMainColor()
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.menuItemWidth=80
        self.progressHeight=2
        self.titleColorNormal = UIColor.color333()
        if examineGoodsFlag != nil{
            self.selectIndex=Int32(examineGoodsFlag!-1)
        }
    }
}

