//
//  AppDelegate.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/4.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
import Siren
import SVProgressHUD
import IQKeyboardManagerSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    var window: UIWindow?
    ///程序入口
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //加载设置
        loadSetting(launchOptions:launchOptions)
        if MEMBERID == -1 || BINDSTOREID == -1{//如果没有会员信息加载登录页面 || 或者会员没有绑定店铺
            self.jumpToLoginVC()
        }else{//加载主页面
            self.jumpToIndexVC()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        /**
         版本检查每次启动应用程序执行Immediately
         版本检查每天执行一次 Daily
         版本检查每周执行一次Weekly
         */
        Siren.shared.checkVersion(checkType: .immediately)
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        /**
         版本检查每次启动应用程序执行Immediately
         版本检查每天执行一次 Daily
         版本检查每周执行一次Weekly
         */
        Siren.shared.checkVersion(checkType: .daily)
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    ///推送消息时，获取设备的tokenid
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    ///接收到推送消息处理
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Required, iOS 7 Support
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(.newData)
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        //// Required,For systems with less than or equal to iOS6
        JPUSHService.handleRemoteNotification(userInfo)
    }

}

// MARK: - 加载各种设置
extension AppDelegate{
    fileprivate func loadSetting(launchOptions:[UIApplicationLaunchOptionsKey: Any]?){
        //设置导航控制器
        setUpNav()
        /********第三方设置***********/
        //开启键盘框架
        IQKeyboardManager.sharedManager().enable = true
        //设置百度
        setUpBMKMap()
        //开启极光推送
        PHJPushHelper.setupWithOptions(launchOptions:launchOptions,delegate:self)
        //关闭极光推送打印
        JPUSHService.setLogOFF()
        //百度统计
        BaiduMobStat.default().start(withAppId: "46c2b6d4bb")
        BaiduMobStat.default().enableDebugOn=false
        //设置菊花图默认前景色和背景色
        SVProgressHUD.setForegroundColor(UIColor(white: 1, alpha: 1))
        SVProgressHUD.setBackgroundColor(UIColor(white: 0.15, alpha: 0.85))
        //设置版本更新
        setupSiren()
        //向微信终端程序注册第三方应用
        WXApi.registerApp(WX_APPID)
        
    }
}
///百度地图
extension AppDelegate:BMKGeneralDelegate{
    ///设置百度地图
    private func setUpBMKMap(){
        let mapManager=BMKMapManager()
        let ret=mapManager.start("YPGsfVTfmQa4X0i6SaV3YrXVLgEfFXas", generalDelegate:self)
        if ret{
            print("百度地图注册成功")
        }
    }
}
// MARK: - 实现极光推送协议
extension AppDelegate:JPUSHRegisterDelegate{
    ///用户点击通知栏进入app执行
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo=response.notification.request.content.userInfo
        if (response.notification.request.trigger?.isKind(of:UNPushNotificationTrigger.classForCoder()))!{
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler()
    }
    ///用户在前台接收到推送消息执行
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo=notification.request.content.userInfo
        if (notification.request.trigger?.isKind(of:UNPushNotificationTrigger.classForCoder()))!{
            JPUSHService.handleRemoteNotification(userInfo)
        }
    }
    
}

// MARK: - 设置导航控制器
extension AppDelegate{
      fileprivate func setUpNav(){
        //导航栏背景色
        UINavigationBar.appearance().barTintColor=UIColor.white;
//        //设置状态栏为白色
//        UIApplication.shared.statusBarStyle = .lightContent
        //导航栏文字颜色
        UINavigationBar.appearance().titleTextAttributes=NSDictionary(object:UIColor.applicationMainColor(), forKey:NSAttributedStringKey.foregroundColor as NSCopying) as? [NSAttributedStringKey : Any]
        //设置导航栏不透明
        UINavigationBar.appearance().isTranslucent=false
        
        UINavigationBar.appearance().tintColor=UIColor.applicationMainColor()
//        //将返回按钮的文字position设置不在屏幕上显示
    }
}

// MARK: - 设置app更新提示
extension AppDelegate{
    /**
     版本更新
     */
    private func setupSiren() {
        let siren = Siren.shared
//        siren.debugEnabled = true
        siren.appName="点单即到"
        siren.majorUpdateAlertType = .option
        siren.minorUpdateAlertType = .option
        siren.patchUpdateAlertType = .option
        siren.revisionUpdateAlertType = .option
        siren.checkVersion(checkType: .immediately)
    }
}
// MARK: - 支付回调
extension AppDelegate{
    // iOS 8 及以下请用这个
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.host == "safepay"{
            //支付回调
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback:{ (resultDic) in
                if resultDic != nil{
                    AliPayManager.shared.showResult(result:resultDic! as NSDictionary)
                }
            })
            //授权回调
            AlipaySDK.defaultService().processAuth_V2Result(url, standbyCallback: { (resultDic) in
                if resultDic != nil{
                    AliPayManager.shared.showAuth_V2Result(result:resultDic! as NSDictionary)
                }
            })
            return true
        }else{
            return WXApi.handleOpen(url, delegate:WXApiManager.shared)
        }
        
    }
    // iOS 9 以上请用这个
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if url.host == "safepay"{
            //支付回调
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback:{ (resultDic) in
                if resultDic != nil{
                    AliPayManager.shared.showResult(result:resultDic! as NSDictionary)
                }
            })
            //授权回调
            AlipaySDK.defaultService().processAuth_V2Result(url, standbyCallback: { (resultDic) in
                if resultDic != nil{
                    AliPayManager.shared.showAuth_V2Result(result:resultDic! as NSDictionary)
                }
            })
            return true
        }else{
            return WXApi.handleOpen(url,delegate:WXApiManager.shared)
        }
    }
}
///页面切换
extension AppDelegate{
    //跳转到首页
    func jumpToIndexVC(){
        self.window?.rootViewController=storyboardViewController(type:.main,withIdentifier:"ConsumerTabBarId") as! UITabBarController
    }
    //跳转到登录页面
    func jumpToLoginVC(){
        let loginNav=storyboardViewController(type:.loginWithRegistr,withIdentifier:"LoginId") as! UINavigationController
        self.window?.rootViewController=loginNav
    }
}
