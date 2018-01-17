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
    ///订单数量提示
    @IBOutlet weak var btnBadge: UIButton!

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnBadge.isHidden=true
    }
    //更新cell
    func updateCell(imgStr:String,str:String,count:Int?){
        img.image=UIImage(named:imgStr)
        lblName.text=str
        if count != nil{
            btnBadge.badgeValue=(count! == 0 ? "" : count!.description)
            btnBadge.isHidden=false

        }else{
            btnBadge.isHidden=true
            btnBadge.badgeValue=""
        }
    }
}
