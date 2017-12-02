//
//  SearchCollectionViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/1.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import SnapKit
/// 搜索cell
class SearchCollectionViewCell:UICollectionViewCell{
    private var lblName:UILabel!
    override init(frame: CGRect) {
        super.init(frame:frame)
        lblName=UILabel.buildLabel(textColor: UIColor.black,font:14, textAlignment: NSTextAlignment.center)
        self.contentView.addSubview(lblName)
        self.contentView.layer.cornerRadius=5
        self.contentView.backgroundColor=UIColor.RGBFromHexColor(hexString:"e6e6e6")
        lblName.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left)
            make.top.equalTo(7.5)
            make.height.equalTo(20)
            make.right.equalTo(self.contentView.snp.right)
        }
    }
    /**
     更新cell
     
     - parameter str:
     */
    func updateCell(str:String){
        if str == "清除历史"{
            self.contentView.backgroundColor=UIColor.applicationMainColor()
            lblName.textColor=UIColor.white
        }else{
            self.contentView.backgroundColor=UIColor.RGBFromHexColor(hexString:"e6e6e6")
            lblName.textColor=UIColor.black
        }
        lblName.text=str
    }
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes=super.preferredLayoutAttributesFitting(layoutAttributes)
        let str=lblName.text!
        if str == ""{
            frame.size.height=35
            frame.size.width=1
            attributes.frame=frame
        }else{
            let size=str.textSizeWithFont(font:lblName.font, constrainedToSize:CGSize(width:500, height:35))
            frame.size.height=35
            frame.size.width=size.width+30
            attributes.frame=frame
        }
        return attributes
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
