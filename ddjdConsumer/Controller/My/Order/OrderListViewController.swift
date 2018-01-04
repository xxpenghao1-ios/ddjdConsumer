//
//  OrderListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/24.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///订单list
class OrderListViewController:BaseViewController{
    ///订单状态 0 全部订单 1. 待付款 2-待发货，3 已发货，4-已经完成 5. 申请退货，6 已退货
    var orderStatus:Int?
    //告诉page页面切换
    var pageSelectIndexClosure:((_ index:Int) -> Void)?
    @IBOutlet weak var table: UITableView!
    private var orderArr=[OrderEntity]()
    private var pageNumber=1
    //支付方式图片
    private var payImgArr=["wx","alipay","balance_money"]
    private var payTitle=["微信支付","支付宝支付","余额支付"]
    ///保存用户余额
    private var memberBalanceMoney:Double?
    ///保存平台折扣
    private var memberDiscount:Int?
    //获取配送费
    private var deliveryFee=userDefaults.object(forKey:"deliveryFee") as? Int ?? 0
    //支付透明view
    private var payView:UIView!
    //支付table
    private var payTableView:UITableView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryMemberBalanceMoney()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        self.getOrderList(pageSize:10, pageNumber:self.pageNumber, orderStatus: self.orderStatus!, isRefresh:true)
        table.mj_header=PHNormalHeader(refreshingBlock: {
            self.pageNumber=1
            self.getOrderList(pageSize:10, pageNumber:self.pageNumber, orderStatus: self.orderStatus!, isRefresh:true)
        })
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.getOrderList(pageSize:10, pageNumber:self.pageNumber, orderStatus: self.orderStatus!, isRefresh:false)
        })
        table.mj_footer.isHidden=true
        //接收通知刷新页面
        NotificationCenter.default.addObserver(self, selector:#selector(updateOrderList), name: notificationOrderListrefresh, object:nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
///设置页面
extension OrderListViewController{
    private func setUpView(){
        if orderStatus == 0{
            self.title="全部"
        }else if orderStatus == 1{
            self.title="待付款"
        }else if orderStatus == 2{
            self.title="待发货"
        }else if orderStatus == 3{
            self.title="已发货"
        }else if orderStatus == 4{
            self.title="已完成"
        }
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        self.table.tag=100
        self.table.emptyDataSetSource=self
        self.table.emptyDataSetDelegate=self
        self.table.tableFooterView=UIView(frame: CGRect.zero)
        self.setEmptyDataSetInfo(text:"一个订单都没有")
        self.setLoadingState(isLoading:true)
    }
    private func reloadTable(){
        self.setLoadingState(isLoading:false)
        self.table.reloadData()
        self.table.mj_footer.endRefreshing()
        self.table.mj_header.endRefreshing()
    }
    ///显示支付view
    private func showPayView(tag:Int){
        payView=UIView(frame:CGRect.init(x:0, y:-(navHeight+44),width:boundsWidth, height:boundsHeight-bottomSafetyDistanceHeight))
        self.payView.backgroundColor = UIColor.init(white:0, alpha:0.5)
        self.view.addSubview(payView)
        payTableView=UITableView(frame:CGRect.init(x:20,y:-(50+self.payImgArr.count*50),width:Int(boundsWidth-40), height:50+self.payImgArr.count*50),style:UITableViewStyle.plain)
        payTableView.delegate=self
        payTableView.tag=tag
        payTableView.dataSource=self
        payTableView.isScrollEnabled=false
        payTableView.layer.cornerRadius=5
        payTableView.separatorColor=UIColor.gray
        payView.addSubview(payTableView)
        UIView.animate(withDuration:0.5, delay:0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.payTableView.center=self.payView.center
        })
    }
    ///隐藏支付view
    @objc private func hidePayView(){
        UIView.animate(withDuration:0.5, delay:0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.payTableView.center=CGPoint.init(x:self.payTableView.center.x,y:-75)
        }, completion: { (b) in
            UIView.animate(withDuration:0.1, delay:0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.payView.isHidden=true
            }, completion:{ (b) in
                self.payTableView.removeFromSuperview()
                self.payView.removeFromSuperview()
            })
        })
    }
    ///支付header
    private func setPayCellHeaderView(view:UITableViewHeaderFooterView,section:Int) -> UITableViewHeaderFooterView{
        let entity=orderArr[section]
        ///只有一个头部  不需要考虑重用问题
        let lblSelectedPayTitle=UILabel.buildLabel(textColor: UIColor.black, font:15, textAlignment: NSTextAlignment.left)
        lblSelectedPayTitle.text="请选择支付方式"
        let lblSelectedPayTitleSize=lblSelectedPayTitle.text!.textSizeWithFont(font:lblSelectedPayTitle.font, constrainedToSize: CGSize.init(width:200, height: 20))
        lblSelectedPayTitle.frame=CGRect.init(x:15, y:15, width:lblSelectedPayTitleSize.width, height:20)
        view.addSubview(lblSelectedPayTitle)
        
        let lblPayPrice=UILabel.buildLabel(textColor:UIColor.color666(), font:13, textAlignment: NSTextAlignment.left)
        lblPayPrice.text="支付金额:"
        let lblPayPriceSize=lblPayPrice.text!.textSizeWithFont(font:lblPayPrice.font, constrainedToSize: CGSize.init(width:200, height: 20))
        lblPayPrice.frame=CGRect.init(x:lblSelectedPayTitle.frame.maxX+5, y:15, width:lblPayPriceSize.width, height:20)
        view.addSubview(lblPayPrice)
        
        let lblPayPriceValue=UILabel.buildLabel(textColor:UIColor.applicationMainColor(), font:13,textAlignment:NSTextAlignment.left)
        entity.orderPrice=entity.orderPrice ?? 0.0
        lblPayPriceValue.text="￥\(entity.orderPrice!)"
        let lblPayPriceValueSize=lblPayPriceValue.text!.textSizeWithFont(font:lblPayPriceValue.font, constrainedToSize: CGSize.init(width:200, height: 20))
        lblPayPriceValue.frame=CGRect.init(x:lblPayPrice.frame.maxX, y:15, width: lblPayPriceValueSize.width, height:20)
        view.addSubview(lblPayPriceValue)
        
        let cancelImgView=UIImageView(frame: CGRect.init(x:boundsWidth-40-35, y:15, width:20, height:20))
        cancelImgView.image=UIImage.init(named:"cancel")
        cancelImgView.isUserInteractionEnabled=true
        cancelImgView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(hidePayView)))
        view.addSubview(cancelImgView)
        
        let borderView=UIView(frame: CGRect.init(x:0, y:49.5, width:boundsWidth-40, height:0.5))
        borderView.backgroundColor=UIColor.gray
        view.addSubview(borderView)
        return view
    }
    ///订单头部
    private func setCellHeaderView(view:UITableViewHeaderFooterView,entity:OrderEntity) -> UITableViewHeaderFooterView{
        
        var orderSN=view.viewWithTag(111) as? UILabel
        if orderSN == nil{
            orderSN=UILabel(frame:CGRect(x:15,y:20,width:boundsWidth-30,height: 20))
            orderSN!.font=UIFont.systemFont(ofSize: 15)
            orderSN!.tag=111
            view.contentView.addSubview(orderSN!)
        }
//        var name=view.viewWithTag(222) as? UILabel
//        if name == nil{
//            name=UILabel.buildLabel(textColor:UIColor.applicationMainColor(), font:15, textAlignment: NSTextAlignment.right)
//            name?.frame=CGRect(x:orderSN!.frame.maxX+10,y:20,width:60,height: 20)
//            name?.tag=222
//            view.contentView.addSubview(name!)
//        }
        var bottomBorderView=view.viewWithTag(999)
        if bottomBorderView == nil{
            bottomBorderView=UIView(frame:CGRect(x:0,y:0,width:boundsWidth,height:5))
            bottomBorderView!.backgroundColor=UIColor.viewBackgroundColor()
            bottomBorderView!.tag=999
            view.contentView.addSubview(bottomBorderView!)
        }
        orderSN!.text="订单号:\(entity.orderSN ?? "")"
//        if entity.orderStatus == 1{
//            name?.text="待付款"
//        }else if entity.orderStatus == 2{
//            name?.text="待发货"
//        }else if entity.orderStatus == 3{
//            name?.text="待收货"
//        }else if entity.orderStatus == 4{
//            name?.text="已完成"
//        }
        return view
    }
    ///订单cell尾部
    private func setCellFooterView(view:UITableViewHeaderFooterView,section:Int) -> UITableViewHeaderFooterView{
        let entity=self.orderArr[section]
        ///订单价格
        var lblOrderPrice=view.viewWithTag(11) as? UILabel
        if lblOrderPrice == nil{
            lblOrderPrice=UILabel.buildLabel(textColor:UIColor.color666(),font:14, textAlignment: NSTextAlignment.right)
            lblOrderPrice!.frame=CGRect(x: 0,y: 10,width: boundsWidth-15,height: 20)
            lblOrderPrice!.tag=11
            view.contentView.addSubview(lblOrderPrice!)
        }
        //商品总数量
        var lblGoodCount=view.viewWithTag(22) as? UILabel
        if lblGoodCount == nil{
            lblGoodCount=UILabel.buildLabel(textColor:UIColor.color666(), font:14, textAlignment: NSTextAlignment.left)
            lblGoodCount!.frame=CGRect.init(x:15,y:10, width:200, height:20)
            lblGoodCount!.tag=22
            view.contentView.addSubview(lblGoodCount!)
        }
        //订单价格
        entity.orderPrice=entity.orderPrice ?? 0.0
        let orderPrice="实付:￥\(entity.orderPrice!)"
        lblOrderPrice!.attributedText=UILabel.setAttributedText(str:orderPrice, textColor:UIColor.applicationMainColor(), font:14, range:NSRange.init(location:3,length:orderPrice.count-3))
        //商品数量
        if entity.goodsAmount != nil{
            let goodCount="共计\(entity.goodsAmount!)件商品"
            lblGoodCount!.attributedText=UILabel.setAttributedText(str:goodCount, textColor:UIColor.applicationMainColor(), font:14, range: NSRange.init(location:2,length:goodCount.count-5))
        }
        ///按钮带的参数
        let dic=NSDictionary.init(dictionary:["section":section])
        //订单详情按钮
        var btnOrderDetails=view.viewWithTag(33) as? UIButton
        if btnOrderDetails == nil{
            btnOrderDetails=buildBtn(text:"订单详情", tag:33, action:#selector(pushOrderDetails), frame: CGRect.init(x:boundsWidth-95,y: lblOrderPrice!.frame.maxY+5,width: 80,height: 30), dic:dic)
            view.contentView.addSubview(btnOrderDetails!)
        }
        ///去付款
        var btnGoToThePayment=view.viewWithTag(44) as? UIButton
        if btnGoToThePayment == nil{
            btnGoToThePayment=buildBtn(text:"付款", tag:44, action:#selector(goToThePayment), frame: CGRect(x: boundsWidth-185,y: btnOrderDetails!.frame.origin.y,width: 80,height: 30), dic: dic)
            view.contentView.addSubview(btnGoToThePayment!)
        }
        btnGoToThePayment!.isHidden=true
        ///取消订单
        var btnCancelOrder=view.viewWithTag(55) as? UIButton
        if btnCancelOrder == nil{
            btnCancelOrder=buildBtn(text:"取消订单", tag:55, action:#selector(cancelOrder), frame: CGRect.init(x:boundsWidth-275,y:btnOrderDetails!.frame.origin.y, width: 80, height:30), dic:dic)
            view.contentView.addSubview(btnCancelOrder!)
        }
        btnCancelOrder!.isHidden=true
        ///确认收货
        var btnConfirmTheGoods=view.viewWithTag(66) as? UIButton
        if btnConfirmTheGoods == nil{
            btnConfirmTheGoods=buildBtn(text:"确认收货", tag:66, action:#selector(confirmTheGoods), frame:CGRect(x: boundsWidth-185,y: btnOrderDetails!.frame.origin.y,width:80,height:30),dic:dic)
            view.contentView.addSubview(btnConfirmTheGoods!)
        }
        btnConfirmTheGoods!.isHidden=true
        entity.orderStatus=entity.orderStatus ?? 0
        switch entity.orderStatus! {
        case 1:
            btnCancelOrder!.isHidden=false
            btnGoToThePayment!.isHidden=false
            break
        case 3:
            btnConfirmTheGoods!.isHidden=false
        default:
            break
        }
        return view
    }
    ///创建按钮
    private func buildBtn(text:String,tag:Int,action:Selector,frame:CGRect,dic:NSDictionary) -> UIButton{
        let btnBorderColor=UIColor.borderColor().cgColor
        let btn=UIButton.button(type:.cornerRadiusButton, text:text, textColor:UIColor.applicationMainColor(), font:14, backgroundColor: UIColor.white, cornerRadius:5)
        btn.frame=frame
        btn.tag=tag
        btn.layer.borderWidth=1
        btn.layer.borderColor=btnBorderColor
        btn.paramDic=dic
        btn.addTarget(self,action:action, for: UIControlEvents.touchUpInside)
        return btn
    }
}
///页面逻辑操作
extension OrderListViewController{
    ///更新页面数据
    @objc private func updateOrderList(notification:NSNotification){
        self.table.mj_header.beginRefreshing()
    }
    ///跳转到订单详情
    @objc private func pushOrderDetails(sender:UIButton){
        let dic=sender.paramDic
        if dic != nil{
            let section=dic!["section"] as! Int
            let entity=orderArr[section]
            let vc=self.storyboardPushView(type:.shoppingCar, storyboardId:"OrderDetailsVC") as! OrderDetailsViewController
            vc.orderId=entity.orderId
            self.navigationController?.pushViewController(vc, animated:true)
        }
    }
    ///去付款
    @objc private func goToThePayment(sender:UIButton){
        let dic=sender.paramDic
        if dic != nil{
            let section=dic!["section"] as! Int
            showPayView(tag:section)
        }
    }
    ///取消订单
    @objc private func cancelOrder(sender:UIButton){
        let dic=sender.paramDic
        if dic != nil{
            let section=dic!["section"] as! Int
            let entity=self.orderArr[section]
            self.removeOrder(orderId:entity.orderId ?? 0)
        }
    }
    ///确认收货
    @objc private func confirmTheGoods(sender:UIButton){
        let dic=sender.paramDic
        if dic != nil{
            let section=dic!["section"] as! Int
            let entity=self.orderArr[section]
            self.orderConfirmTheGoods(orderId:entity.orderId ?? 0)
        }
    }
}
//网络请求
extension OrderListViewController{
    //orderStatus 订单状态 ‘1. 待付款 2-待发货，3 已发货，4-已经完成 5. 申请退货，6 已退货
    private func getOrderList(pageSize:Int,pageNumber:Int,orderStatus:Int,isRefresh:Bool){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryOrderPaginate(memberId: MEMBERID, orderStatus: orderStatus, pageSize: pageSize, pageNumber: pageNumber), successClosure: { (json) in
            if isRefresh{
                self.orderArr.removeAll()
            }
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:OrderEntity.init(), object: value.object)
                var goodList=[GoodEntity]()
                for(_,goodValue) in value["goodsList"]{
                    let goodEntity=self.jsonMappingEntity(entity:GoodEntity.init(), object:goodValue.object)
                    goodList.append(goodEntity!)
                }
                entity!.goodsList=goodList
                self.orderArr.append(entity!)
            }
            if self.orderArr.count < json["totalRow"].intValue{
                self.table.mj_footer.isHidden=false
            }else{
                self.table.mj_footer.isHidden=true
            }
            self.reloadTable()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.reloadTable()
        }
    }
    
    ///去付款 payType 1微信支付 2支付宝支付 4余额支付
    private func payOrder(payType:Int,orderId:Int,memberbalancePaySumPrice:String){
        self.showSVProgressHUD(status:"正在加载中...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.pendingPaymentSubmit(orderId:orderId, memberId:MEMBERID, platform: 2, payType:payType,memberbalancePaySumPrice:memberbalancePaySumPrice), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.dismissHUD {
                    if payType == 1{//微信支付
                        let charge=json["charge"]
                        let req=PayReq()
                        req.timeStamp=charge["timestamp"].uInt32Value
                        req.partnerId=charge["partnerid"].stringValue
                        req.package=charge["package"].stringValue
                        req.nonceStr=charge["noncestr"].stringValue
                        req.sign=charge["sign"].stringValue
                        req.prepayId=charge["prepayid"].stringValue
                        WXApiManager.shared.payAlertController(self, request: req, paySuccess: {
                            self.showSuccess()
                        }, payFail: {
                            self.showSVProgressHUD(status:"支付失败", type: HUD.error)
                        })
                    }else if payType == 2{//支付宝支付
                        let orderString=json["charge"]["orderString"].stringValue
                        AliPayManager.shared.payAlertController(self, request:orderString, paySuccess: {
                            self.showSuccess()
                        }, payFail: {
                            self.showSVProgressHUD(status:"支付失败", type: HUD.error)
                        })
                    }else if payType == 4{//余额支付
                        self.showSuccess()
                    }
                }
            }else if success == "notExist"{
                self.showSVProgressHUD(status:"订单不存在", type: HUD.error)
            }else if success == "notPendingPayment"{
                self.showSVProgressHUD(status:"订单此订单不是待付款订单", type: HUD.error)
            }else{
                self.showSVProgressHUD(status:"提交订单失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///谈出成功提示
    private func showSuccess(){
        UIAlertController.showAlertYes(self, title:"", message:"支付成功", okButtonTitle:"确定", okHandler: { (action) in
            //跳转到下一页面
            self.pageSelectIndexClosure?(2)
        })
    }
    ///取消订单
    private func removeOrder(orderId:Int){
        self.showSVProgressHUD(status:"正在加载中...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.removeOrder(orderId:orderId, memberId:MEMBERID), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"订单取消成功", type: HUD.success)
                ///通知页面刷新数据
                NotificationCenter.default.post(name:notificationOrderListrefresh, object: self,userInfo:nil)
            }else{
                self.showSVProgressHUD(status:"订单取消失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: .error)
        }
    }
    ///确认收货
    private func orderConfirmTheGoods(orderId:Int){
        self.showSVProgressHUD(status:"正在加载中...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target: CarApi.updateMemberOrderInfoStatusThe4(orderId:orderId, memberId:MEMBERID), successClosure: { (json) in
            print(json)
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"收货成功", type: HUD.success)
                //跳转到已完成页面
                self.pageSelectIndexClosure?(4)
            }else{
                self.showSVProgressHUD(status:"收货失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: .error)
        }
    }
    ///获取用户余额
    private func queryMemberBalanceMoney(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryMemberBalanceMoney(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description)), successClosure: { (json) in
            let success=json["success"].string
            if success == "success"{
                self.memberBalanceMoney=json["memberBalanceMoney"].double
                self.memberDiscount=json["memberDiscount"].int
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
///table协议
extension OrderListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag != 100{//支付
            var cell=payTableView.dequeueReusableCell(withIdentifier:"payId")
            if cell == nil{
                cell=UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier:"payId")
            }
            cell!.textLabel!.font=UIFont.systemFont(ofSize: 14)
            cell!.textLabel!.text=payTitle[indexPath.row]
            cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:13)
            cell!.imageView!.image=UIImage.init(named:payImgArr[indexPath.row])?.reSizeImage(reSize: CGSize.init(width:30, height:30))
            cell!.accessoryType = .disclosureIndicator
            if indexPath.row == 2{
                if self.memberDiscount != nil{
                    cell!.textLabel!.text=payTitle[indexPath.row]+"(\(self.memberDiscount!)折)"
                }
                cell!.detailTextLabel!.text="(剩余￥\(self.memberBalanceMoney ?? 0))"
            }
            return cell!
        }else{//订单
            var cell=table.dequeueReusableCell(withIdentifier:"orderId") as? OrderListTableViewCell
            if cell == nil{
                cell = getXibClass(name:"OrderListTableViewCell", owner:self) as? OrderListTableViewCell
            }
            if orderArr.count > 0{
                let orderEntity=orderArr[indexPath.section]
                if orderEntity.goodsList != nil{
                    cell!.updateCell(entity:orderEntity.goodsList![indexPath.row])
                }
            }
            return cell!
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag != 100{
            return 1
        }
        return orderArr.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag != 100{
            return payImgArr.count
        }else{
            if orderArr.count > 0{
                if orderArr[section].goodsList != nil{
                    return orderArr[section].goodsList!.count
                }
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag != 100{
            return 50
        }
        return 120
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag != 100{
            return 50
        }else{
            if orderArr.count > 0{
                return 55
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView.tag == 100{
            if orderArr.count > 0{
                return 75
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 100{
            var view=table.dequeueReusableHeaderFooterView(withIdentifier:"headerId")
            if orderArr.count > 0{
                let entity=orderArr[section]
                if view == nil{
                    view=UITableViewHeaderFooterView(reuseIdentifier:"headerId")
                    view?.contentView.backgroundColor=UIColor.white
                }
                return setCellHeaderView(view:view!, entity: entity)
            }
        }else{
           var view=payTableView.dequeueReusableHeaderFooterView(withIdentifier:"payHeaderId")
                if view == nil{
                    view=UITableViewHeaderFooterView(reuseIdentifier:"payHeaderId")
                    view?.contentView.backgroundColor=UIColor.white
                }
            ///这里的section的是order订单section
            return setPayCellHeaderView(view:view!,section:payTableView.tag)
        }
        return nil
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView.tag == 100{
            var view=table.dequeueReusableHeaderFooterView(withIdentifier:"footerId")
            if orderArr.count > 0{
                view=UITableViewHeaderFooterView(reuseIdentifier:"footerId")
                view?.contentView.backgroundColor=UIColor.white
                return setCellFooterView(view:view!,section:section)
            }
        }
        return nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag != 100{
            let entity=self.orderArr[tableView.tag]
            //取消选中效果颜色
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.row == 0{
                self.payOrder(payType:1, orderId:entity.orderId ?? 0, memberbalancePaySumPrice:entity.orderPrice!.description)
            }else if indexPath.row == 1{
                self.payOrder(payType:2, orderId:entity.orderId ?? 0, memberbalancePaySumPrice:entity.orderPrice!.description)
            }else if indexPath.row == 2{
                self.balanceMoneyPay(entity:entity)
            }
            self.hidePayView()
        }
    }
}
///余额支付
extension OrderListViewController{
    ///余额支付
    private func balanceMoneyPay(entity:OrderEntity){
        ///计算折扣价
        var memberDiscountPrice=PriceComputationsUtil.decimalNumberWithString(multiplierValue:(entity.orderPrice ?? 0.0).description, multiplicandValue:(Double(memberDiscount ?? 100)/100).description,type:ComputationsType.multiplication,position:2)
        ///加上配送费
        memberDiscountPrice=PriceComputationsUtil.decimalNumberWithString(multiplierValue:memberDiscountPrice, multiplicandValue:deliveryFee.description, type: ComputationsType.addition, position:2)
        if self.memberBalanceMoney == nil || self.memberBalanceMoney! < Double(memberDiscountPrice)!{//如果余额为空 或者余额小于支付金额 需要用户去充值
            let vc=self.storyboardPushView(type:.my, storyboardId:"BalanceMoneyTopUpVC") as! BalanceMoneyTopUpViewController
            self.navigationController?.pushViewController(vc, animated:true)
        }else{//去支付
            ///获取支付密码
            let payPw=userDefaults.object(forKey:"payPw") as? String
            if payPw == nil{//提示用户设置支付密码
                UIAlertController.showAlertYesNo(self, title:"温馨提示", message:"您还没有设置支付密码,为确保您余额安全,请设置支付密码。", cancelButtonTitle:"取消",okButtonTitle:"设置支付密码", okHandler: { (action) in
                    let vc=self.storyboardPushView(type:.my, storyboardId:"SetThePaymentPasswordVC") as! SetThePaymentPasswordViewController
                    self.navigationController?.pushViewController(vc, animated:true)
                },cancelHandler:{ (action) in

                })
            }else{//输入支付密码
                self.showPayAlert(payPw:payPw,orderId:entity.orderId ?? 0,memberDiscountPrice:memberDiscountPrice)
            }
        }
    }

    /// 输入支付密码
    ///
    /// - Parameter payPw:本地支付密码
    private func showPayAlert(payPw:String?,orderId:Int,memberDiscountPrice:String){
        let payAlert = PayAlert.init(frame:UIScreen.main.bounds,price:memberDiscountPrice,view:self.view)
        payAlert.completeBlock = {(password) -> Void in
            ///密码*2 MD5加密 转大写
            let pw=(Int(password)!*2).description.MD5().uppercased()
            if pw != payPw{
                UIAlertController.showAlertYesNo(self, title:"", message:"支付密码错误,请重试", cancelButtonTitle:"忘记密码", okButtonTitle:"重试", okHandler: { (action) in
                    self.showPayAlert(payPw:payPw, orderId:orderId, memberDiscountPrice:memberDiscountPrice)
                }, cancelHandler: { (action) in
                    let vc=self.storyboardPushView(type:.my, storyboardId:"SetThePaymentPasswordVC") as! SetThePaymentPasswordViewController
                    self.navigationController?.pushViewController(vc, animated:true)
                })
            }else{//支付密码输入正确
                self.payOrder(payType:4,orderId:orderId,memberbalancePaySumPrice: memberDiscountPrice)
            }
        }
    }
}
