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
import SwiftyJSON
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    var window: UIWindow?
    var tab:ConsumerTabBarViewController!
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
    ///后台进入前台
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        /**
         版本检查每次启动应用程序执行Immediately
         版本检查每天执行一次 Daily
         版本检查每周执行一次Weekly
         */
        Siren.shared.checkVersion(checkType: .daily)
        JPUSHService.resetBadge()
        self.queryMemberLastLoginRecord()
        application.applicationIconBadgeNumber=0;
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    ///推送消息时，获取设备的tokenid
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //设备标识是NSdata通过截取字符串去掉空格获得字符串保存进缓存 登录发给服务器 用于控制用户只能在一台设备登录
        print(deviceToken)
        let characterSet: CharacterSet = CharacterSet(charactersIn: "<>")
        let deviceTokenString: String = (deviceToken.description as NSString)
            .trimmingCharacters(in: characterSet)
            .replacingOccurrences(of: " ", with: "") as String
        //把截取的设备令牌保存进缓存
        userDefaults.set(deviceTokenString, forKey:"deviceToken")
        //写入磁盘
        userDefaults.synchronize()
        JPUSHService.registerDeviceToken(deviceToken)
    }
    ///接收到推送消息处理
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Required, iOS 7 Support
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(.newData)
        //转换为json
        let jsonObject=JSON(userInfo);
        //取出推送内容
        var aps=jsonObject["aps"]
        let alert_type=jsonObject["alert_type"].intValue
        let alert=aps["alert"].stringValue;
        if(application.applicationState == UIApplicationState.active){//如果程序活动在前台
            if alert_type == 1{//如果是订单
                UIAlertController.showAlertYesNo(self.window?.rootViewController,title:"提示", message: alert, cancelButtonTitle:"取消", okButtonTitle:"查看", okHandler: { (action) in
                    self.showStoreOrderList()
                })
            }
        }else{//如果程序运行在后台
            if alert_type == 1{//如果是订单
                self.showStoreOrderList()
            }
        }
        
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
        //监听极光推送自定义消息(只有在前端运行的时候才能收到自定义消息的推送。)
        NotificationCenter.default.addObserver(self, selector:#selector(networkDidReceiveMessage), name:NSNotification.Name.jpfNetworkDidReceiveMessage, object:nil)
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
        ///刷新分类信息
        GoodClassificationDB.shared.refreshClassificationData()

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
            //转换为json
            let jsonObject=JSON(userInfo);
            let alert_type=jsonObject["alert_type"].intValue
            if alert_type == 1{//订单
                self.showStoreOrderList()
            }
        }
        completionHandler()
    }
    ///用户在前台接收到推送消息执行
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo=notification.request.content.userInfo
        if (notification.request.trigger?.isKind(of:UNPushNotificationTrigger.classForCoder()))!{
            JPUSHService.handleRemoteNotification(userInfo)
            //转换为json
            let jsonObject=JSON(userInfo);
            let alert_type=jsonObject["alert_type"].intValue
            if alert_type == 1{//订单
                let alert=jsonObject["aps"]["alert"].stringValue
                UIAlertController.showAlertYesNo(self.window?.rootViewController,title:"提示", message: alert, cancelButtonTitle:"取消", okButtonTitle:"查看", okHandler: { (action) in
                    self.showStoreOrderList()
                })
            }
        }
    }
    ///弹出订单列表
    private func showStoreOrderList(){
        let vc=PageStoreOrderListViewController()
        vc.isCancelItem=1
        app.window?.rootViewController?.present(UINavigationController.init(rootViewController:vc), animated:true, completion: nil)
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
        tab=storyboardViewController(type:.main,withIdentifier:"ConsumerTabBarId") as! ConsumerTabBarViewController
        self.window?.rootViewController=tab
    }
    //跳转到登录页面
    func jumpToLoginVC(){
        let loginNav=storyboardViewController(type:.loginWithRegistr,withIdentifier:"LoginId") as! UINavigationController
        self.window?.rootViewController=loginNav
    }
}
// MARK: - 极光推送自定义消息监听
extension AppDelegate{
    @objc func networkDidReceiveMessage(_ notification:Notification){
        let userInfo=notification.userInfo
        if userInfo != nil{
            let json=JSON(userInfo!)
            let msg=json["extras"]["msg"].intValue
            if msg == 1{//如果为3 表示该账号在其他设备登录
                queryMemberLastLoginRecord()
            }
        }
    }
    ///会员最后一次不同设备登录记录
    private func queryMemberLastLoginRecord(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:LoginWithRegistrApi.queryMemberLastLoginRecord(memberId:MEMBERID), successClosure: { (json) in
            print(json)
            let lastLoginRecord=json["lastLoginRecord"]
            let memberLastLoginDeviceToken=lastLoginRecord["memberLastLoginDeviceToken"].stringValue
            let memberLastLoginTime=lastLoginRecord["memberLastLoginTime"].stringValue
            let memberLastLoginDeviceName=lastLoginRecord["memberLastLoginDeviceName"].stringValue
            let deviceToken=userDefaults.object(forKey:"deviceToken") as? String
            if memberLastLoginDeviceToken != deviceToken{//判断服务器返回的设备标识与当前本机的缓存中的设备标识是否相等  如果不等于表示该账号在另一台设备在登录
                //直接跳转到登录页面

                let alert=UIAlertController(title:"重新登录", message:"您的账号于\(memberLastLoginTime)在另一台设备\(memberLastLoginDeviceName)上登录。如非本人操作,则密码可能已泄露,建议您重新设置密码,以确保数据安全。", preferredStyle: UIAlertControllerStyle.alert)
                let ok=UIAlertAction(title:"确定", style: UIAlertActionStyle.default, handler:{ Void
                    in//点击确定 清除推送别名
                    JPUSHService.setAlias("", completion: nil, seq: 22)
                    app.jumpToLoginVC()
                })
                alert.addAction(ok)
                self.window?.rootViewController?.present(alert, animated:true, completion:nil)
            }
        }) { (error) in

        }
    }
}
