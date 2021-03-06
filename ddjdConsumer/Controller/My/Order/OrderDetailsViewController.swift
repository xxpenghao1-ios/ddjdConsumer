//
//  OrderDetailsViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/28.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///订单详情
class OrderDetailsViewController:BaseViewController{
    //接收订单id
    var orderId:Int?
    //接收订单状态
    var orderState:String?
    //店铺订单标识 如果不为空 查询店铺订单
    var storeFlag:Int?
    @IBOutlet weak var table: UITableView!
    ///收货人
    @IBOutlet weak var lblShippName: UILabel!
    ///收货人电话
    @IBOutlet weak var lblTel: UILabel!
    ///呼叫消费者
    @IBOutlet weak var callMemberImg: UIImageView!
    ///收货地址
    @IBOutlet weak var lblAddress: UILabel!
    ///买家留言
    @IBOutlet weak var lblBuyerMessage: UILabel!
    ///商品总价
    @IBOutlet weak var lblSumPrice: UILabel!
    ///优惠
    @IBOutlet weak var lblPreferentialTreatment: UILabel!
    ///配送费
    @IBOutlet weak var lblDeliveryFee: UILabel!
    //获取配送费
    private var deliveryFee=userDefaults.object(forKey:"deliveryFee") as? Int ?? 0
    ///支付方式
    @IBOutlet weak var lblPayMode: UILabel!
    ///小计
    @IBOutlet weak var lblSubtotal: UILabel!
    ///商品总数量
    @IBOutlet weak var lblGoodSumCount: UILabel!
    ///订单号
    @IBOutlet weak var lblOrderSN: UILabel!
    ///订单时间
    @IBOutlet weak var lblOrderTime: UILabel!
    ///订单状态时间text
    @IBOutlet weak var lblOrderStateTime: UILabel!
    ///订单状态时间value
    @IBOutlet weak var lblOrderStateTimeValue: UILabel!
    ///订单状态
    @IBOutlet weak var lblOrderState: UILabel!
    ///保存商品集合
    private var goodArr=[GoodEntity]()
    ///保存订单信息
    private var orderEntity:OrderDetailsEntity?{
        willSet{
            if newValue != nil{
                ///收货人姓名
                lblShippName.text=newValue!.shippName
                ///电话
                lblTel.text=newValue!.tel
                ///地址
                lblAddress.text=newValue!.shipaddress
                if newValue!.payType == 4{
                    lblPayMode.text="余额支付"
                    ///计算优惠价
                    let preferentialTreatment=PriceComputationsUtil.decimalNumberWithString(multiplierValue:(newValue!.orderOriginalPrice ?? 0).description, multiplicandValue:(newValue!.orderPrice ?? 0).description, type: ComputationsType.subtraction, position:2)
                    lblPreferentialTreatment.text="￥-\(preferentialTreatment)"
                }else{
                    lblPayMode.text=newValue!.payType==1 ? "微信支付":"支付宝支付"
                    lblPreferentialTreatment.text="￥0.0"
                }
                ///订单编号
                lblOrderSN.text=newValue!.orderSN
                ///下单时间
                lblOrderTime.text=newValue!.addTime
                ///是否有留言
                if newValue!.payMessage != nil && newValue!.payMessage! != ""{
                    lblBuyerMessage.text=newValue!.payMessage
                }else{
                    lblBuyerMessage.text="无"
                }
                if deliveryFee == 0{//如果配送费为0 隐藏
                    lblDeliveryFee.isHidden=true
                }else{
                    lblDeliveryFee.text="配送费\(deliveryFee)元"
                }
                newValue!.goodsAmount=newValue!.goodsAmount ?? 0
                ///商品数量
                let goodSumCountStr="共计\(newValue!.goodsAmount!)件商品"
                lblGoodSumCount.attributedText=UILabel.setAttributedText(str:goodSumCountStr, textColor:UIColor.applicationMainColor(), font:14, range: NSRange.init(location:2, length:goodSumCountStr.count-5))

                ///商品实付价格
                newValue!.orderPrice=newValue!.orderPrice ?? 0.0
                let subtotalStr="实付:￥\(newValue!.orderPrice!)"
                lblSubtotal.attributedText=UILabel.setAttributedText(str:subtotalStr, textColor:UIColor.applicationMainColor(), font:14, range: NSRange.init(location:3, length:subtotalStr.count-3))
                ///商品原价
                lblSumPrice.text="￥\(newValue!.orderOriginalPrice ?? 0.0)"
                if newValue!.orderStatus == 1{
                    lblOrderState.text="待付款"
                    lblOrderStateTime.text="订单失效时间:"
                    lblOrderStateTimeValue.text=newValue!.invalidTime
                }else if newValue!.orderStatus == 2{
                    lblOrderState.text="待发货"
                    lblOrderStateTime.text="支付时间:"
                    lblOrderStateTimeValue.text=newValue!.payTime
                }else if newValue!.orderStatus == 3{
                    lblOrderState.text="已发货"
                    lblOrderStateTime.text="发货时间:"
                    lblOrderStateTimeValue.text=newValue!.shipTime
                }else if newValue!.orderStatus == 4{
                    lblOrderState.text="已完成"
                    lblOrderStateTime.text="完成时间:"
                    lblOrderStateTimeValue.text=newValue!.finishedTime
                }
                ///刷新布局
                self.viewDidLayoutSubviews()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="订单详情"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        if storeFlag == nil{
            getOrderDetails()
            callMemberImg.isHidden=true
        }else{
            getStoreOrderDetails()
        }
    }
    //修改table尾部高度
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height=self.table.tableFooterView!.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame=self.table.tableFooterView!.frame
        frame.size.height=height
        self.table.tableFooterView!.frame=frame
        
    }
}
///设置页面
extension OrderDetailsViewController{
    private func setUpView(){
        self.setLoadingState(isLoading:true)
        self.table.delegate=self
        self.table.dataSource=self
        self.table.emptyDataSetSource=self
        self.table.emptyDataSetDelegate=self
        self.table.sectionFooterHeight=0
        if storeFlag != nil{//如果显示导航
            self.navigationItem.rightBarButtonItem=UIBarButtonItem.init(image:UIImage.init(named:"order_mapNav")!.reSizeImage(reSize:CGSize.init(width:25, height:25)), style: UIBarButtonItemStyle.done, target:self, action:#selector(selectedMapNav))
        }
        ///打电话
        callMemberImg.isUserInteractionEnabled=true
        callMemberImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(self.callMember)))
    }
}
///table 协议
extension OrderDetailsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"orderDetailsId") as? OrderListTableViewCell
        if cell == nil{
            cell = getXibClass(name:"OrderListTableViewCell", owner:self) as? OrderListTableViewCell
        }
        if goodArr.count > 0{
            let entity=goodArr[indexPath.row]
            cell!.updateCell(entity:entity)
        }
        return cell!
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goodArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if storeFlag == nil{
            var view=table.dequeueReusableHeaderFooterView(withIdentifier:"HeaderId")
            if view == nil{
                view=UITableViewHeaderFooterView(reuseIdentifier:"HeaderId")
                view?.contentView.backgroundColor=UIColor.white
            }
            var storeImg=view?.viewWithTag(22) as? UIImageView
            if storeImg == nil{
                storeImg=UIImageView(frame: CGRect.init(x:15, y:10, width:30,height:30))
                storeImg!.image=UIImage.init(named:"store_name")
                storeImg!.tag=22
                view!.contentView.addSubview(storeImg!)
            }
            var lblStoreName=view?.viewWithTag(11) as? UILabel
            if lblStoreName == nil{
                lblStoreName=UILabel.buildLabel(textColor:UIColor.color333(), font: 15, textAlignment: NSTextAlignment.left)
                lblStoreName!.frame=CGRect.init(x:storeImg!.frame.maxX, y:15, width:boundsWidth-125-storeImg!.frame.maxX-5, height:20)
                lblStoreName!.tag=11
                view!.contentView.addSubview(lblStoreName!)
            }
            var lblStoreTel=view?.viewWithTag(33) as? UILabel
            if lblStoreTel == nil{
                lblStoreTel=UILabel.buildLabel(textColor:UIColor.color333(), font:13, textAlignment: NSTextAlignment.right)
                lblStoreTel!.frame=CGRect.init(x:boundsWidth-105, y:15, width:90, height:20)
                lblStoreTel!.tag=33
                view!.contentView.addSubview(lblStoreTel!)
                
            }
            var storeTelImg=view?.viewWithTag(44) as? UIImageView
            if storeTelImg == nil{
                storeTelImg=UIImageView(frame: CGRect.init(x:lblStoreTel!.frame.minX-20, y: 15, width:20, height:20))
                storeTelImg!.tag=44
                storeTelImg!.image=UIImage.init(named:"order_tel")
                storeTelImg!.isUserInteractionEnabled=true
                storeTelImg!.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(callStore)))
                view!.contentView.addSubview(storeTelImg!)
            }
            if orderEntity != nil{
                lblStoreName!.text=orderEntity!.storeName
                lblStoreTel!.text=orderEntity!.storeTel
            }
            return view
        }else{
            var view=table.dequeueReusableHeaderFooterView(withIdentifier:"HeaderGoodId")
            if view == nil{
                view=UITableViewHeaderFooterView(reuseIdentifier:"HeaderGoodId")
                view?.contentView.backgroundColor=UIColor.white
            }
            var lblTitle=view?.viewWithTag(88) as? UILabel
            if lblTitle == nil{
                lblTitle=UILabel.buildLabel(textColor:UIColor.color333(), font:15, textAlignment: NSTextAlignment.left)
                lblTitle?.frame=CGRect.init(x:15, y:15, width:200, height:20)
                lblTitle?.tag=88
                view?.contentView.addSubview(lblTitle!)
            }
            lblTitle?.text="商品列表"
            return view
        }
    }
}

