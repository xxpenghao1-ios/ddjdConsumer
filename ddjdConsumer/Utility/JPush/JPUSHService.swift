//
//  JPUSHService.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/6.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import UIKit
/// 极光推送
class PHJPushHelper:NSObject{
    /**
     在应用启动的时候调用
     
     - parameter launchOptions:需要传入[UIApplicationLaunchOptionsKey:Any]
     */
    
    class func setupWithOptions(launchOptions:[UIApplicationLaunchOptionsKey:Any]?,delegate:JPUSHRegisterDelegate){
        if #available(iOS 10.0, *){
            let entiity = JPUSHRegisterEntity()
            entiity.types = Int(UNAuthorizationOptions.alert.rawValue |
                UNAuthorizationOptions.badge.rawValue |
                UNAuthorizationOptions.sound.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entiity, delegate:delegate)
        }else if #available(iOS 8.0, *) {
            let types = UIUserNotificationType.badge.rawValue |
                UIUserNotificationType.sound.rawValue |
                UIUserNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: types, categories: nil)
        }else {
            let type = UIRemoteNotificationType.badge.rawValue |
                UIRemoteNotificationType.sound.rawValue |
                UIRemoteNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: type, categories: nil)
        }
        JPUSHService.setup(withOption:launchOptions, appKey:"4506fc9c3d44e38901f81786", channel:"ddjdCIOS", apsForProduction:false)
    }
    
}
