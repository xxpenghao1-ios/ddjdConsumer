//
//  PriceComputationsUtil.swift
//  pointSingleThatIsTo
//
//  Created by hao peng on 2017/11/7.
//  Copyright © 2017年 penghao. All rights reserved.
//

import Foundation
public enum ComputationsType{
    ///加
    case addition
    ///减
    case subtraction
    ///乘
    case multiplication
    ///除
    case division
}
class PriceComputationsUtil: NSObject {
    /// 货币计算,向零方向舍入的舍入模式。从不对舍弃部分前面的数字加 1（即截尾）。注意，此舍入模式始终不会增加计算值的绝对值。
    ///
    /// - Parameters:
    ///   - multiplierValue: value1
    ///   - multiplicandValue: value2
    ///   - position:需要保留的小数点位数
    /// - Returns:保留好位数的字符串
    internal class func decimalNumberWithString(multiplierValue:String,multiplicandValue:String,type:ComputationsType, position:Int) -> String {
        
        let multiplierNumber = NSDecimalNumber.init(string: multiplierValue)
        let multiplicandNumber = NSDecimalNumber.init(string: multiplicandValue)
        
        let roundingBehavior = NSDecimalNumberHandler.init(
            roundingMode: NSDecimalNumber.RoundingMode.down,
            scale: Int16(position),
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false)
        var product : NSDecimalNumber
        switch type {
        case .addition:
            product = multiplierNumber.adding(multiplicandNumber, withBehavior: roundingBehavior)
            break
        case .subtraction:
            product = multiplierNumber.subtracting(multiplicandNumber, withBehavior: roundingBehavior)
            break
        case .multiplication:
            product = multiplierNumber.multiplying(by: multiplicandNumber, withBehavior: roundingBehavior)
            break
        default:
            product = multiplierNumber.dividing(by: multiplicandNumber, withBehavior: roundingBehavior)
            break
        }
        return String(format: "%.\(position)f", product.doubleValue)
    }
    
}
