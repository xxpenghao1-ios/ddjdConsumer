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
import SnapKit
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
    case launch="LaunchScreen"
}
/// 基类
class BaseViewController:UIViewController{
    /*****默认加载页参数*****/
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
    /************end**************/

    /******商品提示数量******/
    ///商品数量提示
    private var lblGoodCountPrompt:UILabel!
    private var goodCountPromptView:UIView!
    // 保存约束（引用约束）
    private var updateConstraint: Constraint?
    ///总数量
    open var totalRow=0
    /*******end*************/

    /******图片cell加载优化只加载UITableView/UICollectView当前可见区域图片******/
    ///图片队列管理类，追踪每个操作的状态
    let movieOperations=MovieOperations.shared
    /********end**********/

    override func viewDidLoad() {
        super.viewDidLoad()
        ///去掉返回按钮文字
        let bark=UIBarButtonItem()
        bark.title=""
        self.navigationItem.backBarButtonItem=bark
        setUpView()

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if SVProgressHUD.isVisible(){
            SVProgressHUD.dismiss(withDelay:1)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("内存报警了")
        cache.clearMemoryCache()

    }
}
///页面设置
extension BaseViewController{
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
    ///设置页面view
    private func setUpView(){
        setUpGoodCountPromptView()
    }
    ///设置商品提示view
    private func setUpGoodCountPromptView(){
        goodCountPromptView=UIView.init()
        goodCountPromptView.backgroundColor=UIColor.init(red:0, green:0, blue: 0, alpha:0.5)
        goodCountPromptView.layer.cornerRadius=15
        self.view.addSubview(goodCountPromptView)
        goodCountPromptView.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.width.equalTo(100)
            make.left.equalTo((boundsWidth-100)/2)
            self.updateConstraint=make.bottom.equalTo(-(10+bottomSafetyDistanceHeight)).constraint
        }

        lblGoodCountPrompt=UILabel.buildLabel(textColor:UIColor.white, font:13, textAlignment: NSTextAlignment.center)
        goodCountPromptView.addSubview(lblGoodCountPrompt)

        lblGoodCountPrompt.snp.makeConstraints { (make) in
            make.edges.equalTo(goodCountPromptView)
        }
        ///默认隐藏
        goodCountPromptView.isHidden=true
    }
}

///页面控件赋值展示
extension BaseViewController{

