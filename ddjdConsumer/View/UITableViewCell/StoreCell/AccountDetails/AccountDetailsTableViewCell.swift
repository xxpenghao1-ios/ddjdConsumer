//
//  AccountDetailsTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/25.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit

//账户明细cell
class AccountDetailsTableViewCell: UITableViewCell {
    ///时间
    @IBOutlet weak var lblDate: UILabel!
    ///支付方式
    @IBOutlet weak var lblPayMode: UILabel!
    ///金额
    @IBOutlet weak var lblPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCell(entity:TransferAccountSrecordEntity){
        lblDate.text="到账时间:"+(entity.transferAccountsRecordPayDate ?? "")
        lblPayMode.text=entity.transferAccountsRecordType==1 ? "微信到账":"支付宝到账"
        entity.transferAccountsRecordAmount=entity.transferAccountsRecordAmount ?? 0
        lblPrice.text="+"+PriceComputationsUtil.decimalNumberWithString(multiplierValue:entity.transferAccountsRecordAmount!.description, multiplicandValue:100.description, type:ComputationsType.division, position:2)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
