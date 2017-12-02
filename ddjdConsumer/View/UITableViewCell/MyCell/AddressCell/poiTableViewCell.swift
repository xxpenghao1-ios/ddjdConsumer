//
//  poiTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/22.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
///地图位置信息cell
class poiTableViewCell: UITableViewCell {
    //地址名称
    @IBOutlet weak var lblName: UILabel!
    //详细地址
    @IBOutlet weak var lblAddress: UILabel!
    //距离
    @IBOutlet weak var lblDistance: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func updateCell(entity:PoiEntity,distance:String?){
        lblAddress.text=entity.address
        lblDistance.text=distance
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
