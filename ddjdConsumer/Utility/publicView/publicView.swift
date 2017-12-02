//
//  publicView.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/1.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
/// 文本
extension UILabel{
    //创建文本
    class func buildLabel(textColor:UIColor,font:CGFloat,textAlignment:NSTextAlignment) -> UILabel{
        let lbl=UILabel()
        lbl.textColor=textColor
        lbl.font=UIFont.systemFont(ofSize:font)
        lbl.textAlignment=textAlignment
        return lbl
    }
}
///创建输入框
extension UITextField{
    class func buildTxt(font:CGFloat,placeholder:String,tintColor:UIColor,keyboardType:UIKeyboardType) -> UITextField{
        let txt=UITextField()
        txt.font=UIFont.systemFont(ofSize: font)
        txt.attributedPlaceholder=NSAttributedString(string:placeholder, attributes: [NSAttributedStringKey.foregroundColor:UIColor.RGBFromHexColor(hexString: "#999999")])
        txt.backgroundColor=UIColor.white
        txt.clearButtonMode=UITextFieldViewMode.whileEditing
        txt.tintColor=tintColor
        txt.keyboardType=keyboardType
    return txt
    }
}

/// 按钮控件属性
public enum ButtonType {
    case button
    case cornerRadiusButton
}

/// 按钮
extension UIButton {
    
    class func button(type:ButtonType,text:String,textColor:UIColor,font:CGFloat,backgroundColor:UIColor,cornerRadius:CGFloat?) -> UIButton{
        switch type {
        case .button:
            return buildButton(text: text, textColor: textColor, font: font, backgroundColor:backgroundColor)
        case .cornerRadiusButton:
            return buildCornerRadiusButton(text: text,textColor:textColor,font:font,backgroundColor:backgroundColor,cornerRadius:cornerRadius!)
        }
    }
    
    private class func buildCornerRadiusButton(text:String,textColor:UIColor,font:CGFloat,backgroundColor:UIColor,cornerRadius:CGFloat) -> UIButton{
        let btn=UIButton()
        btn.setTitle(text, for: UIControlState.normal)
        btn.setTitleColor(textColor,for: UIControlState.normal)
        btn.titleLabel!.font=UIFont.systemFont(ofSize: font)
        btn.backgroundColor=backgroundColor
        btn.layer.cornerRadius=cornerRadius
        return btn
    }
     private class func buildButton(text:String,textColor:UIColor,font:CGFloat,backgroundColor:UIColor) -> UIButton{
        let btn=UIButton()
        btn.setTitle(text, for: UIControlState.normal)
        btn.setTitleColor(textColor,for: UIControlState.normal)
        btn.titleLabel!.font=UIFont.systemFont(ofSize: font)
        btn.backgroundColor=backgroundColor
        return btn
    }
    
    
}
