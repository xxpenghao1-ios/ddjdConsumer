//
//  PageStoreGoodListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/8.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import WMPageController
class PageStoreGoodListViewController:WMPageController {
    ///默认选中页面 1已上架 2已下架
    var goodsFlag:Int?
    private let titleArr=["已上架","已下架"]
    override func viewDidLoad() {
        setUpMenuView()
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        self.navigationItem.rightBarButtonItem=UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target:self, action:#selector(addGood))
    }
    ///添加商品
    @objc private func addGood(){
        let vc=storyboardViewController(type: .storeGood, withIdentifier:"VerifyThatTheBarcodeExistsVC") as! VerifyThatTheBarcodeExistsViewController
        self.navigationController?.pushViewController(vc, animated:true)
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
        let vc=storyboardViewController(type: .storeGood, withIdentifier:"StoreGoodListVC") as! StoreGoodListViewController
        vc.goodsFlag=index+1
        return vc
    }
    //设置menuView frame
    override func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        menuView.backgroundColor=UIColor.clear
        return CGRect(x:0, y:0, width:boundsWidth,height:44)
    }
    //设置contentView frame
    override func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        return CGRect(x:0, y:0, width:boundsWidth,height:boundsHeight-navHeight-bottomSafetyDistanceHeight)
    }
}
// MARK: - 设置页面
extension PageStoreGoodListViewController{
    //设置分页控件
    private  func setUpMenuView(){
        self.menuViewStyle = .line
        self.titleColorSelected = .white
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.menuItemWidth=60
        self.progressHeight=2
        self.showOnNavigationBar=true
        self.titleColorNormal = UIColor.black
        if goodsFlag != nil{
            self.selectIndex=Int32(goodsFlag!-1)
        }
    }
}
