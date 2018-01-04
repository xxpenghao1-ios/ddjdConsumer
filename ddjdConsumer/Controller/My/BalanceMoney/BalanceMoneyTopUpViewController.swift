//
//  BalanceMoneyTopUpViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/28.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///余额充值
class BalanceMoneyTopUpViewController:BaseViewController{
    ///余额充值输入框
    @IBOutlet weak var txtBalanceMoneyTopUp: UITextField!
    ///当前余额
    @IBOutlet weak var lblBalanceMoney: UILabel!
    ///提交
    @IBOutlet weak var btnSubmit: UIButton!
    ///提示
    @IBOutlet weak var lblPrompt: UILabel!
    ///最小充值金额
    private var minRechargeMoney:Int?
    ///最大充值金额
    private var maxRechargeMoney:Int?
    ///充值方式 0 没有绑定； 1 绑定了微信； 2 绑定了支付宝
    private var payType:Int?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryMemberBalanceMoney()
        queryMemberbindrechargepaymenttools()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="余额充值"
        self.view.backgroundColor=UIColor.viewBackgroundColor()

        txtBalanceMoneyTopUp.font=UIFont.systemFont(ofSize: 14)
        txtBalanceMoneyTopUp.attributedPlaceholder=NSAttributedString(string:"请输入充值金额", attributes: [NSAttributedStringKey.foregroundColor:UIColor.color999()])
        txtBalanceMoneyTopUp.adjustsFontSizeToFitWidth=true;
        txtBalanceMoneyTopUp.tintColor=UIColor.applicationMainColor()
        txtBalanceMoneyTopUp.keyboardType=UIKeyboardType.numberPad;
        txtBalanceMoneyTopUp.layer.cornerRadius=45/2
        txtBalanceMoneyTopUp.backgroundColor=UIColor.white
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtBalanceMoneyTopUp.clearButtonMode=UITextFieldViewMode.whileEditing;
        //左视图
        let txtBalanceMoneyTopUpLeft=UIView(frame:CGRect(x:0,y:0,width:50,height:45))
        let txtBalanceMoneyTopUpLeftImg=UIImageView(frame:CGRect(x:20,y:10,width:25,height:25))
        txtBalanceMoneyTopUpLeftImg.image=UIImage(named: "balance_money")
        txtBalanceMoneyTopUpLeft.addSubview(txtBalanceMoneyTopUpLeftImg)
        txtBalanceMoneyTopUp.leftView=txtBalanceMoneyTopUpLeft
        txtBalanceMoneyTopUp.leftViewMode=UITextFieldViewMode.always;


