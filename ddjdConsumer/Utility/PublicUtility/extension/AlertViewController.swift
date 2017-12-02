//
//  AlertViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/10.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
// MARK: - 扩展系统自带弹出层
extension UIAlertController {
    /**
     弹出单个按钮
     
     - parameter presentController: 传入self
     - parameter title:             标题名称名称
     - parameter message:           弹出内容
     - parameter okButtonTitle:     按钮名称
     */
    class func showAlertYes(_ presentController: UIViewController!,title: String!,message: String!,okButtonTitle: String?) {
        let alert = UIAlertController(title: title!, message: message!, preferredStyle: UIAlertControllerStyle.alert)
        if (okButtonTitle != nil) {
            alert.addAction(UIAlertAction(title: okButtonTitle!, style: UIAlertActionStyle.default, handler: nil))
        }
        
        presentController!.present(alert, animated: true, completion: nil)
    }
    /**
     弹出单个按钮(需要传入一个闭包参数)
     
     - parameter presentController: 传入self
     - parameter title:             标题名称名称
     - parameter message:           弹出内容
     - parameter okButtonTitle:     按钮名称
     - parameter okHandler:         闭包参数
     */
    class func showAlertYes(_ presentController: UIViewController!,title: String!,message: String!,okButtonTitle: String? ,okHandler: ((UIAlertAction?) -> Void)!) {
        let alert = UIAlertController(title: title!, message: message!, preferredStyle: UIAlertControllerStyle.alert)
        if (okButtonTitle != nil) {
            alert.addAction(UIAlertAction(title: okButtonTitle!, style: UIAlertActionStyle.default, handler: okHandler))
        }
        
        presentController!.present(alert, animated: true, completion: nil)
    }
    /**
     弹出带确定取消的按钮
     
     - parameter presentController: 传入self
     - parameter title:             标题名称名称
     - parameter message:           弹出内容
     - parameter okButtonTitle:     确定按钮名称
     - parameter cancelButtonTitle: 取消按钮名称
     */
    class func showAlertYesNo(_ presentController: UIViewController!,title: String!,message: String!,cancelButtonTitle: String?,okButtonTitle: String?) {
        let alert = UIAlertController(title: title!, message: message!, preferredStyle: UIAlertControllerStyle.alert)
        if (cancelButtonTitle != nil) {
            alert.addAction(UIAlertAction(title: cancelButtonTitle!, style: UIAlertActionStyle.default, handler: nil))
        }
        if (okButtonTitle != nil) {
            alert.addAction(UIAlertAction(title: okButtonTitle!, style: UIAlertActionStyle.default, handler: nil))
        }
        
        presentController!.present(alert, animated: true, completion: nil)
    }
    /**
     弹出带确定取消的按钮(需要传入一个闭包参数)
     
     - parameter presentController: 传入self
     - parameter title:             标题名称名称
     - parameter message:           弹出内容
     - parameter okButtonTitle:     确定按钮名称
     - parameter cancelButtonTitle: 取消按钮名称
     - parameter okHandler:         闭包参数
     */
    class func showAlertYesNo(_ presentController: UIViewController!,title: String!,message: String!,cancelButtonTitle: String? ,okButtonTitle: String? ,okHandler: ((UIAlertAction?) -> Void)!) {
        let alert = UIAlertController(title: title!, message: message!, preferredStyle: UIAlertControllerStyle.alert)
        if (cancelButtonTitle != nil) {
            alert.addAction(UIAlertAction(title: cancelButtonTitle!, style: UIAlertActionStyle.default, handler: nil))
        }
        if (okButtonTitle != nil) {
            alert.addAction(UIAlertAction(title: okButtonTitle!, style: UIAlertActionStyle.default, handler: okHandler))
        }
        presentController!.present(alert, animated: true, completion: nil)
    }
    /**
     弹出带确定取消的按钮(需要传入2个闭包参数)
     
     - parameter presentController: 传入self
     - parameter title:             标题名称名称
     - parameter message:           弹出内容
     - parameter okButtonTitle:     确定按钮名称
     - parameter cancelButtonTitle: 取消按钮名称
     - parameter okHandler:         闭包参数
     */
    class func showAlertYesNo(_ presentController: UIViewController!,title: String!,message: String!,cancelButtonTitle: String? ,okButtonTitle: String? ,okHandler: ((UIAlertAction?) -> Void)!,cancelHandler:((UIAlertAction?) -> Void)!) {
        let alert = UIAlertController(title: title!, message: message!, preferredStyle: UIAlertControllerStyle.alert)
        if (cancelButtonTitle != nil) {
            alert.addAction(UIAlertAction(title: cancelButtonTitle!, style: UIAlertActionStyle.default, handler:cancelHandler))
        }
        if (okButtonTitle != nil) {
            alert.addAction(UIAlertAction(title: okButtonTitle!, style: UIAlertActionStyle.default, handler: okHandler))
        }
        presentController!.present(alert, animated: true, completion: nil)
    }
}
