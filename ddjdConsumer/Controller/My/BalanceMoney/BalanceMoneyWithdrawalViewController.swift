//
//  BalanceMoneyWithdrawalViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/5.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///余额提现
class BalanceMoneyWithdrawalViewController:BaseViewController {
    ///内容view
    @IBOutlet weak var contentView: UIView!
    //提交按钮
    @IBOutlet weak var btnSubmit: UIButton!
    //输入的提现金额
    @IBOutlet weak var txtMoney: UITextField!
    ///提现方式名称
    @IBOutlet weak var lblWithdrawalTypeName: UILabel!
    ///提现账号名称
    @IBOutlet weak var lblWithdrawalAccountName: UILabel!
    ///全部提现按钮
    @IBOutlet weak var btnAllWithdrawal: UIButton!
    ///提现信息提示
    @IBOutlet weak var lblWithdrawalInfoPrompt: UILabel!
    ///最小提现金额
    private var minWithdrawalsMoney:Double?
    ///最大提现金额
    private var maxWithdrawalsMoney:Double?
    ///累计提现金额
    private var memberSumWithdrawalsMoney:Double?
    ///手续费费率； 千分之~ ;正整数
    private var withdrawalsServiceChargeRate:Int?
    ///需要扣除的手续费
    private var poundageMoneyStr:String?
    ///最大提现金额(扣除手续费后)
    private var toDeductoundageMoneyMaxWithdrawalsMoney:String?
    ///获取会员可提现金额
    private var memberBalanceMoney:Double?
    ///保存会员提现余额
    private var returnMemberBalanceMoney:String?
    ///提现余额(传给服务器)
    private var withdrawalsMoney:String?
    ///余额充值 0 没有绑定； 1 绑定了微信； 2 绑定了支付宝
    private var payType:Int?
    ///提现是否绑定1 已经绑定； =2 没有绑定 ；
    private var bind:Int?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryMemberWithdrawalsBalance()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="余额提现"
        setUpView()
    }
}

