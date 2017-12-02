////
////  DSLTransitionFromFirstToSecond.swift
////
////
////  Created by penghao on 16/3/14.
////  Copyright © 2016年 penghao. All rights reserved.
////
//
//import Foundation
/////// 定义闭包接收传入的UIViewController返回UIView
////typealias transitionClosure=(_ viewcontroller:UIViewController) -> UIView?
////
/////// 保存页面(主页面,跳转页面)
////let transitionDic=NSMutableDictionary()
/////// 保存跳转页面(图片)
////var toViewTransitionClosure:transitionClosure!
/////// 保存主页面(图片)
////var fromViewTransitionClosure:transitionClosure!
////
/////// 用于判断动画是否执行(默认不执行)
////var isExecution = TransitionState.Inexecution
//// 一个默认的基于百分比的动画实现
//var interactivePopTransition:UIPercentDrivenInteractiveTransition!
//
///**
// 定义一个枚举判断是否执行过度动画
//
// - execution: 执行
// - inexecution:不执行
// */
//public enum TransitionState{
//    case Execution
//    case Inexecution
//}
//// MARK: - 扩展导航控制
//extension UINavigationController:UINavigationControllerDelegate{
//    /**
//     进入页面实现这个协议
//
//     - parameter animated:Bool
//     */
//    open override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.delegate=self
//    }
//    /**
//     页面加载给导航控制屏幕滑动手势
//     */
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//        /// 给导航控制器中的view添加屏幕滑动手势
//        let popRecognizer = UIScreenEdgePanGestureRecognizer(target:self,action: Selector(("handlePopRecognizer:")))
//        // 设置为左滑动
//        popRecognizer.edges = UIRectEdge.left
//        self.view.addGestureRecognizer(popRecognizer)
//
//    }
//    /**
//     页面退出清除协议
//
//     - parameter animated: Bool
//     */
//    open override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if self.delegate != nil{
//            self.delegate=nil
//        }
//    }
//
//    /**
//     扩展导航控制器 方法
//
//     - parameter toViewController: 跳转页面
//     - parameter fromView:         主页面闭包参数
//     - parameter toView:           跳转页面闭包参数
//     */
//    func pushViewController(toViewController:UIViewController,fromView:@escaping transitionClosure,toView:@escaping transitionClosure){
//        //页面调用这个方法 表示需要执行自定义动画(设置枚举类型为Execution)
//        isExecution = .Execution
//        //给闭包赋值
//        toViewTransitionClosure=toView
//        fromViewTransitionClosure=fromView
//        //给字典赋值
//        transitionDic.setObject(self.topViewController!,forKey:"fromVC" as NSCopying)
//        transitionDic.setObject(toViewController, forKey:"toVC" as NSCopying)
//        //跳转页面开始执行自定义动画
//        self.pushViewController(toViewController, animated:true)
//
//
//
//    }
//    /**
//     导航控制处理界面交互提供的API
//
//     - parameter navigationController: 导航控制器
//     - parameter operation:            导航控制器状态(push/pop)
//     - parameter fromVC:               主页面
//     - parameter toVC:                 跳转页面
//
//     - returns: UIViewControllerAnimatedTransitioning 自定义界面交互动画
//     */
//    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//
//        if isExecution == .Execution{//判断是否执行
//            let ds=PHTransitionFromFirstToSecond()
//            ds.navigationOperation=operation
//            return ds
//        }else{
//            return nil
//        }
//    }
//    //屏幕滑动调用
//    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//
//        return interactivePopTransition
//
//    }
//    /**
//     屏幕边缘滑动手势(设置为左边)
//
//     - parameter recognizer:UIScreenEdgePanGestureRecognizer屏幕滑动手势对象
//     */
//    func handlePopRecognizer(recognizer:UIScreenEdgePanGestureRecognizer){
//        //得到pop过程中的x坐标
//        var progress=recognizer.translation(in: self.view).x / (self.view.bounds.size.width * 1.0)
//        //返回较小的“x”和“y”。
//        progress = min(1.0,max(0.0,progress))
//        if recognizer.state == .began{
//            interactivePopTransition = UIPercentDrivenInteractiveTransition()
//            self.popToRootViewController(animated: true)
//        }else if recognizer.state == .changed{
//            interactivePopTransition.update(progress)
//        }else if recognizer.state == .ended || recognizer.state == .cancelled{
//            if progress > 0.5{
//                interactivePopTransition.finish()
//            }else{
//                interactivePopTransition.cancel()
//            }
//            interactivePopTransition=nil
//        }
//
//    }
//
//
//}
//
///// 自定义界面交互动画
//class PHTransitionFromFirstToSecond:NSObject,UIViewControllerAnimatedTransitioning{
//
//    /// 接收当前导航控制器操作状态主要监听(push/pop)
//    var navigationOperation:UINavigationControllerOperation?
//    /// 接收主页面数据
//    var fromViewClosure:transitionClosure?
//    /// 接收跳转页面数据
//    var toViewClosure:transitionClosure?
//
//
//    /**
//     界面交互需要做的操作
//
//     - parameter transitionContext:获取动画上下文
//
//     所以它包含了许多关于专场所需要的内容，包括转入ViewController和转出Viewcontroller，还有动画容器View--containerView等。
//     */
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let containerView=transitionContext.containerView
//        /// 主页面
//        let fromView=transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
//        /// 跳转页面
//        let toView=transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
//        /// 获取动画时间
//        let duration=self.transitionDuration(using: transitionContext)
//
//        if fromView == transitionDic.object(forKey: "fromVC") as! UIViewController && toView == transitionDic.object(forKey: "toVC") as! UIViewController{//判断当前主页面是否等于传入的主页面 并且 跳转页面是否等于传入跳转页面
//            //给对应的闭包赋值
//            fromViewClosure=fromViewTransitionClosure
//            toViewClosure=toViewTransitionClosure
//        }else if fromView == transitionDic.object(forKey: "toVC") as! UIViewController && toView == transitionDic.object(forKey: "fromVC") as! UIViewController{//否则倒过来赋值
//            fromViewClosure=toViewTransitionClosure
//            toViewClosure=fromViewTransitionClosure
//        }else{
//            var deviation:CGFloat!
//            if self.navigationOperation == UINavigationControllerOperation.push{
//                deviation = -1
//            }else{
//                deviation = 1
//            }
//            var newFrame = toView.view.frame;
//            newFrame.origin.x+=newFrame.size.width*deviation;
//            toView.view.frame=newFrame;
//            containerView.addSubview(toView.view)
//            containerView.addSubview(fromView.view)
//            /**
//            *  执行动画
//            */
//            UIView.animate(withDuration: duration, animations:{ Void in
//                var animationFrame=toView.view.frame
//                animationFrame.origin.x -= animationFrame.size.width*deviation
//                toView.view.frame=animationFrame
//                animationFrame=fromView.view.frame
//                animationFrame.origin.x -= animationFrame.size.width*deviation
//                fromView.view.frame=animationFrame
//                }, completion:{ finished in
//                    if self.navigationOperation == UINavigationControllerOperation.push{
//                        fromView.view.removeFromSuperview()
//                    }else{
//                        toView.view.removeFromSuperview()
//                    }
//                    //声明过度结束
//                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//                    //设置动画执行状态(Inexecution表示不执行)
//                    //                    isExecution = .Inexecution
//            })
//            return
//        }
//        var fromImgView:UIView!
//        var toImgView:UIView!
//        /// 传入页面参数 拿到主页面对应的图片ImgView
//        fromImgView=fromViewClosure!(fromView)!
//        /// 传入页面参数 拿到跳转页面对应的图片ImgView
//        toImgView=toViewClosure!(toView)!
//        /// 图片截图
//        let imageSnapshot:UIView!
//        // 判断导航控制器处于什么状态 执行相应的动画效果
//        if navigationOperation == UINavigationControllerOperation.push{//当导航控制属于push状态
//            /// 对cell中的图片截图 生成UIView
//            imageSnapshot=fromImgView.snapshotView(afterScreenUpdates: false)
//            // 设置该UIView的frame
//            imageSnapshot.frame=containerView.convert(fromImgView.frame, from:fromImgView)
//            // 隐藏cell中的图片
//            fromImgView.isHidden = true
//            // 现在初始化第2页面一开始状态
//            toView.view.frame=transitionContext.finalFrame(for: toView)
//            // 设置view的透明度为0
//            toView.view.alpha=0
//            // 隐藏第2页面的图片
//            toImgView.isHidden=true
//            // 把第2页面的view 和 第1页面截图添加进 视图过度处理view中来
//            containerView.addSubview(toView.view)
//            containerView.addSubview(imageSnapshot)
//            /**
//            *  执行动画
//            */
//            UIView.animate(withDuration: duration, animations:{ Void in
//                /// 第2页面view恢复透明度
//                toView.view.alpha=1
//                /// 获取第2页面的图片对应的frame值
//                let frame=containerView.convert(toImgView.frame, from:toImgView.superview)
//                // 让截图view的frame=第2界面的图片的frame值
//                imageSnapshot.frame=frame
//                }, completion:{ finished in
//                    //动画执行完 恢复隐藏图片  删除截图view
//                    toImgView.isHidden=false
//                    fromImgView.isHidden=false
//                    imageSnapshot.removeFromSuperview()
//                    //声明过度结束
//                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//                    //设置动画执行状态(Inexecution表示不执行)
//                    //                    isExecution = .Inexecution
//            })
//        }else if navigationOperation == UINavigationControllerOperation.pop{//当导航控制器是pop状态(主页面,跳转页面倒过来)
//
//            // 对主页面图片进行截图生成UIView
//            imageSnapshot=fromImgView.snapshotView(afterScreenUpdates: false)
//            // 设置截图view的frame位置大小
//            imageSnapshot.frame=containerView.convert(fromImgView.frame, from:fromImgView.superview!)
//            /// 隐藏主页面图片
//            fromImgView.isHidden=true
//            // 显示隐藏cell图片
//            toImgView.isHidden=true
//            // 现在初始化第2页面一开始状态
//            toView.view.frame=transitionContext.finalFrame(for: toView)
//            //把第2页面添加进过度动画处理view中
//            containerView.insertSubview(toView.view, belowSubview:fromView.view)
//            //把截图view也添加进来
//            containerView.addSubview(imageSnapshot)
//            /**
//            *  执行动画
//            */
//            UIView.animate(withDuration: duration, animations:{ Void in
//                //设置主页面view的透明度为0
//                fromView.view.alpha=0
//                /// 获取第2页面的图片对应的frame值
//                imageSnapshot.frame=containerView.convert(toImgView.frame, from:toImgView.superview)
//                }, completion:{ finished in
//                    //动画执行完 恢复隐藏图片  删除截图view
//                    imageSnapshot.removeFromSuperview()
//                    fromImgView.isHidden=false
//                    toImgView.isHidden=false
//                    //声明过度结束
//                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//                    //设置动画执行状态(Inexecution表示不执行)
//                    //                    isExecution = .Inexecution
//            })
//
//        }
//
//    }
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 0.3
//    }
//}

