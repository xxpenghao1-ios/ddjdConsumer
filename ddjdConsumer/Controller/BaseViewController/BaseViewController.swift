//
//  BaseViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/11.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import SwiftyJSON
import ObjectMapper
import RealReachability
/// 对应sb中单个storyboard
///
/// - index: 首页
/// - my: 个人中心
/// - goodsClassification: 分类页面
/// - shoppingCar: 购物车
public enum storyboardType:String{
    case index="Index"
    case my="My"
    case goodsClassification="GoodsClassification"
    case shoppingCar="ShoppingCar"
    case loginWithRegistr="LoginWithRegistr"
    case main="Main"
    case store="Store"
    case storeGood="StoreGood"
    case storeOrder="StoreOrder"
}
/// 基类
class BaseViewController:UIViewController{
    //是否显示加载状态 默认不加载
    private var emptyDataSetIsLoading=false
    //是否显示空白页 默认显示
    private var emptyDataSetIsDisplay=true
    //空视图提示信息 默认为空
    private var emptyDataSetTextInfo=""
    //空视图提示图片 //默认为空
    private var emptyDataSetImage:String?
    //空视图文字颜色
    private var emptyDataSetTextColor:UIColor?
//    /// 检查是否有无网络
//    let reachabilityStatus=RealReachability.sharedInstance().currentReachabilityStatus()
    override func viewDidLoad() {
        super.viewDidLoad()
        ///去掉返回按钮文字
        let bark=UIBarButtonItem()
        bark.title=""
        self.navigationItem.backBarButtonItem=bark
    }
    // MARK: - 其他内部方法
    //寻找导航栏下的横线  （递归查询导航栏下边那条分割线）
    func findNavLineImageViewOn(_ view: UIView) -> UIImageView? {
        if view.isKind(of: UIImageView.classForCoder()) && view.bounds.size.height <= 1.0{
            return view as? UIImageView
        }
        for subView in view.subviews {
            let imageView = findNavLineImageViewOn(subView)
            if imageView != nil {
                return imageView
            }
        }
        return nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - 设置导航栏颜色
extension BaseViewController{
    //设置导航栏颜色
    func setUpNavColor(){
        //改掉导航栏黑线颜色
        self.navigationController?.navigationBar.shadowImage=UIImage.imageFromColor(UIColor.applicationMainColor())
        self.navigationController?.navigationBar.barTintColor=UIColor.applicationMainColor()
        self.navigationController?.navigationBar.titleTextAttributes=NSDictionary(object:UIColor.white, forKey:NSAttributedStringKey.foregroundColor as NSCopying) as? [NSAttributedStringKey : Any]
        self.navigationController?.navigationBar.tintColor=UIColor.white
    }
    //恢复导航栏颜色
    func reinstateNavColor(){
        //恢复导航栏黑线颜色
        self.navigationController?.navigationBar.shadowImage=nil
        self.navigationController?.navigationBar.tintColor=UIColor.applicationMainColor()
        self.navigationController?.navigationBar.barTintColor=UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes=NSDictionary(object:UIColor.applicationMainColor(), forKey:NSAttributedStringKey.foregroundColor as NSCopying) as? [NSAttributedStringKey : Any]
    }
}
// MARK: - ObjectMapper
extension BaseViewController{
    /**
     json映射entity(泛型)传入entity返回对应已经解析的entity
     
     - parameter object:AnyObject
     
     - returns:Mappable
     */
    func jsonMappingEntity<N:Mappable>(entity:N,object:Any) -> N?{
        return Mapper<N>().map(JSONObject:object)
    }
}
// MARK: - 跳转页面
extension BaseViewController{
    /**
     用Storyboard构建页面需要StoryboardId找到页面
     
     - parameter storyboardId:
     
     - returns: 返回UIViewController
     */
    func storyboardPushView(type:storyboardType,storyboardId:String) -> UIViewController{
        //先拿到main文件
        let storyboard=UIStoryboard(name:type.rawValue, bundle:nil);
        let vc=storyboard.instantiateViewController(withIdentifier: storyboardId)
        return vc
    }
}
/**
 弹出对应的窗体
 
 - Error:   错误提示
 - Success: 成功提示
 - Info:    警告提示
 - Text:    文本提示
 - TextClear:文本提示(不允许用户交互)
 - TextGradient:文本提示(带背景不允许用户交互)
 */
public enum HUD {
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
///实现默认视图协议
extension BaseViewController:DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    /// 给视图设置提示信息
    ///
    /// - Parameters:
    ///   - text: 提示文本  默认“”
    ///   - strImg: 提示图片 默认 emptyDataSet_defualt 图片自行好
    ///   - textColor: 提示文字颜色 默认#666666
    func setEmptyDataSetInfo(text:String,strImg:String?=nil,textColor:UIColor?=nil){
        self.emptyDataSetImage=strImg
        self.emptyDataSetTextInfo=text
        self.emptyDataSetTextColor=textColor
    }
    ///设置加载状态 true加载 false不加载
    func setLoadingState(isLoading:Bool){
        self.emptyDataSetIsLoading=isLoading
    }
    ///设置是否显示 默认显示 true显示 false不显示
    func setDisplay(isDisplay:Bool){
        self.emptyDataSetIsDisplay=isDisplay
    }
    //图片
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        if emptyDataSetIsLoading{
            return UIImage(named:"loading")?.reSizeImage(reSize:CGSize(width:45,height:45))
        }else{
            if emptyDataSetImage != nil{
                return UIImage(named:emptyDataSetImage!)?.reSizeImage(reSize:CGSize(width:497/3, height:150/3))
            }else{
                return UIImage(named:"emptyDataSet_defualt")?.reSizeImage(reSize:CGSize(width:497/3, height:150/3))
            }
        }
    }
    //设置图片动画
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation? {
        let animation=CABasicAnimation(keyPath:"transform")
        animation.fromValue = NSValue(caTransform3D:CATransform3DIdentity)
        animation.toValue = NSValue(caTransform3D:CATransform3DMakeRotation(CGFloat.pi/2, 0, 0, 1.0))
        animation.duration = 0.25;
        animation.isCumulative=true
        animation.repeatCount = MAXFLOAT;
        return animation
    }
    //文字提示
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var text=""
        let attributes=[NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:self.emptyDataSetTextColor ?? UIColor.color666()] as [NSAttributedStringKey : Any]
        if !emptyDataSetIsLoading{ //如果不是加载状态 显示提示信息
            text=emptyDataSetTextInfo
        }
        return NSAttributedString(string:text, attributes:attributes)
    }
    //设置文字和图片间距
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 0
    }
    //设置垂直偏移量
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 0
    }
    //是否执行动画
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView) -> Bool {
        return emptyDataSetIsLoading
    }
    //设置是否可以滑动 默认不可以
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    ///是否显示
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return emptyDataSetIsDisplay
    }
}
