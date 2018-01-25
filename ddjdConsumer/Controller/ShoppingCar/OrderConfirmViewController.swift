//
//  OrderConfirmViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/15.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
//确认订单
class OrderConfirmViewController:BaseViewController{
    //接收购物车传入的商品
    var goodArr=[GoodEntity]()
    //接收商品数量
    var sumCount:Int?
    //接收传入的总金额
    var sumPrice:String?
    //保存所有地址信息
    private var addressArr=[ShippAddressEntity]()
    //收货人姓名
    @IBOutlet weak var lblShippName: UILabel!
    //电话号码
    @IBOutlet weak var lblTel: UILabel!
    //收货地址
    @IBOutlet weak var lblAddress: UILabel!
    //修改收货地址View
    @IBOutlet weak var updateAddresView: UIView!
    //table
    @IBOutlet weak var table: UITableView!
    //总金额
    @IBOutlet weak var lblSumPrice: UILabel!
    //商品总数量
    @IBOutlet weak var lblSumCount: UILabel!
    //提交订单
    @IBOutlet weak var btnSubmit: UIButton!
    //留言信息
    @IBOutlet weak var txtMessage: UITextField!
    //配送费
    @IBOutlet weak var lblDeliveryFee: UILabel!
    //获取配送费
    private var deliveryFee=userDefaults.object(forKey:"deliveryFee") as? Int ?? 0
    //商品总价格
    @IBOutlet weak var lblGoodSumPrice: UILabel!
    //支付方式图片
    private var payImgArr=["wx","alipay","balance_money"]
    private var payTitle=["微信支付","支付宝支付","余额支付"]
    //支付透明view
    private var payView:UIView!
    //支付table
    private var payTableView:UITableView!
    ///保存用户余额
    private var memberBalanceMoney:Double?
    ///保存平台折扣
    private var memberDiscount:Int?
    //保存当前地址信息
    private var addressEntity:ShippAddressEntity?{
        willSet{
            if newValue != nil{
                newValue!.shippName=newValue!.shippName ?? ""
                lblShippName.text="收货人:"+newValue!.shippName!
                lblTel.text=newValue!.phoneNumber
                newValue?.address=newValue!.address ?? ""
                newValue?.detailAddress=newValue!.detailAddress ?? ""
                lblAddress.text="收货地址:"+newValue!.address!+newValue!.detailAddress!
            }else{
                lblShippName.text="收货人:无"
                lblTel.text="手机号码"
                lblAddress.text="收货地址:无"
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ///获取用户是否有余额
        queryMemberBalanceMoney()
        if addressEntity == nil{//如果收货地址为空 发送请求
            getAllAddressInfo()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="确认订单"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        
    }
    //点击table区域收起键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.table.endEditing(true)
    }
}
///设置页面
extension OrderConfirmViewController{
    private func setUpView(){
        self.table.sectionFooterHeight=0
        ///跳转到地址list图片按钮
        updateAddresView.isUserInteractionEnabled=true
        updateAddresView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(pushAddressListVC)))
        
        txtMessage.textColor=UIColor.color999()
        
        //提交订单
        btnSubmit.addTarget(self, action:#selector(saveOrder), for: UIControlEvents.touchUpInside)
        
        let sumCountStr="共\(sumCount!)件"
        lblSumCount.attributedText=UILabel.setAttributedText(str:sumCountStr, textColor:UIColor.applicationMainColor(), font: 13, range: NSRange.init(location:1, length:sumCountStr.count-2))
        //商品小计
        let
        goodSumPriceStr="商品小计:￥\(sumPrice!)"
        lblGoodSumPrice.attributedText=UILabel.setAttributedText(str:goodSumPriceStr, textColor:UIColor.applicationMainColor(), font: 15, range: NSRange.init(location:5, length:goodSumPriceStr.count-5))
        ///商品总价加上配送费
        let sumPriceStr="总计:￥"+PriceComputationsUtil.decimalNumberWithString(multiplierValue: sumPrice!, multiplicandValue:"\(deliveryFee)", type: ComputationsType.addition, position:2)
        ///订单总价
        lblSumPrice.attributedText=UILabel.setAttributedText(str:sumPriceStr, textColor:UIColor.applicationMainColor(), font: 13, range: NSRange.init(location:3, length:sumPriceStr.count-3))
        if deliveryFee == 0{//如果配送费为0 隐藏
            lblDeliveryFee.isHidden=true
        }else{
            lblDeliveryFee.text="配送费\(deliveryFee)元"
        }
        
        setUpPayView()
    }
    ///显示添加收货地址
    private func showAddAddressView(){
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(title:"添加地址", style: UIBarButtonItemStyle.done, target:self, action:#selector(pushAddressListVC))
    }
    ///隐藏添加收货地址
    private func hideAddAddressView(){
        self.navigationItem.rightBarButtonItem=nil
    }
    //设置支付view
    private func setUpPayView(){
        payView=UIView(frame:CGRect.init(x:0, y:-navHeight,width:boundsWidth, height:boundsHeight))
        self.payView.backgroundColor = UIColor.init(white:0, alpha:0.5)
        self.view.addSubview(payView)
        payTableView=UITableView(frame:CGRect.init(x:20,y:-(50+self.payImgArr.count*50),width:Int(boundsWidth-40), height:50+self.payImgArr.count*50),style:UITableViewStyle.plain)
        payTableView.delegate=self
        payTableView.dataSource=self
        payTableView.tag=100
        payTableView.isScrollEnabled=false
        payTableView.layer.cornerRadius=5
        payTableView.separatorColor=UIColor.lightGray
        payView.addSubview(payTableView)
        payView.isHidden=true
    }
    ///显示支付view
    private func showPayView(){
        self.payView.isHidden=false
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
            }, completion: nil)
        })
    }
}
///点击事件
extension OrderConfirmViewController{
    ///跳转到收货地址列表
    @objc private func pushAddressListVC(){
        self.addressEntity=nil
        let vc=self.storyboardPushView(type:.my, storyboardId:"AddressListVC") as! AddressListViewController
        vc.isSelectedAddressInfo=1
        vc.addressInfoClosure={ (entity) in
            self.addressEntity=entity
            if self.addressEntity != nil{
                self.hideAddAddressView()
            }
        }
        self.navigationController?.pushViewController(vc, animated:true)
    }
    ///提交订单
    @objc private func saveOrder(){
        if addressEntity?.shippAddressId == nil{
            self.showSVProgressHUD(status:"请选择收货地址", type: HUD.info)
            return
        }
        self.showPayView()
    }
    ///跳转到订单列表
    private func pushOrderList(orderStatus:Int){
        let vc=OrderListPageController()
        vc.orderStatus=orderStatus
        vc.popFlag=1
        self.navigationController?.pushViewController(vc, animated:true)
    }
    ///查看订单
    private func checkOrder(){
        UIAlertController.showAlertYesNo(self, title:"", message:"下单成功,我们尽快帮您送货上门", cancelButtonTitle: "返回", okButtonTitle:"查看订单", okHandler: { (action) in
            //通知tab页面更新购物车角标
            NotificationCenter.default.post(name:updateCarBadgeValue,object:nil)
            self.pushOrderList(orderStatus:2)
            
        }, cancelHandler: { (action) in
            self.navigationController?.popViewController(animated:true)
        })
    }
}
///网络请求
extension OrderConfirmViewController{