    ///展示商品数量提示view
    ///
    /// - Parameters:
    ///   - currentCount: 当前数量
    ///   - totalCount: 总数量
    func showBaseVCGoodCountPromptView(currentCount:Int,totalCount:Int,view:UIView?=nil){
        if view?.frame.height == 690.0{
            self.updateConstraint?.update(offset:-10)
        }else{
            self.updateConstraint?.update(offset:-(10+bottomSafetyDistanceHeight))
        }
        lblGoodCountPrompt.text="\(currentCount)/\(totalCount)"
        goodCountPromptView.isHidden=false
        self.view.bringSubview(toFront:self.goodCountPromptView)
        if currentCount == 0{//隐藏
            hideBaseVCGoodCountPromptView()
        }
    }
    ///隐藏商品数量提示view
    private func hideBaseVCGoodCountPromptView(){
        goodCountPromptView.isHidden=true
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
            if MEMBERID == -1{
                text="您还没有登录,相关数据需要登录后才能展示"
            }else{
                text=emptyDataSetTextInfo
            }
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
        return true
    }
    ///是否显示
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return emptyDataSetIsDisplay
    }
}
///滚动类型
public enum ScrollType{
    case tableView
    case collectView
}
// MARK: - UITableView/UICollectView图片加载优化(只加载当前显示cell的图片)
extension BaseViewController{
    //图片任务
    func startOperationsForMovieRecord(_ entity: GoodEntity, indexPath: IndexPath,completion:@escaping () -> Void){
        switch (entity.state) {
        case .new:
            startDownloadForRecord(entity, indexPath: indexPath,completion:completion)
        default:break
        }
    }
    //执行图片下载任务
    func startDownloadForRecord(_ entity:GoodEntity, indexPath: IndexPath,completion:@escaping () -> Void){
        //判断队列中是否已有该图片任务
        if let _ = movieOperations.downloadsInProgress[indexPath] {
            return
        }

        //创建一个下载任务
        let downloader = ImageDownloader.init(entity:entity)
        //任务完成后重新加载对应的单元格
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async(execute: {
                self.movieOperations.downloadsInProgress.removeValue(forKey: indexPath)
                ///回调
                completion()
            })
        }
        //记录当前下载任务
        movieOperations.downloadsInProgress[indexPath] = downloader
        //将任务添加到队列中
        movieOperations.downloadQueue.addOperation(downloader)
    }
    open func resumeAllOperationsAndloadImagesForOnscreenCells(type:ScrollType,scrollView:UIScrollView,arr:[GoodEntity]){
        loadImagesForOnscreenCells(type:type,scrollView:scrollView,arr:arr)
        resumeAllOperations()
    }

    //暂停所有队列
    open func suspendAllOperations () {
        movieOperations.downloadQueue.isSuspended = true
        movieOperations.filtrationQueue.isSuspended = true
    }

    //恢复运行所有队列
    private func resumeAllOperations () {
        movieOperations.downloadQueue.isSuspended = false
        movieOperations.filtrationQueue.isSuspended = false
    }

    //加载可见区域的单元格图片
    private func loadImagesForOnscreenCells (type:ScrollType,scrollView:UIScrollView,arr:[GoodEntity]) {
        var pathsArray:[IndexPath]?
        var table:UITableView!
        var collect:UICollectionView!
        //开始将tableview/collectView可见行的index path放入数组中。
        if type == .tableView{
            table=scrollView as! UITableView
            pathsArray = table.indexPathsForVisibleRows
        }else{
            collect=scrollView as! UICollectionView
            pathsArray = collect.indexPathsForVisibleItems
        }
        //通过组合所有下载队列来创建一个包含所有等待任务的集合
        let allMovieOperations = NSMutableSet()
        for key in movieOperations.downloadsInProgress.keys{
            allMovieOperations.add(key)
        }

        //构建一个需要撤销的任务的集合。从所有任务中除掉可见行的index path，
        //剩下的就是屏幕外的行所代表的任务。
        let toBeCancelled = allMovieOperations.mutableCopy() as? NSMutableSet
        let visiblePaths = NSSet(array: pathsArray!)
        toBeCancelled?.minus(visiblePaths as Set<NSObject>)

        //创建一个需要执行的任务的集合。从所有可见index path的集合中除去那些已经在等待队列中的。
        let toBeStarted = visiblePaths.mutableCopy() as! NSMutableSet
        toBeStarted.minus(allMovieOperations as Set<NSObject>)

        // 遍历需要撤销的任务，撤消它们，然后从 movieOperations 中去掉它们
        for indexPath in toBeCancelled! {
            let indexPath = indexPath as! IndexPath
            if let movieDownload = movieOperations.downloadsInProgress[indexPath] {
                movieDownload.cancel()
            }
            movieOperations.downloadsInProgress.removeValue(forKey: indexPath)
        }
        // 遍历需要开始的任务，调用 startOperationsForPhotoRecord
        for indexPath in toBeStarted {
            let indexPath = indexPath as? IndexPath
            if indexPath != nil{
                if type == .tableView{
                    let entity = arr[indexPath!.row]
                    startOperationsForMovieRecord(entity, indexPath: indexPath!){
                        table.reloadRows(at:[indexPath!], with: UITableViewRowAnimation.fade)
                    }
                }else{
                    let entity = arr[indexPath!.item]
                    startOperationsForMovieRecord(entity, indexPath: indexPath!){
                        UIView.performWithoutAnimation({
                            UIView.animate(withDuration:1, delay:0, options:.transitionCrossDissolve, animations: {
                                collect.reloadItems(at:[indexPath!])
                            }, completion: nil)
                        })
                    }
                }
            }
        }
    }
}

