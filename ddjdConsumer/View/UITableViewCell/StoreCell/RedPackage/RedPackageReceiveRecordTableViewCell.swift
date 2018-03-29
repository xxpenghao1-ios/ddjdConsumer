//
//  RedPackageReceiveRecordTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/27.
//  Copyright © 2018年 zltx. All rights reserved.
//

import UIKit
///红包领取记录
class RedPackageReceiveRecordTableViewCell: UITableViewCell {
    ///用户账号
    @IBOutlet weak var lblAcc: UILabel!
    ///红包领取时间
    @IBOutlet weak var lblTime: UILabel!
    ///红包领取金额
    @IBOutlet weak var lblMoney: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func updateCell(entity:ReceiveredPackeTrecordEntity){
        lblAcc.text=entity.account
        lblTime.text=entity.receiveTime
        lblMoney.text=entity.receiveMoney?.description
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