        btnSubmit.addTarget(self, action:#selector(submit), for: UIControlEvents.touchUpInside)
        btnSubmit.layer.cornerRadius=40/2
    }
    @objc private func submit(){
        let rechargeMoney=txtBalanceMoneyTopUp.text
        guard rechargeMoney != nil && rechargeMoney!.count > 0 else {
            self.showSVProgressHUD(status:"请输入充值金额", type: HUD.info)
            return
        }
        if minRechargeMoney != nil && maxRechargeMoney != nil{
            guard Int(rechargeMoney!)! >= minRechargeMoney!   else {
                self.showSVProgressHUD(status:"充值金额不能低于\(minRechargeMoney!)元", type: HUD.info)
                return
            }
            guard Int(rechargeMoney!)! <= maxRechargeMoney!   else {
                self.showSVProgressHUD(status:"充值金额不能大于\(maxRechargeMoney!)元", type: HUD.info)
                return
            }
        }
        self.showPayType(paymentInstrument:self.payType, rechargeMoney:rechargeMoney!)
    }
    ///弹出支付方式
    private func showPayType(paymentInstrument:Int?,rechargeMoney:String){
        let alert=UIAlertController.init(title:"", message:"请选择支付方式", preferredStyle: UIAlertControllerStyle.actionSheet)
        if paymentInstrument == nil || paymentInstrument! == 0{
            let wx=UIAlertAction.init(title:"微信支付", style: UIAlertActionStyle.default) { (action) in
                self.memberRechargeBalance(rechargeMoney:Int(rechargeMoney)!, paymentInstrument:1)
            }
            let ali=UIAlertAction.init(title:"支付宝支付", style: UIAlertActionStyle.default) { (action) in
                self.memberRechargeBalance(rechargeMoney:Int(rechargeMoney)!,paymentInstrument:2)
            }
            alert.addAction(wx)
            alert.addAction(ali)
        }else if paymentInstrument == 1{//微信支付
            let wx=UIAlertAction.init(title:"微信支付", style: UIAlertActionStyle.default) { (action) in
                self.memberRechargeBalance(rechargeMoney:Int(rechargeMoney)!, paymentInstrument:paymentInstrument!)
            }
            alert.addAction(wx)
        }else if paymentInstrument == 2{//支付宝支付
            let ali=UIAlertAction.init(title:"支付宝支付", style: UIAlertActionStyle.default) { (action) in
                self.memberRechargeBalance(rechargeMoney:Int(rechargeMoney)!,paymentInstrument:paymentInstrument!)
            }
            alert.addAction(ali)
        }
        let cancel=UIAlertAction.init(title:"取消支付", style: UIAlertActionStyle.cancel)
        alert.addAction(cancel)
        self.present(alert, animated:true, completion:nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - 网络请求
extension BalanceMoneyTopUpViewController{

    /// 余额充值
    ///
    /// - Parameters:
    ///   - rechargeMoney: 会员充值的金额
    ///   - paymentInstrument: 会员充值使用的支付工具； 1微信；2支付宝
    private func memberRechargeBalance(rechargeMoney:Int,paymentInstrument:Int){
        self.showSVProgressHUD(status:"正在充值...",type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.memberRechargeBalance(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description, dicAny:["rechargeMoney":rechargeMoney,"paymentInstrument":paymentInstrument])), successClosure: { (json) in
            print(json)
            let success=json["success"].stringValue
            if success == "success"{
                if paymentInstrument == 1{//微信支付
                    let charge=json["charge"]
                    let req=PayReq()
                    req.timeStamp=charge["timestamp"].uInt32Value
                    req.partnerId=charge["partnerid"].stringValue
                    req.package=charge["package"].stringValue
                    req.nonceStr=charge["noncestr"].stringValue
                    req.sign=charge["sign"].stringValue
                    req.prepayId=charge["prepayid"].stringValue
                    WXApiManager.shared.payAlertController(self, request: req, paySuccess: {
                        self.showSVProgressHUD(status:"充值成功", type: HUD.success)
                        self.txtBalanceMoneyTopUp.text=nil
                        self.queryMemberBalanceMoney()
                        self.queryMemberbindrechargepaymenttools()
                    }, payFail: {
                        self.showSVProgressHUD(status:"支付失败", type: HUD.error)

                    })
                }else{//支付宝支付
                    let orderString=json["charge"]["orderString"].stringValue
                    AliPayManager.shared.payAlertController(self, request:orderString, paySuccess: {
                        self.showSVProgressHUD(status:"充值成功", type: HUD.success)
                        self.txtBalanceMoneyTopUp.text=nil
                        self.queryMemberBalanceMoney()
                        self.queryMemberbindrechargepaymenttools()
                    }, payFail: {
                        self.showSVProgressHUD(status:"支付失败", type: HUD.error)
                        self.navigationController?.popViewController(animated:true)
                    })
                }
            }else{
                self.showSVProgressHUD(status:"充值失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status: error!, type: HUD.error)
        }
    }
    ///获取用户余额
    private func queryMemberBalanceMoney(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryMemberBalanceMoney(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description)), successClosure: { (json) in
            let success=json["success"].string
            if success == "success"{
                self.minRechargeMoney=json["minRechargeMoney"].int
                self.maxRechargeMoney=json["maxRechargeMoney"].int
                self.lblBalanceMoney.text="当前余额:\(json["memberBalanceMoney"].doubleValue.description)"
                if self.minRechargeMoney != nil && self.maxRechargeMoney != nil{
                    self.lblPrompt.text="提示:充值金额不能小于\(self.minRechargeMoney!)元,大于\(self.maxRechargeMoney!)元"
                }
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///查询会员绑定的充值支付工具
    private func queryMemberbindrechargepaymenttools(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryMemberbindrechargepaymenttools(memberId:MEMBERID), successClosure: { (json) in
            print(json)
            self.payType=json["payType"].intValue
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
