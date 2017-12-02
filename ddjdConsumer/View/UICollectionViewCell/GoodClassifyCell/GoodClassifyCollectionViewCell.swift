//
//  GoodClassifyCollectionViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/12.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
import Kingfisher
//商品3级分类cell
class GoodClassifyCollectionViewCell: UICollectionViewCell {
    //分类图片
    @IBOutlet weak var img: UIImageView!
    //分类名称
    @IBOutlet weak var lblName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        lblName.textColor=UIColor.color666()
        // Initialization code
        
    }
    //更新cell
    func updateCell(entity:GoodscategoryEntity){
        entity.goodsCategoryIco=entity.goodsCategoryIco ?? ""
        img.kf.setImage(with:URL.init(string:urlImg+entity.goodsCategoryIco!), placeholder:UIImage.init(named:goodDefaultImg),options:[.transition(ImageTransition.fade(1))])
        lblName.text=entity.goodsCategoryName
    }
}
