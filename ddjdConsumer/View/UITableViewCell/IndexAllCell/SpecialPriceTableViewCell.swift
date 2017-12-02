//
//  SpecialPriceTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/2.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
//特价cell
class SpecialPriceTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    //更新cell
    func updateCell(){
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
