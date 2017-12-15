//
//  OrderStatisticsTextViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/15.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///订单文字统计
class OrderStatisticsTextViewController:BaseViewController{
    ///table topview
    @IBOutlet weak var orderTopView: UIView!
    ///本月订单笔数
    @IBOutlet weak var lblOrderCount: UILabel!
    ///本月订单总金额
    @IBOutlet weak var lblMonthOrderPrice: UILabel!
    ///历史总营业额
    @IBOutlet weak var lblOrderSumPrice: UILabel!
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title=""
    }
}