// MARK: - 页面设置
extension BalanceMoneyWithdrawalViewController{
    private func setUpView(){

        txtMoney.tintColor=UIColor.gray
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtMoney.clearButtonMode=UITextFieldViewMode.whileEditing;
        txtMoney.delegate=self
        txtMoney.addTarget(self, action:#selector(textFieldDidChange), for: UIControlEvents.editingChanged)

        btnSubmit.disable()
        btnSubmit.addTarget(self, action:#selector(submit), for: UIControlEvents.touchUpInside)
        btnSubmit.layer.cornerRadius=5

        contentView.layer.cornerRadius=5

        btnAllWithdrawal.addTarget(self, action:#selector(getAllMoney), for: UIControlEvents.touchUpInside)

        lblWithdrawalTypeName.isUserInteractionEnabled=true
        lblWithdrawalTypeName.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(selectedBindMemberWithdrawalsInfo)))
    }
    ///提现
    @objc private func submit(){
        if bind == 1{//如果没有绑定 如果已经绑定了
            if Double(txtMoney.text!)! > Double(toDeductoundageMoneyMaxWithdrawalsMoney ?? "0.0")!{//如果输入金额大于最大提现金额(扣除手续费后)
                UIAlertController.showAlertYesNo(self, title:"", message:"剩余余额不足以支付提现手续费￥\(self.poundageMoneyStr ?? "0.0"),当前最大提现金额为\(self.toDeductoundageMoneyMaxWithdrawalsMoney ?? "0.0")\n是否要全部提现?", cancelButtonTitle:"取消", okButtonTitle:"全部提现", okHandler: { (action) in
                    self.getAllMoney()
                    self.submit()
                })
                return
            }
            ///获取支付密码
            let payPw=userDefaults.object(forKey:"payPw") as? String
            if payPw == nil{//提示用户设置支付密码
                UIAlertController.showAlertYesNo(self, title:"温馨提示", message:"您还没有设置支付密码,为确保您余额安全,请设置支付密码。", cancelButtonTitle:"取消",okButtonTitle:"设置支付密码", okHandler: { (action) in
                    let vc=self.storyboardPushView(type:.my, storyboardId:"SetThePaymentPasswordVC") as! SetThePaymentPasswordViewController
                    self.navigationController?.pushViewController(vc, animated:true)
                },cancelHandler:{ (action) in

                })
            }else{//输入支付密码
                self.showPayAlert(payPw:payPw,memberDiscountPrice:self.returnMemberBalanceMoney ?? "0.0", discount:self.poundageMoneyStr ?? "0.0")
            }
        }else{//如果没有绑定
            UIAlertController.showAlertYesNo(self, title:"", message:"您还没有绑定提现方式", cancelButtonTitle:"取消", okButtonTitle:"绑定", okHandler: { (action) in
                self.selectedBindMemberWithdrawalsInfo()
            })
        }
    }
    ///获取全部可提余额
    @objc private func getAllMoney(){
        if self.memberBalanceMoney ?? 0 <= 0{
            return
        }
        if self.memberBalanceMoney ?? 0 < self.minWithdrawalsMoney ?? 1{
            self.btnAllWithdrawal.isHidden=true
            return
        }
        toCalculateMoney(isAllWithdrawal:1, memberBalanceMoney:self.memberBalanceMoney ?? 0.0)
        ///隐藏全部提现按钮
        self.btnAllWithdrawal.isHidden=true
        self.btnSubmit.enable()
    }
    ///计算提现余额 isAllWithdrawal 1是全部提现 2不是
    private func toCalculateMoney(isAllWithdrawal:Int,memberBalanceMoney:Double){
        ///每次计算清空
        poundageMoneyStr="0.0"
        ///手续费
        let poundage=PriceComputationsUtil.decimalNumberWithString(multiplierValue:(withdrawalsServiceChargeRate ?? 6).description, multiplicandValue:1000.description, type: ComputationsType.division, position:3)
        if memberSumWithdrawalsMoney == nil || memberSumWithdrawalsMoney! < 2000{//如果累计提现金额小于2000
            ///免费可提余额
            let  freeCanCarryMoney=2000-(memberSumWithdrawalsMoney ?? 0)
            print("免费可提余额\(freeCanCarryMoney)")
            if memberBalanceMoney > freeCanCarryMoney{//如果可提金额大于 免费额度
                ///需要计算手续费的余额
                let needToBePoundageMoney=(memberBalanceMoney-freeCanCarryMoney).description
                print("需要计算手续费的余额\(needToBePoundageMoney)")
                ///手续费扣除
                let poundageMoney=PriceComputationsUtil.decimalNumberWithString(multiplierValue: needToBePoundageMoney, multiplicandValue: poundage, type: ComputationsType.multiplication, position: 2)
                ///如果手续费小于0.1 收0.1
                poundageMoneyStr=Double(poundageMoney) ?? 0.0 < 0.1 ? "0.1":poundageMoney
                print("手续费扣除后的余额\(poundageMoneyStr ?? "0")")
                ///计算当前可提余额 (可提余额-手续费扣除后)
                returnMemberBalanceMoney=PriceComputationsUtil.decimalNumberWithString(multiplierValue:memberBalanceMoney.description, multiplicandValue: poundageMoneyStr ?? "0", type: ComputationsType.subtraction, position:2)
                if isAllWithdrawal == 1{//如果是全部提现
                    txtMoney.text=returnMemberBalanceMoney

                }
                ///提示信息
                self.lblWithdrawalInfoPrompt.text="额外扣除￥\(poundageMoneyStr ?? "0")手续费 (费率\(PriceComputationsUtil.decimalNumberWithString(multiplierValue: (withdrawalsServiceChargeRate ?? 6).description, multiplicandValue: 10.description, type: ComputationsType.division, position:1))%)"
            }else{//如果小于 不收取手续费
                returnMemberBalanceMoney=memberBalanceMoney.description
                if isAllWithdrawal == 1{//如果是全部提现
                    txtMoney.text=memberBalanceMoney.description
                }
                self.lblWithdrawalInfoPrompt.text="免费额度2000(已用额度\(memberSumWithdrawalsMoney ?? 0))"
            }
        }else{//如果已经超过累计金额
            ///手续费扣除
            let poundageMoney=PriceComputationsUtil.decimalNumberWithString(multiplierValue: memberBalanceMoney.description, multiplicandValue: poundage, type: ComputationsType.multiplication, position: 2)
            ///如果手续费小于0.1 收0.1
            poundageMoneyStr=Double(poundageMoney) ?? 0.0 < 0.1 ? "0.1":poundageMoney
            ///计算当前可提余额 (可提余额-手续费扣除后)
            returnMemberBalanceMoney=PriceComputationsUtil.decimalNumberWithString(multiplierValue:memberBalanceMoney.description, multiplicandValue: poundageMoneyStr ?? "0", type: ComputationsType.subtraction, position:2)
            if isAllWithdrawal == 1{//如果是全部提现
                txtMoney.text=returnMemberBalanceMoney
            }
            self.lblWithdrawalInfoPrompt.text="额外扣除￥\(poundageMoneyStr ?? "0")手续费 (费率\(PriceComputationsUtil.decimalNumberWithString(multiplierValue: (withdrawalsServiceChargeRate ?? 6).description, multiplicandValue: 10.description, type: ComputationsType.division, position:1))%)"
        }
        ///会员提现余额(没有计算手续费)
        withdrawalsMoney=memberBalanceMoney.description
        if isAllWithdrawal == 1{//如果是全部提现
            withdrawalsMoney=self.memberBalanceMoney?.description
        }
        self.lblWithdrawalInfoPrompt.textColor=UIColor.RGBFromHexColor(hexString:"aeaeae")
        ///计算最大提现金额(扣除手续费后)
        toDeductoundageMoneyMaxWithdrawalsMoneyMethod()
    }
    ///计算最大提现金额(扣除手续费后)
    private func toDeductoundageMoneyMaxWithdrawalsMoneyMethod(){
        let memberBalanceMoney=self.memberBalanceMoney ?? 0.0
        ///手续费
        let poundage=PriceComputationsUtil.decimalNumberWithString(multiplierValue:(withdrawalsServiceChargeRate ?? 6).description, multiplicandValue:1000.description, type: ComputationsType.division, position:3)
        if memberSumWithdrawalsMoney == nil || memberSumWithdrawalsMoney! < 2000{//如果累计提现金额小于2000
            ///免费可提余额
            let  freeCanCarryMoney=2000-(memberSumWithdrawalsMoney ?? 0)
            if memberBalanceMoney > freeCanCarryMoney{//如果可提金额大于 免费额度
                ///需要计算手续费的余额
                let needToBePoundageMoney=(memberBalanceMoney-freeCanCarryMoney).description
                ///手续费扣除
                let poundageMoney=PriceComputationsUtil.decimalNumberWithString(multiplierValue: needToBePoundageMoney, multiplicandValue: poundage, type: ComputationsType.multiplication, position: 2)
                ///如果手续费小于0.1 收0.1
                let poundageMoneyStrs=Double(poundageMoney) ?? 0.0 < 0.1 ? "0.1":poundageMoney
                ///计算最大提现金额(扣除手续费后)
                self.toDeductoundageMoneyMaxWithdrawalsMoney=PriceComputationsUtil.decimalNumberWithString(multiplierValue:(self.memberBalanceMoney ?? 0.0).description, multiplicandValue:poundageMoneyStrs, type: ComputationsType.subtraction, position:2)

            }else{//如果小于 不收取手续费
            self.toDeductoundageMoneyMaxWithdrawalsMoney=memberBalanceMoney.description

            }
        }else{//如果已经超过累计金额
            ///手续费扣除
            let poundageMoney=PriceComputationsUtil.decimalNumberWithString(multiplierValue:(self.memberBalanceMoney ?? 0.0).description, multiplicandValue: poundage, type: ComputationsType.multiplication, position: 2)
            ///如果手续费小于0.1 收0.1
            let poundageMoneyStrs=Double(poundageMoney) ?? 0.0 < 0.1 ? "0.1":poundageMoney
            ///计算最大提现金额(扣除手续费后)
            self.toDeductoundageMoneyMaxWithdrawalsMoney=PriceComputationsUtil.decimalNumberWithString(multiplierValue:(self.memberBalanceMoney ?? 0.0).description, multiplicandValue:poundageMoneyStrs, type: ComputationsType.subtraction, position:2)

        }
    }
    /// 输入支付密码
    ///
    /// - Parameter payPw:本地支付密码
    private func showPayAlert(payPw:String?,memberDiscountPrice:String,discount:String){
        let payAlert = PayAlert.init(frame:UIScreen.main.bounds,price:memberDiscountPrice,view:self.view,payType:2,discount:discount)
        payAlert.completeBlock = {(password) -> Void in
            ///密码*2 MD5加密 转大写
            let pw=(Int(password)!*2).description.MD5().uppercased()
            if pw != payPw{
                UIAlertController.showAlertYesNo(self, title:"", message:"支付密码错误,请重试", cancelButtonTitle:"忘记密码", okButtonTitle:"重试", okHandler: { (action) in
                    self.showPayAlert(payPw:payPw, memberDiscountPrice:memberDiscountPrice, discount: discount)
                }, cancelHandler: { (action) in
                    let vc=self.storyboardPushView(type:.my, storyboardId:"SetThePaymentPasswordVC") as! SetThePaymentPasswordViewController
                    self.navigationController?.pushViewController(vc, animated:true)
                })
            }else{//支付密码输入正确
                self.memberStartWithdrawalsBalance()
            }
        }
    }
}

// MARK: - 网络请求
extension BalanceMoneyWithdrawalViewController{
    ///查询会员提现信息
    private func queryMemberWithdrawalsBalance(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryMemberWithdrawalsBalance(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description)), successClosure: { (json) in
            print(json)
            let success=json["success"].stringValue
            if success == "success"{
                self.maxWithdrawalsMoney=json["maxWithdrawalsMoney"].doubleValue
                self.minWithdrawalsMoney=json["minWithdrawalsMoney"].doubleValue
                self.memberSumWithdrawalsMoney=json["memberSumWithdrawalsMoney"].doubleValue
                self.memberBalanceMoney=json["memberBalanceMoney"].doubleValue
                self.withdrawalsServiceChargeRate=json["withdrawalsServiceChargeRate"].intValue
                self.lblWithdrawalInfoPrompt.text="余额￥\(self.memberBalanceMoney ?? 0.00),"
                ///是否绑定提现信息 1 已经绑定 2 没有绑定
                self.bind=json["bind"].intValue
                ///充值信息是否绑定 0 没有绑定； 1 绑定了微信； 2 绑定了支付宝
                self.payType=json["memberBindRechargePaymentToolsIdWxOrAli"].intValue
                if self.bind == 1{//如果有绑定
                    let nickname=json["nickname"].stringValue
                    if self.payType == 1{
                        self.lblWithdrawalTypeName.text="到账微信"
                        self.lblWithdrawalAccountName.text="微信账户\(nickname)"
                    }else if self.payType == 2{
                        self.lblWithdrawalTypeName.text="到账支付宝"
                        self.lblWithdrawalAccountName.text="支付宝账户\(nickname)"
                    }
                    ///禁用绑定提现
                    self.lblWithdrawalTypeName.isUserInteractionEnabled=false
                }
            }else{
                self.showSVProgressHUD(status:"获取提现信息失败", type: HUD.error)
                self.navigationController?.popViewController(animated:true)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///选择绑定会员提现信息
    @objc private func selectedBindMemberWithdrawalsInfo(){
        let wx=UIAlertAction.init(title:"绑定微信", style: UIAlertActionStyle.default, handler: { (action) in
            WXApiManager.shared.login(self, loginSuccess: { (code) in
                self.updateBindMemberWithdrawalsInfo(payType:1, code:code)
            }, loginFail: {
                self.showSVProgressHUD(status:"绑定失败", type: HUD.error)
            })
        })
        let ali=UIAlertAction.init(title:"绑定支付宝", style: UIAlertActionStyle.default, handler: { (action) in
            self.query_ali_AuthParams()
        })
        let cancel=UIAlertAction.init(title:"取消", style: UIAlertActionStyle.cancel, handler: nil)
        if self.payType == 0{
            let alert=UIAlertController.init(title:"绑定提现账户", message:"微信/支付宝只能选择一种,绑定后不能修改(暂时)", preferredStyle: UIAlertControllerStyle.actionSheet)
            alert.addAction(cancel)
            alert.addAction(wx)
            alert.addAction(ali)
            self.present(alert, animated:true, completion: nil)
        }else if self.payType == 1{
            let alert=UIAlertController.init(title:"绑定提现账户", message:"您第一次充值使用的支付方式是微信,提现账户也必须绑定微信账户(暂时)", preferredStyle: UIAlertControllerStyle.actionSheet)
            alert.addAction(cancel)
            alert.addAction(wx)
            self.present(alert,animated:true, completion: nil)
        }else if self.payType == 2{
            let alert=UIAlertController.init(title:"绑定提现账户", message:"您第一次充值使用的支付方式是微信,提现账户也必须绑定微信账户(暂时)", preferredStyle: UIAlertControllerStyle.actionSheet)
            alert.addAction(cancel)
            alert.addAction(ali)
            self.present(alert,animated:true, completion: nil)
        }
    }
    ///绑定会员提现信息 payType1 微信 ； 2 支付宝
    private func updateBindMemberWithdrawalsInfo(payType:Int,code:String){
        self.showSVProgressHUD(status:"正在绑定...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.updateBindMemberWithdrawalsInfo(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description, dicAny:["payType":payType,"code":code])), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"绑定成功", type: HUD.success)
                self.queryMemberWithdrawalsBalance()
            }else if success == "exist"{
                self.showSVProgressHUD(status:"会员已经绑定提现方式了", type: HUD.error)
            }else{
                self.showSVProgressHUD(status:"绑定失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///获取支付宝授权参数 ； 调起支付宝授权所需的请求参数
    private func query_ali_AuthParams(){
        self.showSVProgressHUD(status:"正在调起支付宝...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreBindWxOrAlipayApi.query_ali_AuthParams(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description, dicAny: ["storeId":STOREID])),successClosure: { (json) in
            self.dismissHUD()
            let str=json["ali_auth_app_login"].stringValue
            print(json)
            AliPayManager.shared.login(self, withInfo:str, loginSuccess: { (str) in
                let resultArr=str.components(separatedBy:"&")
                for(subResult) in resultArr{
                    if subResult.count > 10 && subResult.hasPrefix("auth_code="){
                        let auth_code=subResult[subResult.index(subResult.startIndex, offsetBy:10)...]
                        self.updateBindMemberWithdrawalsInfo(payType:2, code: String(auth_code))
                        return
                    }
                }
                self.showSVProgressHUD(status:"绑定失败", type: HUD.error)
            }, loginFail: {
                self.showSVProgressHUD(status:"绑定失败", type: HUD.error)
            })
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///开始提现
    private func memberStartWithdrawalsBalance(){
        self.showSVProgressHUD(status:"正在提现...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.memberStartWithdrawalsBalance(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description, dicAny:["withdrawalsMoney":self.withdrawalsMoney ?? "0.0","serviceCharge":self.poundageMoneyStr ?? "0.0"])), successClosure: { (json) in
            print(json)
            let success=json["success"].stringValue
            self.dismissHUD()
            switch success{
            case "success":
                let vc=self.storyboardPushView(type:.my, storyboardId:"WithdrawalSuccessVC") as! WithdrawalSuccessViewController
                self.navigationController?.pushViewController(vc, animated:true)
                break
            case "memberBalanceNotEnough":
                self.showSVProgressHUD(status:"会员余额不充足", type: HUD.error)
                break
            case "deductMemberBalanceFail":
                self.showSVProgressHUD(status:"扣除会员余额失败", type: HUD.error)
                break
            case "error":
                self.showSVProgressHUD(status:"提现金额超出剩余可提现金额", type: HUD.error)
                break
            case "notExist":
                self.showSVProgressHUD(status:"提现金额超出剩余可提现金额", type: HUD.error)
                break
            case "maxWithdrawalsMoneyToday":
                let surplusToday=json["surplusToday"].doubleValue
                self.showSVProgressHUD(status:"超出今日最大提现金额\(surplusToday)", type: HUD.error)
                break
            default:
                self.showSVProgressHUD(status:"提现失败", type: HUD.error)
            }
            self.queryMemberWithdrawalsBalance()
            self.btnAllWithdrawal.isHidden=false
            self.txtMoney.text=nil
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
extension BalanceMoneyWithdrawalViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 1{//按键是x执行
            return true
        }
        if textField.text != nil && textField.text!.count > 0{//如果不为空
            let strs=textField.text!.components(separatedBy:".")
            if strs.count > 1{//如果分割的字符串数组大于1表示有.
                if string.contains("."){ //如果小数点后面还包含小数返回false
                    return false
                }
                if strs[1].count >= 2{//如果小数点超过2位
                    if range.location == textField.text!.count{//光标位置在最后
                        return false
                    }
                }
            }else{//如果没有点
                if range.location < textField.text!.count{//光标位值小于字符长度
                    if string.contains("."){//如果是点
                        if textField.text!.count > 2{//如果输入框的字符串大于2位
                            return false
                        }else{//如果小于等于2位
                            if range.location == 0{//如果光标位置是第一为
                                textField.text="0."+textField.text!
                                return false
                            }
                        }
                    }
                }
            }
        }else{//如果输入框为空
            if string.count == 1{//如果第一位是小数点 默认给0.
                if string.contains("."){
                    textField.text="0"
                }
            }
        }
        return true
    }
    //监听输入
    @objc func textFieldDidChange(_ textField:UITextField){
        if textField.text != nil && textField.text!.count > 0{//如果不为空
            let memberBalanceMoney=Double(textField.text!) ?? 0.0
            if memberBalanceMoney > self.memberBalanceMoney ?? 0.0{//如果输入金额大于可提现余额
                self.updateLblPrompt(str:"输入的金额超过余额")
                return
            }
            if memberBalanceMoney > self.maxWithdrawalsMoney ?? 10000{//如果输入金额大于最大提现额度
                self.updateLblPrompt(str:"输入金额超过最大限额\(self.maxWithdrawalsMoney ?? 10000)")
                return
            }
            if memberBalanceMoney < self.minWithdrawalsMoney ?? 1{//如果输入金额小于最小提现额度
                self.updateLblPrompt(str:"输入金额小于最小限额\(self.minWithdrawalsMoney ?? 1)")
                return
            }
            if memberBalanceMoney >= self.minWithdrawalsMoney ?? 1{ //如果输入金额大于最小限额
                self.toCalculateMoney(isAllWithdrawal:2, memberBalanceMoney: memberBalanceMoney)
                ///显示全部提现
                self.btnAllWithdrawal.isHidden=true
            }
            btnSubmit.enable()
        }else{//如果为空
            btnSubmit.disable()
            ///显示余额
            self.lblWithdrawalInfoPrompt.text="余额￥\(self.memberBalanceMoney ?? 0.00),"
            self.lblWithdrawalInfoPrompt.textColor=UIColor.RGBFromHexColor(hexString:"aeaeae")
            ///显示全部提现
            self.btnAllWithdrawal.isHidden=false
        }
    }
    ///更新提示信息
    private func updateLblPrompt(str:String){
        self.lblWithdrawalInfoPrompt.text=str
        self.lblWithdrawalInfoPrompt.textColor=UIColor.red
        self.btnAllWithdrawal.isHidden=true
        self.btnSubmit.disable()
    }
}
