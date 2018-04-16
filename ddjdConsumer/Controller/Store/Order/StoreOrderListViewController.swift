//
//  StoreOrderListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/13.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///订单列表
class StoreOrderListViewController:BaseViewController{
    /// 1. 待付款 2-待发货，3 已发货，4-已经完成
    var orderStatus:Int?
    private var orderArr=[OrderEntity]()
    //告诉page页面切换
    var pageSelectIndexClosure:((_ index:Int) -> Void)?
    private var pageNumber=1
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        self.queryStoreOrderInfo(pageSize:10, pageNumber:self.pageNumber, isRefresh:true)
        table.mj_header=PHNormalHeader(refreshingBlock: {
            self.pageNumber=1
            self.queryStoreOrderInfo(pageSize:10, pageNumber:self.pageNumber, isRefresh:true)
        })
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.queryStoreOrderInfo(pageSize:10, pageNumber:self.pageNumber, isRefresh:false)
        })
        table.mj_footer.isHidden=true
        //接收通知刷新页面
        NotificationCenter.default.addObserver(self, selector:#selector(updateOrderList), name: notificationStoreOrderListrefresh, object:nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension StoreOrderListViewController{
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
        self.table.dataSource=self
        self.table.delegate=self
        self.table.backgroundColor=UIColor.viewBackgroundColor()
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
    ///订单头部
    private func setCellHeaderView(view:UITableViewHeaderFooterView,entity:OrderEntity) -> UITableViewHeaderFooterView{
        
        var orderSN=view.viewWithTag(111) as? UILabel
        if orderSN == nil{
            orderSN=UILabel(frame:CGRect(x: 15,y: 20,width: 280,height: 20))
            orderSN!.font=UIFont.systemFont(ofSize: 15)
            orderSN!.tag=111
            view.contentView.addSubview(orderSN!)
        }
        var name=view.viewWithTag(222) as? UILabel
        if name == nil{
            name=UILabel.buildLabel(textColor:UIColor.applicationMainColor(), font:15, textAlignment: NSTextAlignment.right)
            name?.frame=CGRect(x:295,y: 20,width:boundsWidth-310,height: 20)
            name?.tag=222
            view.contentView.addSubview(name!)
        }
        var bottomBorderView=view.viewWithTag(999)
        if bottomBorderView == nil{
            bottomBorderView=UIView(frame:CGRect(x:0,y:0,width:boundsWidth,height:5))
            bottomBorderView!.backgroundColor=UIColor.viewBackgroundColor()
            bottomBorderView!.tag=999
            view.contentView.addSubview(bottomBorderView!)
        }
        orderSN!.text="订单号:\(entity.orderSN ?? "")"
        if entity.orderStatus == 1{
            name?.text="待付款"
        }else if entity.orderStatus == 2{
            name?.text="待发货"
        }else if entity.orderStatus == 3{
            name?.text="待收货"
        }else if entity.orderStatus == 4{
            name?.text="已完成"
        }
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
        ///发货
        var btnConfirmTheDelivery=view.viewWithTag(44) as? UIButton
        if btnConfirmTheDelivery == nil{
            btnConfirmTheDelivery=buildBtn(text:"确认发货", tag:44, action:#selector(confirmTheDelivery), frame: CGRect(x: boundsWidth-185,y: btnOrderDetails!.frame.origin.y,width: 80,height: 30), dic: dic)
            view.contentView.addSubview(btnConfirmTheDelivery!)
        }
        btnConfirmTheDelivery!.isHidden=true
        entity.orderStatus=entity.orderStatus ?? orderStatus!
        switch entity.orderStatus! {
        case 2:
            btnConfirmTheDelivery!.isHidden=false
            break
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
///页面按钮点击事件
extension StoreOrderListViewController{
    ///跳转到详情页面
    @objc private func pushOrderDetails(sender:UIButton){
        let dic=sender.paramDic
        if dic != nil{
            let section=dic!["section"] as! Int
            let entity=orderArr[section]
            let vc=self.storyboardPushView(type:.shoppingCar, storyboardId:"OrderDetailsVC") as! OrderDetailsViewController
            vc.orderId=entity.orderId
            vc.storeFlag=1
            self.navigationController?.pushViewController(vc, animated:true)
        }
    }
    ///确认发货
    @objc private func confirmTheDelivery(sender:UIButton){
        let dic=sender.paramDic
        if dic != nil{
            let section=dic!["section"] as! Int
            let entity=orderArr[section]
            self.updateStoreOrderInfoTheOrderStatus(orderId:entity.orderId ?? 0)
        }
    }
    ///刷新页面
    @objc private func updateOrderList(){
        self.table.mj_header.beginRefreshing()
    }
}
///网络请求
extension StoreOrderListViewController{
    ///查询订单数据
    private func queryStoreOrderInfo(pageSize:Int,pageNumber:Int,isRefresh:Bool){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreOrderApi.queryStoreOrderInfo(storeId:STOREID, orderStatus: orderStatus!, pageSize: pageSize, pageNumber: pageNumber), successClosure: { (json) in
            print(STOREID)
            if isRefresh{
                self.orderArr.removeAll()
            }
            for(_,value) in json{
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
    ///店铺发货
    private func updateStoreOrderInfoTheOrderStatus(orderId:Int){
        self.showSVProgressHUD(status:"正在加载...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreOrderApi.updateStoreOrderInfoTheOrderStatus(storeId:STOREID, orderId: orderId), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"发货成功", type: HUD.success)
                self.pageSelectIndexClosure?(1)
            }else if success == "orderStatusError"{
                self.showSVProgressHUD(status:"订单状态错误，不能发货", type: HUD.error)
            }else if success == "notExist"{
                self.showSVProgressHUD(status:"订单已经不存在了", type: HUD.error)
            }else if success == "notStore"{
                self.showSVProgressHUD(status:"此笔订单不属于此店铺", type: HUD.error)
            }else{
                self.showSVProgressHUD(status:"发货失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
///table协议
extension StoreOrderListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"storeOrderId") as? OrderListTableViewCell
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderArr.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if orderArr.count > 0{
            if orderArr[section].goodsList != nil{
                return orderArr[section].goodsList!.count
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if orderArr.count > 0{
            return 55
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if orderArr.count > 0{
            return 75
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
        
    }
}
