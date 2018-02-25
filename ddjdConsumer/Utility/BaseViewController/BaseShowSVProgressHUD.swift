//
//  BaseShowSVProgressHUD.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/2/24.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import SVProgressHUD
/**
 弹出对应的窗体

 - Error:   错误提示
 - Success: 成功提示
 - Info:    警告提示
 - Text:    文本提示
 - TextClear:文本提示(不允许用户交互)
 - TextGradient:文本提示(带背景不允许用户交互)
 */
public enum HUD{
    case error
    case success
    case info
    case text
    case textClear
    case textGradient
}
// MARK: - SVProgressHUD
extension BaseViewController{
    /**
     弹出对应的提示视图

     - parameter status: 内容
     - parameter type:   弹出类型(HUD)
     */
    func showSVProgressHUD(status:String,type:HUD){
        switch type {
        case .error:
            return showError(status:status)
        case .success:
            return showSuccess(status:status)
        case .info:
            return showInfo(status: status)
        case .text:
            return showText(status: status)
        case .textClear:
            return showTextClear(status: status)
        case .textGradient:
            return showTextGradient(status: status)
        }
    }
    /**
     关闭弹出视图
     */
    func dismissHUD(){
        SVProgressHUD.dismiss()
    }
    func dismissHUD(delay:TimeInterval){
        SVProgressHUD.dismiss(withDelay:delay)
    }
    func dismissHUD(completion:@escaping () -> Swift.Void){
        SVProgressHUD.dismiss(completion:completion)
    }
    func dismissHUD(delay:TimeInterval,completion:@escaping () -> Swift.Void){
        SVProgressHUD.dismiss(withDelay:delay,completion: completion)
    }
    /**
     弹出错误

     - parameter status: 内容
     */
    private func showError(status:String){
        SVProgressHUD.showError(withStatus:status)
        dismissTimeDelay()
    }
    /**
     弹出成功

     - parameter status: 内容
     */
    private func showSuccess(status:String){
        SVProgressHUD.showSuccess(withStatus: status)
        dismissTimeDelay()
    }
    /**
     弹出警告

     - parameter status: 内容
     */
    private func showInfo(status:String){
        SVProgressHUD.showInfo(withStatus: status)
        dismissTimeDelay()
    }
    /**
     弹出文字

     - parameter status: 内容
     */
    private func showText(status:String){
        SVProgressHUD.show(withStatus: status)
    }
    /**
     弹出文字(用户不可交互)

     - parameter status: 内容
     */
    private func showTextClear(status:String){
        SVProgressHUD.show(withStatus: status)
        SVProgressHUD.setDefaultMaskType(.clear)
    }
    /**
     弹出文字(用户不可交互)带背景

     - parameter status: 内容
     */
    private func showTextGradient(status:String){
        SVProgressHUD.show(withStatus: status)
        SVProgressHUD.setDefaultMaskType(.gradient)
    }
    //延时2秒关闭
    private func dismissTimeDelay(){
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.dismiss(withDelay:2)
    }
}
