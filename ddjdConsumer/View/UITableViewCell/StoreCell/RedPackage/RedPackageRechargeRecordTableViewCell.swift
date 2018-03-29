//
//  RedPackageRechargeRecordTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/27.
//  Copyright © 2018年 zltx. All rights reserved.
//

import UIKit

/// 红包充值记录
class RedPackageRechargeRecordTableViewCell: UITableViewCell {
    ///充值状态
    @IBOutlet weak var lblRechargeStatu: UILabel!
    ///时间
    @IBOutlet weak var lblTime: UILabel!
    ///充值金额
    @IBOutlet weak var lblMoney: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func updateCell(entity:StoreRedPackreChargeRecordEntity){
        lblRechargeStatu.text=entity.rechargeStatu==1 ? "等待付款":"充值成功"
        lblTime.text=entity.rechargeTime
        lblMoney.text="+"+(entity.backRechargeMoney ?? 0).description
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
