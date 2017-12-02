//
//  UILabel.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/27.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
extension UILabel{
    ///设置label文字
    class func setAttributedText(str:String,textColor:UIColor,font:Int,range:NSRange) -> NSMutableAttributedString{
        let strAttributed=NSMutableAttributedString.init(string:str)
        let normalAttributes=[NSAttributedStringKey.foregroundColor:textColor,NSAttributedStringKey.font:UIFont.systemFont(ofSize:CGFloat(font))]
        strAttributed.addAttributes(normalAttributes, range:range)
        return strAttributed
    }
}
