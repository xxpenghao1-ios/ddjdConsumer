//
//  BalanceMoneyRecordTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/4.
//  Copyright © 2018年 zltx. All rights reserved.
//

import UIKit
///余额记录cell
class BalanceMoneyRecordTableViewCell: UITableViewCell {
    ///余额类型
    @IBOutlet weak var lblBalanceMoneyType: UILabel!
    ///余额日期
    @IBOutlet weak var lblTime: UILabel!
    ///余额
    @IBOutlet weak var lblBalanceMoney: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    func updateCell(entity:BalanceRecordEntity){
        lblTime.text=entity.memberBalanceRecordTime
        if entity.memberBalanceRecordStatu == 1{
            lblBalanceMoney.text="+\(entity.memberBalanceRecordMoney ?? 0)"
        }else if entity.memberBalanceRecordStatu == 2{
            lblBalanceMoney.text="-\(entity.memberBalanceRecordMoney ?? 0)"
        }
        if entity.memberBalanceRecordType == 1{
            lblBalanceMoneyType.text="余额充值"
        }else if entity.memberBalanceRecordType == 2{
            lblBalanceMoneyType.text="余额返还"
        }else if entity.memberBalanceRecordType == 3{
            lblBalanceMoneyType.text="订单扣除"
        }else if entity.memberBalanceRecordType == 4{
            lblBalanceMoneyType.text="提现扣除"
        }else{
            lblBalanceMoneyType.text="其他"
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
