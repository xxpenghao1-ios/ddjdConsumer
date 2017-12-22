//
//  OrderStatisticsTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/18.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
///订单统计
class OrderStatisticsTableViewCell: UITableViewCell {
    ///日期
    @IBOutlet weak var lblDate: UILabel!
    ///订单收入
    @IBOutlet weak var lblOrderPrice: UILabel!
    ///订单数量
    @IBOutlet weak var lblOrderCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }
    func updateCell(entity:OrderStatisticsEntity){
        lblDate.text=entity.dateStr
        lblOrderPrice.text=entity.orderPrice?.description
        lblOrderCount.text=entity.orderCount?.description
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
