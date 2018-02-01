//
//  PublicUtility.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/7.
//  Copyright © 2017年 zltx. All rights reserved.
//
//pod 'UMengSocialCOM', '~> 5.2.1'    #友盟分享    (oc)
//pod 'UMengAnalytics'    #友盟统计 标准SDK，含IDFA   (oc)
//pod 'AFNetworking', '~> 3.0' #网络请求   (OC)
//pod 'SwiftyJSON'            #JSON转字典   (Swift)
//pod 'SDWebImage', '~>3.8'   #图片缓存(网络图片请求拓展类 (oc)
//pod 'MJExtension'           #MJExtension （oc)
//pod 'MJRefresh'             #上啦下啦刷新库 (oc)
//pod 'FMDB'                  #SQLite数据库  (oc)
//pod 'CWStatusBarNotification', '~> 2.3.5'   #Notification消息通知 (oc)
//pod 'FDFullscreenPopGesture', '1.1'         #pop滑动库 (oc)
//pod 'UITableView+FDTemplateLayoutCell'      #计算TableCell高度
//pod 'CYLTabBarController'                   #拓展的Tabbar (oc)
//pod 'DOPDropDownMenu-Enhanced', '~> 1.0.0'  #多级菜单 (oc)
//pod 'SWTableViewCell', '~> 0.3.7'           #可左右滑动的Cell (oc)
//pod 'IQKeyboardManager'                     #键盘管理 (oc)
//pod 'WMPageController'                      #左右滑动（oc)
//pod 'DZNEmptyDataSet'                       #UITableview
import Foundation
import UIKit
//app公用常量
///图片请求路径
let urlImg="http://c.hnddjd.com";
///cs.houjue.me
///数据请求路径
let url="http://c.hnddjd.com";

/// 屏幕宽
let boundsWidth=UIScreen.main.bounds.width

/// 屏幕高
let boundsHeight=UIScreen.main.bounds.height

/// 导航栏高度
let navHeight:CGFloat=boundsHeight==812.0 ? 88 : 64

/// 底部安全距离
let bottomSafetyDistanceHeight:CGFloat=boundsHeight==812.0 ? 34 : 0

/// tabBar高度
let tabBarHeight:CGFloat=boundsHeight==812.0 ? 83 : 49

/// 全局缓存
let userDefaults=UserDefaults.standard

/// 商品默认图片
let goodDefaultImg="good_defualt"

/// 头像默认图片
let memberDefualtImg="member_defualt"

/// 幻灯片默认图片
let slide_default="good_defualt"

let app=UIApplication.shared.delegate as! AppDelegate
//会员id
var MEMBERID:Int{
    get{
        return userDefaults.object(forKey:"memberId") as? Int ?? -1
    }
}
//会员绑定店铺id
var BINDSTOREID:Int{
    get{
        if (userDefaults.object(forKey:"iosExamineStatu") as? Int) == 1{//如果不是审核状态
            return userDefaults.object(forKey:"bindstoreId") as? Int ?? -1
        }else{
            return userDefaults.object(forKey:"bindstoreId") as? Int ?? 102
        }
    }
}
//店铺id
var STOREID:Int{
    get{
        return userDefaults.object(forKey:"storeId") as? Int ?? -1
    }
}
///公钥
let PUBLICKEY="ddjdc_request"
///私钥
let PRIVATEKEY="ddjdc_requestPrivateKeyAccByZltx"
///storyboard页面
///
/// - Parameters:
///   - name: storyboard名称
///   - withIdentifier: storyboardId
/// - Returns: 页面
func storyboardViewController(type:storyboardType,withIdentifier:String) -> UIViewController{
    return UIStoryboard(name:type.rawValue, bundle:nil).instantiateViewController(withIdentifier:withIdentifier)
}
///拿到xib类
func getXibClass(name:String,owner:Any?) -> Any?{
   return Bundle.main.loadNibNamed(name,owner:owner,options:nil)?.last
}
///删除上传图片img
func deleteUploadImgFile(){
    let fileManager = FileManager.default
    let myDirectory = NSHomeDirectory() + "/Documents/myImgages"
    let fileArray = fileManager.subpaths(atPath: myDirectory)
    if fileArray != nil{
        for fn in fileArray!{
            try! fileManager.removeItem(atPath: myDirectory + "/\(fn)")
        }
    }
}
extension CGFloat{
    /// ps字体大小转ios字体大小
    static func pxTurnPt(px:Int) -> CGFloat{
        let pt=(px/96)*72
        return CGFloat(pt)
    }
}
///MD5加密
extension Int
{
    func hexedString() -> String
    {
        return NSString(format:"%02x", self) as String
    }
}

extension NSData
{
    func hexedString() -> String
    {
        var string = String()
        let unsafePointer = bytes.assumingMemoryBound(to: UInt8.self)
        for i in UnsafeBufferPointer<UInt8>(start:unsafePointer, count: length)
        {
            string += Int(i).hexedString()
        }
        return string
    }
    func MD5() -> NSData
    {
        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
        let unsafePointer = result.mutableBytes.assumingMemoryBound(to: UInt8.self)
        CC_MD5(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(unsafePointer))
        return NSData(data: result as Data)
    }
}

extension String
{
    func MD5() -> String
    {
        let data = (self as NSString).data(using: String.Encoding.utf8.rawValue)! as NSData
        return data.MD5().hexedString()
    }
}
///// log 打印
//let log: XCGLogger = {
//    // Setup XCGLogger
//    let log = XCGLogger.default
//
//    if let fileDestination: FileDestination = log.destination(withIdentifier: XCGLogger.Constants.fileDestinationIdentifier) as? FileDestination {
//        let ansiColorLogFormatter: ANSIColorLogFormatter = ANSIColorLogFormatter()
//        ansiColorLogFormatter.colorize(level: .verbose, with: .colorIndex(number: 244), options: [.faint])
//        ansiColorLogFormatter.colorize(level: .debug, with: .black)
//        ansiColorLogFormatter.colorize(level: .info, with: .blue, options: [.underline])
//        ansiColorLogFormatter.colorize(level: .warning, with: .yellow, options: [.faint])
//        ansiColorLogFormatter.colorize(level: .error, with: .red, options: [.bold])
//        ansiColorLogFormatter.colorize(level: .severe, with: .white, on: .red)
//        fileDestination.formatters = [ansiColorLogFormatter]
//    }
//
//
//    //    let emojiLogFormatter = PrePostFixLogFormatter()
//    //    emojiLogFormatter.apply(prefix: "🗯🗯🗯 ", postfix: " 🗯🗯🗯", to: .verbose)
//    //    emojiLogFormatter.apply(prefix: "🔹🔹🔹 ", postfix: " 🔹🔹🔹", to: .debug)
//    //    emojiLogFormatter.apply(prefix: "ℹ️ℹ️ℹ️ ", postfix: " ℹ️ℹ️ℹ️", to: .info)
//    //    emojiLogFormatter.apply(prefix: "⚠️⚠️⚠️ ", postfix: " ⚠️⚠️⚠️", to: .warning)
//    //    emojiLogFormatter.apply(prefix: "‼️‼️‼️ ", postfix: " ‼️‼️‼️", to: .error)
//    //    emojiLogFormatter.apply(prefix: "💣💣💣 ", postfix: " 💣💣💣", to: .severe)
//    //    log.formatters = [emojiLogFormatter]
//
//    return log
//}()



