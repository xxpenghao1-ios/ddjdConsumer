//
//  GoodClassifyTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/12.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
//1级分类
class GoodClassifyTableViewCell: UITableViewCell {
    //分类名称
    @IBOutlet weak var lblName: UILabel!
    //选中图片
    @IBOutlet weak var selectedImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedImg.isHidden=true
        self.selectionStyle = .none
        // Initialization code
    }
    //更新cell
    func updateCell(entity:GoodscategoryEntity){
        lblName.text=entity.goodsCategoryName
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected{
            self.lblName.textColor=UIColor.applicationMainColor()
            selectedImg.isHidden=false
            self.contentView.backgroundColor=UIColor.white
        }else{
            self.lblName.textColor=UIColor.color333()
            selectedImg.isHidden=true
            self.contentView.backgroundColor=UIColor.viewBackgroundColor()
        }

        // Configure the view for the selected state
    }
    
}