// MARK: - 页面逻辑方法
extension OrderDetailsViewController{
    ///呼叫店铺
    @objc private func callStore(){
        if orderEntity == nil{
            return
        }
        if orderEntity!.storeTel == nil{
            return
        }
        UIApplication.shared.openURL(Foundation.URL(string :"tel://\(orderEntity!.storeTel!)")!)
    }
    ///呼叫消费者
    @objc private func callMember(){
        if orderEntity == nil{
            return
        }
        if orderEntity!.tel == nil{
            return
        }
        UIApplication.shared.openURL(Foundation.URL(string :"tel://\(orderEntity!.tel!)")!)
    }
    ///选择地图导航 目前只有百度地图
    @objc private func selectedMapNav(){
        if self.orderEntity?.lat != nil && self.orderEntity?.lon != nil{
            let coordinate=CLLocationCoordinate2D.init(latitude: CLLocationDegrees.init(self.orderEntity!.lat!)!, longitude: CLLocationDegrees.init(self.orderEntity!.lon!)!)
            self.showAlert(coordinate:coordinate)
        }else{
            self.showSVProgressHUD(status:"没有获取到对应经纬度,不能导航", type: HUD.error)
        }

    }
    ///弹出导航选项
    private func showAlert(coordinate:CLLocationCoordinate2D){
        let alert=UIAlertController.init(title:"导航到目的地", message:"", preferredStyle: UIAlertControllerStyle.actionSheet)
        let baiduAction=UIAlertAction.init(title:"百度地图", style: UIAlertActionStyle.default) { (action) in
            if !MapNav.shared.openMapNav(coordinate:coordinate, name:self.orderEntity?.shipaddress ?? "", mapType:MapNavType.baidu){
                self.showSVProgressHUD(status:"请检测是否安装百度地图", type: HUD.error)
            }
        }
        let gaoDeAction=UIAlertAction.init(title:"高德地图", style: UIAlertActionStyle.default) { (action) in
            if !MapNav.shared.openMapNav(coordinate:coordinate, name:self.orderEntity?.shipaddress ?? "", mapType:MapNavType.gaode){
                self.showSVProgressHUD(status:"请检测是否安装高德地图", type: HUD.error)
            }
        }
        let iphoneAction=UIAlertAction.init(title:"苹果地图", style: UIAlertActionStyle.default) { (action) in
            if !MapNav.shared.openMapNav(coordinate:coordinate, name:self.orderEntity?.shipaddress ?? "", mapType:MapNavType.iPhone){
                self.showSVProgressHUD(status:"请检测是否安装苹果地图", type: HUD.error)
            }
        }
        let cancelAction=UIAlertAction.init(title:"取消", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(baiduAction)
        alert.addAction(gaoDeAction)
        alert.addAction(iphoneAction)
        alert.addAction(cancelAction)
        self.present(alert, animated:true, completion:nil)
    }
}
///网络请求
extension OrderDetailsViewController{
    ///查询消费者订单
    private func getOrderDetails(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryOrderById(orderId:orderId ?? 0), successClosure: { (json) in
            for(_,value) in json["goods"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object: value.object)
                self.goodArr.append(entity!)
            }
            self.orderEntity=self.jsonMappingEntity(entity:OrderDetailsEntity.init(), object:json["order"].object)
            self.setLoadingState(isLoading:false)
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type:HUD.error)
            self.navigationController?.popViewController(animated:true)
        }
    }
    ///查询店铺订单详情
    private func getStoreOrderDetails(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreOrderApi.queryStoreOrderInfoDetails(orderId:orderId ?? 0), successClosure: { (json) in
            print(json)
            for(_,value) in json["orderInfoGoodsListDetails"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object: value.object)
                self.goodArr.append(entity!)
            }
            self.orderEntity=self.jsonMappingEntity(entity:OrderDetailsEntity.init(), object:json["orderInfoDetails"].object)
            self.setLoadingState(isLoading:false)
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type:HUD.error)
            self.navigationController?.popViewController(animated:true)
        }
    }
}
