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
        
        let sumCountStr="共\(sumCount!)件商品"
        lblSumCount.attributedText=UILabel.setAttributedText(str:sumCountStr, textColor:UIColor.applicationMainColor(), font: 14, range: NSRange.init(location:1, length:sumCountStr.count-4))
        //商品小计
        let
        goodSumPriceStr="商品小计:￥\(sumPrice!)"
        lblGoodSumPrice.attributedText=UILabel.setAttributedText(str:goodSumPriceStr, textColor:UIColor.applicationMainColor(), font: 15, range: NSRange.init(location:5, length:goodSumPriceStr.count-5))
        ///商品总价加上配送费
        let sumPriceStr="总金额:￥"+PriceComputationsUtil.decimalNumberWithString(multiplierValue: sumPrice!, multiplicandValue:"\(deliveryFee)", type: ComputationsType.addition, position:2)
        ///订单总价
        lblSumPrice.attributedText=UILabel.setAttributedText(str:sumPriceStr, textColor:UIColor.applicationMainColor(), font: 15, range: NSRange.init(location:4, length:sumPriceStr.count-4))
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
    //下单 payType 1微信支付 2支付宝
    private func payOrder(payType:Int){
        self.showSVProgressHUD(status:"请稍后...", type: HUD.textClear)
        let payMessage=txtMessage.text ?? ""
        let moblieSumPrice=PriceComputationsUtil.decimalNumberWithString(multiplierValue: sumPrice!, multiplicandValue:"\(deliveryFee)", type: ComputationsType.addition, position:2)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.saveOrder(memberId:MEMBERID, shipaddressId:addressEntity!.shippAddressId!, platform:2, payType:payType, moblieSumPrice:moblieSumPrice,payMessage:payMessage), successClosure: { (json) in
            print(json)
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
                            self.showSVProgressHUD(status:"支付失败", type: HUD.error)
                            self.navigationController?.popViewController(animated:true)
                        })
                    }else if payType == 2{
                        let orderString=json["charge"]["orderString"].stringValue
                        AliPayManager.shared.payAlertController(self, request:orderString, paySuccess: {
                            self.checkOrder()
                        }, payFail: {
                            self.showSVProgressHUD(status:"支付失败", type: HUD.error)
                            self.navigationController?.popViewController(animated:true)
                        })
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
                let goodsName=json["goodsName"].stringValue
                self.showSVProgressHUD(status:goodsName+"库存不足", type: HUD.info)
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
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }

}
extension OrderConfirmViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 100{
            var cell=payTableView.dequeueReusableCell(withIdentifier:"payId")
            if cell == nil{
                cell=UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier:"payId")
            }
            cell!.textLabel!.font=UIFont.systemFont(ofSize: 14)
            cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:13)
            cell!.textLabel!.text=payTitle[indexPath.row]
            cell!.imageView!.image=UIImage.init(named:payImgArr[indexPath.row])?.reSizeImage(reSize: CGSize.init(width:30, height:30))
            cell!.accessoryType = .disclosureIndicator
            if indexPath.row == 3{
                cell!.detailTextLabel!.text="96折"
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
            if indexPath.row == 0{
                self.payOrder(payType:1)
            }else if indexPath.row == 1{
                self.payOrder(payType:2)
            }
            self.hidePayView()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 100{
            let view=UIView(frame: CGRect.zero)
            let lblSelectedPayTitle=UILabel.buildLabel(textColor: UIColor.black, font:15, textAlignment: NSTextAlignment.left)
            lblSelectedPayTitle.text="请选择支付方式"
            let lblSelectedPayTitleSize=lblSelectedPayTitle.text!.textSizeWithFont(font:lblSelectedPayTitle.font, constrainedToSize: CGSize.init(width:200, height: 20))
            lblSelectedPayTitle.frame=CGRect.init(x:15, y:15, width:lblSelectedPayTitleSize.width, height:20)
            view.addSubview(lblSelectedPayTitle)
            
            let lblPayPrice=UILabel.buildLabel(textColor:UIColor.color666(), font:13, textAlignment: NSTextAlignment.left)
            lblPayPrice.text="订单金额:"
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
