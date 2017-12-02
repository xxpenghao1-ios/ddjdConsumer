//
//  SpecialPriceViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/2.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
//特价商品
class SpecialPriceViewController:BaseViewController{
    //table
    @IBOutlet weak var table: UITableView!
    //返回顶部
    @IBOutlet weak var returnTopImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
}
// MARK: - 设置页面
extension SpecialPriceViewController{
    //设置页面
    private func setUpView(){
        //去掉底部多余cell
        table.tableFooterView=UIView(frame:CGRect.zero)
        table.dataSource=self
        table.delegate=self
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        table.backgroundColor=UIColor.viewBackgroundColor()
        //返回顶部
        returnTopImg.isUserInteractionEnabled=true
        returnTopImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(returnTop)))
        returnTopImg.isHidden=true
    }
}
// MARK: - 滑动协议
extension SpecialPriceViewController{
    //监听滑动事件
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > boundsHeight/2{//滑动屏幕高度一半距离显示返回顶部按钮
            returnTopImg.isHidden=false
        }else{
            returnTopImg.isHidden=true
        }
    }
}
// MARK: - table协议
extension SpecialPriceViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"SpecialPriceTableViewCellId") as? SpecialPriceTableViewCell
        if cell == nil{
            cell=Bundle.main.loadNibNamed("SpecialPriceTableViewCell", owner:self, options: nil)?.last as? SpecialPriceTableViewCell
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
}
//// MARK: - table为空提示视图
//extension SpecialPriceViewController:DZNEmptyDataSetDelegate,DZNEmptyDataSetSource{
//    //图片
//    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
//        return UIImage(named: "nil_img")
//    }
//    //文字提示
//    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        let text="还木有特价商品"
//        let attributes=[NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.darkGray]
//        return NSAttributedString(string:text, attributes:attributes)
//    }
//    //设置文字和图片间距
//    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
//        return 10
//    }
//    //设置垂直偏移量
//    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
//        return 0
//    }
//    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
//        return true
//    }
//    
//}

// MARK: - 页面逻辑
extension SpecialPriceViewController{
    //返回顶部
    @objc private func returnTop(){
        let at=IndexPath(row:0, section:0)
        self.table.scrollToRow(at: at, at: UITableViewScrollPosition.bottom, animated: true)
    }
}
// MARK: - 跳转页面
extension SpecialPriceViewController{
    //跳转到购物车
    @objc private func pushCarVC(){
        let vc=self.storyboardPushView(type: .shoppingCar, storyboardId:"ShoppingCarVC") as! ShoppingCarViewController
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
