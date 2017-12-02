//
//  StoreIndexCollectionViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/19.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
//店铺首页cell
class StoreIndexCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //更新cell
    func updateCell(imgStr:String,str:String){
        img.image=UIImage(named:imgStr)
        lblName.text=str
    }
}
