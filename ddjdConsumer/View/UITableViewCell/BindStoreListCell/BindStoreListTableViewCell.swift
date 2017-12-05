//
//  BindStoreListTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/4.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit

class BindStoreListTableViewCell: UITableViewCell {

    @IBOutlet weak var lblStoreName: UILabel!
    
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var lblDistance: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func updateCell(entity:StoreEntity){
        lblStoreName.text=entity.storeName
        lblAddress.text=entity.address
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
