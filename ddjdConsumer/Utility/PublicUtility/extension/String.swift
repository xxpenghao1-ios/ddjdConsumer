//
//  String.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/1.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
// MARK: - 扩展字符串
extension String {
    /**
     //根据文字多少大小计算UILabel的宽高度
     
     - parameter font: UILabel大小
     - parameter size: UILabel的最大宽高
     
     - returns: 当前文本所占的宽高
     */
    func textSizeWithFont(font: UIFont, constrainedToSize size:CGSize) -> CGSize {
        var textSize:CGSize!
        if __CGSizeEqualToSize(size,CGSize.zero){
            let attributes=NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
            textSize=self.size(withAttributes:attributes as? [NSAttributedStringKey : Any])
        }else{
            let attributes=NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
            let stringRect = self.boundingRect(with:size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes:attributes as? [NSAttributedStringKey : Any], context: nil)
            textSize = stringRect.size
        }
        return textSize
    }
}
extension String{
    /**
     过滤特殊字符
     
     - returns:
     */
    func check() -> String {
        
        let  result = NSMutableString()
        // 使用正则表达式一定要加try语句
        
        do {
            
            // - 1、创建规则
            
            let pattern = "[a-zA-Z_0-9_一-龥]"
            
            // - 2、创建正则表达式对象
            
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            
            // - 3、开始匹配
            
            let res = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count))
            
            // 输出结果
            
            for checkingRes in res {
                
                let nn = (self as NSString).substring(with: checkingRes.range) as NSString
                
                result.append(nn as String)
                
            }
            
        }
            
        catch {
            
            print(error)
            
        }
        
        return result as String
        
    }
}
