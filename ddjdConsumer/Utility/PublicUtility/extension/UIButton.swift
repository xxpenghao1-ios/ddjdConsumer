//
//  UIButton.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/10.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
// MARK: - 扩展UIButton
private var key:String=""
extension UIButton{
    var paramDic:NSDictionary?{
        set{
            objc_setAssociatedObject(self,&key,newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get{
            return objc_getAssociatedObject(self,&key) as? NSDictionary
        }
    }
    /// 实现按钮半透明+不可点效果
    func disable(){
        self.isEnabled = false
        self.alpha = 0.5
        
    }
    /// 正常按钮+可点击效果
    func enable(){
        self.isEnabled = true
        self.alpha = 1
    }
    
}
