//
//  HotGoodListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/22.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///热门推荐商品list
class HotGoodListViewController:BaseViewController{
    ///table
    @IBOutlet weak var table: UITableView!
    private var arr=[GoodEntity]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="热门推荐商品管理"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
    }
}
extension HotGoodListViewController{
    
}
