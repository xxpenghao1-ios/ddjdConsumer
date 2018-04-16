//
//  MyViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/13.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Kingfisher
///个人中心
class MyViewController:BaseViewController{
    //table
    @IBOutlet weak var table: UITableView!
    //订单
    private var orderCollection:UICollectionView!
    //会员头像
    private var memberImg:UIImageView!
    //会员名称
    private var lblMemberName:UILabel!
    //名称数组
    private let nameArr=["我的信息","余额明细","地址管理","我的收藏","购买历史","意见反馈","解绑门店","我的门店"]//["门店授权"]  消费者登录的时候 如果已经获得门店授权storeAuthStatu=1 展示门店授权
    //图片数组
    private let imgArr=["my_info","my_balance_record","my_address","my_sc","my_history","my_opinion","my_relieve_store","my_store"]
    //订单名称
    private let orderNameArr=["全部","待付款","待发货","待收货","已完成"]
    //订单图标
    private let orderImgArr=["order_all","order_dfk","order_dfh","order_dsh","order_ywc"]
    //待付款订单数量
    private var paymentPendingOrderCount=0
    //待收货订单数量
    private var forTheGoodsOrderCount=0
    //待发货订单数量
    private var toSendTheGoodsOrderCount=0
    //用于header背景拉伸效果
    private var topView:UIView!
    //会员vip标识图片
    private var vipImg:UIImageView!
    private var flag=false
    ///保存会员信息
    private var memberEntity:MemberEntity?{
        willSet{
            if newValue != nil{
                if newValue!.nickName != nil{//如果有会员昵称
                    lblMemberName.text=newValue!.nickName
                }else{//如果没有显示会员账号
                    lblMemberName.text=newValue!.account
                }
                let memberNameSize=lblMemberName.text!.textSizeWithFont(font:UIFont.systemFont(ofSize:15), constrainedToSize: CGSize.init(width:300, height: 20))
                lblMemberName.frame=CGRect.init(x:(boundsWidth-30-memberNameSize.width)/2, y: memberImg.frame.maxY+10,width: memberNameSize.width, height:20)
                vipImg.frame=CGRect.init(x:lblMemberName.frame.origin.x-20, y:  memberImg.frame.maxY+10, width:20, height:20)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavColor()
        if MEMBERID == -1{
            self.reinstateNavColor()
            self.present(UINavigationController.init(rootViewController:app.returnLoginVC()), animated:true, completion:nil)

        }else{
            ///查询会员信息
            getMember()
            if flag{
                ///查询订单数量
                queryOrderNum()
            }
            flag=true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.reinstateNavColor()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        queryOrderNum()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //获取偏移量
        let offset = scrollView.contentOffset;
        //判断是否改变
        if (offset.y < 0) {
            var rect = self.topView.frame;
            //我们只需要改变view的y值和高度即可
            rect.origin.y = offset.y;
            rect.size.height = 75 - offset.y;
            self.topView.frame = rect;
        }
    }
}
//页面设置
extension MyViewController{
    private func setUpView(){
        setUpNav()
        table.dataSource=self
        table.delegate=self
        table.tableFooterView=UIView(frame: CGRect.zero)
        table.tableHeaderView=setHeaderView()
    }
    //设置导航栏
    private func setUpNav(){
        //设置按钮
        self.navigationItem.leftBarButtonItem=UIBarButtonItem(image:UIImage(named:"setting")!.reSizeImage(reSize:CGSize(width:25, height: 25)), style: UIBarButtonItemStyle.done, target:self, action:#selector(pushSettingVC))
//       //消息按钮
//        self.navigationItem.rightBarButtonItem=UIBarButtonItem(image:UIImage(named:"news")!.reSizeImage(reSize:CGSize(width:25, height: 25)), style: UIBarButtonItemStyle.done, target:self, action:#selector(pushNewsVC))
    }
    //table头部
    private func setHeaderView() -> UIView{
        let view=UIView(frame:CGRect(x:0, y:0, width:boundsWidth, height:275))
        view.backgroundColor=UIColor.viewBackgroundColor()
        //主题颜色
        topView=UIView(frame:CGRect(x:0, y:0, width:boundsWidth, height:75))
        topView.backgroundColor=UIColor.applicationMainColor()
        view.addSubview(topView)
        //会员信息
        let infoView=UIView(frame:CGRect(x:15, y:10, width:boundsWidth-30, height:160))
        infoView.layer.cornerRadius=5
        //设置背景图片
        infoView.layer.contents=UIImage(named:"my_header_bac")?.cgImage
        infoView.backgroundColor=UIColor.clear
        view.addSubview(infoView)
        //头像
        memberImg=UIImageView(frame:CGRect(x:(infoView.frame.width-80)/2, y: 25, width: 80, height: 80))
        memberImg.image=UIImage(named:memberDefualtImg)
        memberImg.clipsToBounds=true
        memberImg.layer.cornerRadius=40
        memberImg.layer.borderColor=UIColor.applicationMainColor().cgColor
        memberImg.layer.borderWidth=4
        infoView.addSubview(memberImg)
        //会员名称
        lblMemberName=UILabel.buildLabel(textColor:UIColor.color333(), font:15, textAlignment: NSTextAlignment.center)
        infoView.addSubview(lblMemberName)
        //vip图片
        vipImg=UIImageView()
        infoView.addSubview(vipImg)

        //订单视图
        //初始化UICollectionViewFlowLayout.init对象
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize=CGSize(width:(boundsWidth-30)/5,height:75)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0;//每个相邻layout的上下
        flowLayout.minimumInteritemSpacing = 0;//每个相邻layout的左右
        orderCollection=UICollectionView(frame:CGRect(x:15,y:infoView.frame.maxY+15,width:boundsWidth-30,height:75),collectionViewLayout:flowLayout)
        orderCollection.backgroundColor=UIColor.white
        orderCollection.delegate=self
        orderCollection.dataSource=self
        orderCollection.isScrollEnabled=false
        orderCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier:"orderId")
        view.addSubview(orderCollection)
        return view
    }
}

// MARK: - table协议
extension MyViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=tableView.dequeueReusableCell(withIdentifier:"myCell")
        if cell == nil{
            cell=UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier:"myCell")
        }
        cell!.imageView?.image=UIImage(named:imgArr[indexPath.row])!.reSizeImage(reSize:CGSize(width:25, height:25))
        cell!.textLabel!.text=nameArr[indexPath.row]
        cell!.textLabel!.textColor=UIColor.color333()
        cell!.textLabel!.font=UIFont.systemFont(ofSize:15)
        cell!.accessoryType = .disclosureIndicator
        if indexPath.row == nameArr.count-1{
            if memberEntity?.storeFlag == 2{//如果不是门店
                if memberEntity?.storeAuthStatu == 2{ ///如果门店已经授权给消费者
                    cell!.textLabel!.text="门店授权"
                    cell!.imageView?.image=UIImage(named:"my_auth")!.reSizeImage(reSize:CGSize(width:25, height:25))
                }
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memberEntity?.storeAuthStatu == 2{//如果已经授权
            return nameArr.count
        }else{
            if memberEntity?.storeFlag == 1{
                return nameArr.count
            }
            return nameArr.count-1
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中效果颜色
        tableView.deselectRow(at: indexPath, animated: true)
        switch  indexPath.row{
        case 0:
            let vc=self.storyboardPushView(type:.my, storyboardId:"MyInformationVC") as! MyInformationViewController
            vc.memberInfo=memberEntity
            self.pushVC(vc:vc)
            break
        case 1:
            let vc=self.storyboardPushView(type:.my, storyboardId:"BalanceMoneyRecordVC") as! BalanceMoneyRecordViewController
            vc.partnerStatu=memberEntity?.partnerStatu
            self.pushVC(vc:vc)
            break
        case 2:
            let vc=self.storyboardPushView(type:.my, storyboardId:"AddressListVC") as! AddressListViewController
            self.pushVC(vc:vc)
            break
        case 3:
            let vc=self.storyboardPushView(type:.my, storyboardId:"MyCollectGoodVC") as! MyCollectGoodViewController
            self.pushVC(vc:vc)
            break
        case 4:
            let vc=self.storyboardPushView(type:.my, storyboardId:"PurchaseHistoryVC") as! PurchaseHistoryViewController
            self.pushVC(vc: vc)
            break
        case 5:
            let vc=self.storyboardPushView(type:.my, storyboardId:"FeedbackVC") as! FeedbackViewController
            self.pushVC(vc:vc)
            break
        case 6:
            var storeName=userDefaults.object(forKey:"storeName") as? String
            storeName=storeName ?? ""
            if memberEntity?.partnerStatu == 2{
                self.showSVProgressHUD(status:"众筹人不能解绑", type: HUD.info)
                return
            }
            if memberEntity?.storeFlag == 1{
                self.showSVProgressHUD(status:"您是店铺不能解绑", type: HUD.info)
                return
            }
            UIAlertController.showAlertYesNo(self, title:"", message:"解除绑定后将会需要重新登录并绑定门店,您确定要与[\(storeName!)]解除绑定?", cancelButtonTitle:"取消", okButtonTitle:"确定", okHandler: { (action) in
                self.unBindStore()
            })
            break
        case 7:
            if memberEntity?.storeFlag == 1{
                let vc=self.storyboardPushView(type:.store, storyboardId:"StoreIndexVC") as! StoreIndexViewController
                self.pushVC(vc:vc)
            }else{///跳转到授权功能页面
                let vc=MemberAuthViewController()
                self.pushVC(vc: vc)
            }
            break
        default:break
        }
    }
}
//订单视图协议
extension MyViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"orderId", for: indexPath)
        //图片
        var img=cell.contentView.viewWithTag(111) as? UIImageView
        if img == nil{
            img=UIImageView(frame:CGRect(x:(cell.contentView.frame.width-30)/2, y:10, width:30, height:30))
            img?.tag=111
            cell.contentView.addSubview(img!)
        }
        //数字提示按钮
        var btnBadge=cell.contentView.viewWithTag(333) as? UIButton
        if btnBadge == nil{
            btnBadge=UIButton.button(type:.button, text:"", textColor:UIColor.clear, font:1, backgroundColor: UIColor.clear, cornerRadius:nil)
            btnBadge!.tag=333
            btnBadge!.frame=CGRect(x:img!.frame.maxX+5, y:10, width:1, height:1)
            cell.contentView.addSubview(btnBadge!)
        }
        //文字
        var lblName=cell.contentView.viewWithTag(222) as? UILabel
        if lblName == nil{
            lblName=UILabel.buildLabel(textColor:UIColor.color999(), font:14, textAlignment: NSTextAlignment.center)
            lblName!.frame=CGRect(x:0,y:img!.frame.maxY+5, width:cell.contentView.frame.size.width,height:20)
            lblName!.tag=222
            cell.contentView.addSubview(lblName!)
        }
        img!.image=UIImage(named:orderImgArr[indexPath.item])
        lblName!.text=orderNameArr[indexPath.item]
        if indexPath.item == 0{
            lblName!.textColor=UIColor.applicationMainColor()
        }else{
            lblName!.textColor=UIColor.color999()
        }
        if indexPath.item == 1{
            let badge=paymentPendingOrderCount > 0 ? "\(paymentPendingOrderCount)" : ""
            btnBadge!.badgeValue=badge
        }else if indexPath.item == 2{
            let badge=toSendTheGoodsOrderCount > 0 ? "\(toSendTheGoodsOrderCount)" : ""
            btnBadge!.badgeValue=badge
        }else if indexPath.item == 3{
            let badge=forTheGoodsOrderCount > 0 ? "\(forTheGoodsOrderCount)" : ""
            btnBadge!.badgeValue=badge
        }else{
            btnBadge!.badgeValue=""
        }
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderImgArr.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var orderStatus=0
        if indexPath.item == 0{
            orderStatus=0
        }else if indexPath.item == 1{
            orderStatus=1
        }else if indexPath.item == 2{
            orderStatus=2
        }else if indexPath.item == 3{
            orderStatus=3
        }else if indexPath.item == 4{
            orderStatus=4
        }
        let vc=OrderListPageController()
        vc.orderStatus=orderStatus
        self.pushVC(vc:vc)
    }
}
//跳转页面
extension MyViewController{
    //跳转到设置页面
    @objc private func pushSettingVC(){
        let vc=self.storyboardPushView(type:.my, storyboardId:"SettingVC") as! SettingViewController
        vc.hidesBottomBarWhenPushed=true
        self.navigationController?.pushViewController(vc, animated:true)
    }
    //跳转到消息页面
    @objc private func pushNewsVC(){
        let vc=self.storyboardPushView(type:.my, storyboardId:"MyNewsVC") as! MyNewsViewController
        self.pushVC(vc:vc)
    }
    //跳转页面
    private func pushVC(vc:UIViewController){
        vc.hidesBottomBarWhenPushed=true
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
///网络请求
extension MyViewController{
    ///查询待付和待收订单数量
    private func queryOrderNum(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryOrderNum(memberId:MEMBERID), successClosure: { (json) in
            
            self.forTheGoodsOrderCount=json["daishou"].intValue
            self.paymentPendingOrderCount=json["daifu"].intValue
            self.toSendTheGoodsOrderCount=json["daifa"].intValue
            self.orderCollection.reloadData()
        }) { (error) in
            
        }
    }
    ///查询会员信息
    private func getMember(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.getMember(memberId:MEMBERID), successClosure: { (json) in
//            print(json)
            self.memberEntity=self.jsonMappingEntity(entity:MemberEntity.init(), object:json.object)
            if self.memberEntity!.vipStatu == 2{
                self.vipImg.image=UIImage.init(named:"member_vip")
            }
            if self.memberEntity!.partnerStatu == 2{
                self.vipImg.image=UIImage.init(named:"my_hhr")
            }

            JPUSHService.getAllTags({ (c, setAll, q) in

            if self.memberEntity!.storeAuthStatu == 2{
                if setAll?.count == 0{//tags 为空写入tag
                    JPUSHService.setTags(["s_"+self.memberEntity!.bindstoreId!.description], completion: nil, seq: 11)
                }
            }else{
                ///清除tag
                JPUSHService.cleanTags(nil, seq:11)
            }

            }, seq: 11)

            userDefaults.set(self.memberEntity!.vipStatu, forKey:"vipStatu")
            userDefaults.set(self.memberEntity!.partnerStatu, forKey:"partnerStatu")
            userDefaults.set(self.memberEntity!.storeAuthStatu, forKey:"storeAuthStatu")
            userDefaults.synchronize()
            self.table.reloadData()
        }) { (error) in
            
        }
    }
    ///解绑店铺
    private func unBindStore(){
        self.showSVProgressHUD(status:"正在解除绑定...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.unBindStore(memberId:MEMBERID), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"成功解除绑定", type: HUD.success)
                userDefaults.removeObject(forKey:"memberId")
                userDefaults.synchronize()
                app.jumpToLoginVC()
            }else if success == "noBind"{//会员没有绑定店铺，不需要解绑 这里我们也提示解绑成功
                self.showSVProgressHUD(status:"成功解除绑定", type: HUD.success)
                userDefaults.removeObject(forKey:"memberId")
                userDefaults.synchronize()
                app.jumpToLoginVC()
            }else if success == "isStore"{
                self.showSVProgressHUD(status:"这个会员是店铺，不能解绑自己", type: HUD.error)
            }else if success == "partnerNotUnBind"{
                self.showSVProgressHUD(status:"会员是店铺的众筹人，不能解绑", type: HUD.error)
            }else{
                self.showSVProgressHUD(status:"解绑失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }

}