    /// 请求地址信息
    private func getAllAddressInfo(){
        self.addressArr.removeAll()
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.getAllShippaddress(memberId:MEMBERID), successClosure: { (json) in
            for(_,value) in json{
                let entity=self.jsonMappingEntity(entity:ShippAddressEntity.init(), object: value.object)
                if entity!.defaultFlag == 1{//保存默认地址
                    self.addressEntity=entity
                }
                self.addressArr.append(entity!)
            }
            if self.addressEntity == nil{//如果没有默认地址 选择数组第一个地址
                if self.addressArr.count > 0{
                    self.addressEntity=self.addressArr[0]
                    //隐藏添加收货地址
                    self.hideAddAddressView()
                }else{
                    //显示添加收货地址
                    self.showAddAddressView()
                }
            }else{
                //隐藏添加收货地址
                self.hideAddAddressView()
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    //下单 payType 1微信支付 2支付宝 4余额
    private func payOrder(payType:Int,sumPrice:String){
        self.showSVProgressHUD(status:"请稍后...", type: HUD.textClear)
        let payMessage=txtMessage.text ?? ""
        ///加上配送费
        let moblieSumPrice=PriceComputationsUtil.decimalNumberWithString(multiplierValue: sumPrice,multiplicandValue:"\(deliveryFee)", type: ComputationsType.addition, position:2)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.saveOrder(memberId:MEMBERID, shipaddressId:addressEntity!.shippAddressId!, platform:2, payType:payType, moblieSumPrice:moblieSumPrice,payMessage:payMessage), successClosure: { (json) in

            let success=json["success"].stringValue
            if success == "success"{
                self.dismissHUD {
                    if payType == 1{
                        let charge=json["charge"]
                        let req=PayReq()
                        req.timeStamp=charge["timestamp"].uInt32Value
                        req.partnerId=charge["partnerid"].stringValue
                        req.package=charge["package"].stringValue
                        req.nonceStr=charge["noncestr"].stringValue
                        req.sign=charge["sign"].stringValue
                        req.prepayId=charge["prepayid"].stringValue
                        WXApiManager.shared.payAlertController(self, request: req, paySuccess: {
                           self.checkOrder()
                        }, payFail: {
                            UIAlertController.showAlertYesNo(self, title:"提示", message:"支付失败", cancelButtonTitle: "返回", okButtonTitle:"查看失败订单", okHandler: { (action) in
                                self.pushOrderList(orderStatus:1)
                            }, cancelHandler: { (action) in
                                self.navigationController?.popViewController(animated:true)
                            })
                        })
                    }else if payType == 2{
                        let orderString=json["charge"]["orderString"].stringValue
                        AliPayManager.shared.payAlertController(self, request:orderString, paySuccess: {
                            self.checkOrder()
                        }, payFail: {
                            UIAlertController.showAlertYesNo(self, title:"提示", message:"支付失败", cancelButtonTitle: "返回", okButtonTitle:"查看失败订单", okHandler: { (action) in
                                self.pushOrderList(orderStatus:1)
                            }, cancelHandler: { (action) in
                                self.navigationController?.popViewController(animated:true)
                            })
                        })
                    }else if payType == 4{
                        self.checkOrder()
                    }
                }
            }else if success == "orderRepeat"{
                self.dismissHUD {
                    UIAlertController.showAlertYesNo(self, title:"", message:"您存在待付款订单,请先支付", cancelButtonTitle: "返回", okButtonTitle:"去付款", okHandler: { (action) in
                        self.pushOrderList(orderStatus:1)
                    }, cancelHandler: { (action) in
                        self.navigationController?.popViewController(animated:true)
                    })
                }
            }else if success == "underStock"{
                let goodsName=json["underStockGoodsInfo"]["goodsName"].stringValue
                self.showSVProgressHUD(status:goodsName+"库存不足", type: HUD.info)
            }else if success == "orderInfoAddTimeError"{
                self.showSVProgressHUD(status:"下单时间不在店铺设置的配送时间范围内，不能下单", type: HUD.info)
            }else if success == "lowestMoneyError"{
                self.showSVProgressHUD(status:"订单价格低于店铺设置的最低起送额", type: HUD.info)
            }else if success == "partnerBalanceError"{
                self.showSVProgressHUD(status:"合伙人余额信息错误", type: HUD.error)
            }else if success == "deductPartnerBalanceFail"{
                self.showSVProgressHUD(status:"扣除合伙人余额失败", type: HUD.error)
            }else if success == "partnerBalanceNotEnough"{
                self.showSVProgressHUD(status:"合伙人余额不充足", type: HUD.error)
            }else if success == "deductMemberBalanceFail"{
                self.showSVProgressHUD(status:"扣除会员余额失败", type: HUD.error)
            }else if success == "memberBalanceNotEnough"{
                self.showSVProgressHUD(status:"会员余额不充足", type: HUD.error)
            }else if success == "flagError"{
                self.showSVProgressHUD(status:"店铺整顿中", type: HUD.error)
            }else if success == "notOpen"{
                self.showSVProgressHUD(status:"暂停营业", type: HUD.error)
            }else if success == "outTime"{
                let goodsName=json["outTimeGoodsInfo"]["goodsName"].stringValue
                self.showSVProgressHUD(status:goodsName+"促销活动已结束", type: HUD.info)
            }else{
                self.showSVProgressHUD(status:"下单失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///获取用户余额
    private func queryMemberBalanceMoney(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryMemberBalanceMoney(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description)), successClosure: { (json) in
            let success=json["success"].string
            
            if success == "success"{
                self.memberBalanceMoney=json["memberBalanceMoney"].double
                self.memberDiscount=json["memberDiscount"].int
                if self.payTableView != nil{
                    self.payTableView.reloadData()
                }
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///余额支付
    private func balanceMoneyPay(){
        ///计算折扣价
        var memberDiscountPrice=PriceComputationsUtil.decimalNumberWithString(multiplierValue:sumPrice!, multiplicandValue:(Double(memberDiscount ?? 100)/100).description,type:ComputationsType.multiplication,position:2)
        ///加上配送费
        memberDiscountPrice=PriceComputationsUtil.decimalNumberWithString(multiplierValue:memberDiscountPrice, multiplicandValue:deliveryFee.description, type: ComputationsType.addition, position:2)
        if self.memberBalanceMoney == nil || self.memberBalanceMoney! < Double(memberDiscountPrice)!{//如果余额为空 或者余额小于支付金额 需要用户去充值
            let vc=self.storyboardPushView(type:.my, storyboardId:"BalanceMoneyTopUpVC") as! BalanceMoneyTopUpViewController
            self.navigationController?.pushViewController(vc, animated:true)
        }else{//去支付
            ///获取支付密码
            let payPw=userDefaults.object(forKey:"payPw") as? String
            if payPw == nil || payPw!.count == 0{//提示用户设置支付密码
                UIAlertController.showAlertYesNo(self, title:"温馨提示", message:"您还没有设置支付密码,为确保您余额安全,请设置支付密码。", cancelButtonTitle:"取消",okButtonTitle:"设置支付密码", okHandler: { (action) in
                    let vc=self.storyboardPushView(type:.my, storyboardId:"SetThePaymentPasswordVC") as! SetThePaymentPasswordViewController
                    self.navigationController?.pushViewController(vc, animated:true)
                },cancelHandler:{ (action) in
                    
                })
            }else{//输入支付密码
                self.showPayAlert(payPw:payPw, memberDiscountPrice:memberDiscountPrice)
            }
        }
    }

    /// 输入支付密码
    ///
    /// - Parameter payPw:本地支付密码
    private func showPayAlert(payPw:String?,memberDiscountPrice:String){
        ///折扣了多少
        let discount=PriceComputationsUtil.decimalNumberWithString(multiplierValue:sumPrice!, multiplicandValue:memberDiscountPrice, type: ComputationsType.subtraction, position:2)
        let payAlert = PayAlert.init(frame:UIScreen.main.bounds,price:memberDiscountPrice,view:self.view,payType:1,discount:discount)
        payAlert.completeBlock = {(password) -> Void in
            ///密码*2 MD5加密 转大写
            let pw=(Int(password)!*2).description.MD5().uppercased()
            if pw != payPw{
                UIAlertController.showAlertYesNo(self, title:"", message:"支付密码错误,请重试", cancelButtonTitle:"忘记密码", okButtonTitle:"重试", okHandler: { (action) in
                    self.showPayAlert(payPw:payPw, memberDiscountPrice:memberDiscountPrice)
                }, cancelHandler: { (action) in
                    let vc=self.storyboardPushView(type:.my, storyboardId:"SetThePaymentPasswordVC") as! SetThePaymentPasswordViewController
                    self.navigationController?.pushViewController(vc, animated:true)
                })
            }else{//支付密码输入正确
                self.payOrder(payType:4,sumPrice:memberDiscountPrice)
            }
        }
    }
}
extension OrderConfirmViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 100{
            var cell=payTableView.dequeueReusableCell(withIdentifier:"payId")
            if cell == nil{
                cell=UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier:"payId")
            }
            cell!.textLabel!.font=UIFont.systemFont(ofSize: 14)
            cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:12)
            cell!.textLabel!.text=payTitle[indexPath.row]
            cell!.imageView!.image=UIImage.init(named:payImgArr[indexPath.row])?.reSizeImage(reSize: CGSize.init(width:30, height:30))
            cell!.accessoryType = .disclosureIndicator
            if indexPath.row == 2{
                if self.memberDiscount != nil{
                    cell!.textLabel!.text=payTitle[indexPath.row]+"(\(self.memberDiscount!==100 ? "不打" : self.memberDiscount!.description)折)"
                }
                cell!.detailTextLabel!.text="￥\(self.memberBalanceMoney ?? 0)"
            }
            return cell!
        }else{
            var cell=table.dequeueReusableCell(withIdentifier:"OrderConfirmTableViewCellId") as? OrderConfirmTableViewCell
            if cell == nil{
                cell=getXibClass(name:"OrderConfirmTableViewCell", owner:self) as? OrderConfirmTableViewCell
            }
            if goodArr.count > 0{
                let entity=goodArr[indexPath.row]
                cell!.updateCell(entity:entity)
            }
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 100{
            return payImgArr.count
        }
        return goodArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 100{
            return 50
        }
        return 120
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中效果颜色
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.tag == 100{
            if indexPath.row == 0{//微信支付
                self.payOrder(payType:1, sumPrice:self.sumPrice!)
            }else if indexPath.row == 1{//支付宝支付
                self.payOrder(payType:2, sumPrice:self.sumPrice!)
            }else if indexPath.row == 2{//余额支付
                self.balanceMoneyPay()
            }
            self.hidePayView()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 100{
            let view=UIView(frame: CGRect.zero)
            let lblSelectedPayTitle=UILabel.buildLabel(textColor: UIColor.black, font:15, textAlignment: NSTextAlignment.left)
            lblSelectedPayTitle.text="选择支付方式"
            let lblSelectedPayTitleSize=lblSelectedPayTitle.text!.textSizeWithFont(font:lblSelectedPayTitle.font, constrainedToSize: CGSize.init(width:200, height: 20))
            lblSelectedPayTitle.frame=CGRect.init(x:15, y:15, width:lblSelectedPayTitleSize.width, height:20)
            view.addSubview(lblSelectedPayTitle)
            
            let lblPayPrice=UILabel.buildLabel(textColor:UIColor.color666(), font:13, textAlignment: NSTextAlignment.left)
            lblPayPrice.text="金额:"
            let lblPayPriceSize=lblPayPrice.text!.textSizeWithFont(font:lblPayPrice.font, constrainedToSize: CGSize.init(width:200, height: 20))
            lblPayPrice.frame=CGRect.init(x:lblSelectedPayTitle.frame.maxX+5, y:15, width:lblPayPriceSize.width, height:20)
            view.addSubview(lblPayPrice)
            
            let lblPayPriceValue=UILabel.buildLabel(textColor:UIColor.applicationMainColor(), font:13,textAlignment:NSTextAlignment.left)
            lblPayPriceValue.text="￥\(sumPrice!)"
            let lblPayPriceValueSize=lblPayPriceValue.text!.textSizeWithFont(font:lblPayPriceValue.font, constrainedToSize: CGSize.init(width:200, height: 20))
            lblPayPriceValue.frame=CGRect.init(x:lblPayPrice.frame.maxX, y:15, width: lblPayPriceValueSize.width, height:20)
            view.addSubview(lblPayPriceValue)

            let cancelImgView=UIImageView(frame: CGRect.init(x:boundsWidth-40-35, y:15, width:20, height:20))
            cancelImgView.image=UIImage.init(named:"cancel")
            cancelImgView.isUserInteractionEnabled=true
            cancelImgView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(hidePayView)))
            view.addSubview(cancelImgView)
            
            let borderView=UIView(frame: CGRect.init(x:0, y:49.5, width:boundsWidth-40, height:0.5))
            borderView.backgroundColor=UIColor.lightGray
            view.addSubview(borderView)
            return view
        }else{
            var view=table.dequeueReusableHeaderFooterView(withIdentifier:"headerId")
            if view == nil{
                view=UITableViewHeaderFooterView(reuseIdentifier:"headerId")
                view?.contentView.backgroundColor=UIColor.white
            }
            var lblName=view?.viewWithTag(11) as? UILabel
            if lblName == nil{
                lblName=UILabel.buildLabel(textColor:UIColor.black,font:16, textAlignment: NSTextAlignment.left)
                lblName!.frame=CGRect.init(x:15, y:15, width:boundsWidth-15, height: 20)
                lblName!.text="商品列表"
                view?.contentView.addSubview(lblName!)
            }
            return view!
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
