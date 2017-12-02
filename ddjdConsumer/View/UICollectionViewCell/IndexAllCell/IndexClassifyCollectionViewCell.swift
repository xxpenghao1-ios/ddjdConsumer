//
//  IndexClassifyCollectionViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/12.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
/// 首页分类
class IndexClassifyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var classifyImg: UIImageView!
    
    @IBOutlet weak var imgWidth: NSLayoutConstraint!
    
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblName.font=UIFont.systemFont(ofSize:14)
        lblName.textColor=UIColor.color666()
        imgWidth.constant=boundsWidth/4-40
        imgHeight.constant=boundsWidth/4-40
    }
    ///更新cell
    func updateCell(name:String,imgStr:String){
        lblName.text=name
        classifyImg.image=UIImage(named:imgStr)
    }
}
