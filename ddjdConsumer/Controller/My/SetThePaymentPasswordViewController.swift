//
//  SetThePaymentPasswordViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/2.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///设置支付密码
class SetThePaymentPasswordViewController:BaseViewController{
    ///支付密码输入框
    @IBOutlet weak var txtPayPassword: UITextField!
    ///验证码
    @IBOutlet weak var txtCode: UITextField!
    ///提交按钮
    @IBOutlet weak var btnSubmit: UIButton!
    ///获取验证码
    private var btnGetCode:UIButton!
    /// 定时器
    private var timer:Timer?;
    ///保存获取到的验证
    private var code:String?
    //默认60秒
    private var secondCount=60
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="设置支付密码"
        self.view.backgroundColor=UIColor.white
        setUpView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //关闭计时器
        self.endTimer()
    }
    //点击view区域收起键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - 设置页面
extension SetThePaymentPasswordViewController{

    private func setUpView(){

        let borderColor=UIColor.RGBFromHexColor(hexString:"fbebef").cgColor

        txtPayPassword.layer.borderColor=borderColor
        txtPayPassword.layer.borderWidth=0.5
        txtPayPassword.layer.cornerRadius=5
        txtPayPassword.font=UIFont.systemFont(ofSize: 14)
        txtPayPassword.adjustsFontSizeToFitWidth=true;
        txtPayPassword.isSecureTextEntry=true
        txtPayPassword.tintColor=UIColor.color999()
        txtPayPassword.keyboardType=UIKeyboardType.numberPad;
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtPayPassword.clearButtonMode=UITextFieldViewMode.whileEditing;
        //左视图
        let txtPayPasswordLeft=UIView(frame:CGRect(x:0,y:0,width:45,height:45))
        txtPayPasswordLeft.layer.cornerRadius=5
        txtPayPasswordLeft.backgroundColor=UIColor.RGBFromHexColor(hexString:"e77493")
        let txtPayPasswordLeftImg=UIImageView(frame:CGRect(x:(45-22)/2,y:8.5,width:22,height:28))
        txtPayPasswordLeftImg.image=UIImage(named:"password")
        txtPayPasswordLeft.addSubview(txtPayPasswordLeftImg)
        txtPayPassword.leftView=txtPayPasswordLeft
        txtPayPassword.leftViewMode=UITextFieldViewMode.always;

        //设置验证码
        txtCode.layer.borderColor=borderColor
        txtCode.layer.borderWidth=0.5
        txtCode.layer.cornerRadius=5
        txtCode.font=UIFont.systemFont(ofSize: 14)
        txtCode.adjustsFontSizeToFitWidth=true;
        txtCode.tintColor=UIColor.color999()
        txtCode.keyboardType=UIKeyboardType.numberPad;
        txtCode.delegate=self
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtCode.clearButtonMode=UITextFieldViewMode.whileEditing;
        txtCode.addTarget(self, action:#selector(textFieldDidChange), for: UIControlEvents.editingChanged)

        //左视图
        let txtCodeLeft=UIView(frame:CGRect(x:0,y:0,width:45,height:45))
        txtCodeLeft.layer.cornerRadius=5
        txtCodeLeft.backgroundColor=UIColor.RGBFromHexColor(hexString:"e77493")
        let txtCodeLeftImg=UIImageView(frame:CGRect(x:0,y:0,width:20.8,height:26.8))
        txtCodeLeftImg.image=UIImage(named:"login_code")
        txtCodeLeftImg.center=txtCodeLeft.center
        txtCodeLeft.addSubview(txtCodeLeftImg)
        txtCode.leftView=txtCodeLeft
        txtCode.leftViewMode=UITextFieldViewMode.always;

        btnGetCode=UIButton.button(type: .cornerRadiusButton, text:"获取验证码", textColor: .white, font:13, backgroundColor:UIColor.RGBFromHexColor(hexString:"e77493"), cornerRadius:5)
        btnGetCode.frame=CGRect(x:0, y:0, width:80, height:45)
        btnGetCode.addTarget(self, action: #selector(getCode), for:UIControlEvents.touchUpInside)
        txtCode.rightView=btnGetCode
        txtCode.rightViewMode = .always


        btnSubmit.layer.cornerRadius=5
        btnSubmit.disable()
        btnSubmit.addTarget(self, action: #selector(submit), for: UIControlEvents.touchUpInside)
    }

}
extension SetThePaymentPasswordViewController:UITextFieldDelegate{
    ///获取验证码
    @objc private func getCode(){
        let account=userDefaults.object(forKey:"account") as! String
        self.showSVProgressHUD(status:"正在获取验证码...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target: LoginWithRegistrApi.duanxinValidate(account:account,flag:3), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.dismissHUD()
                self.code=json["randCode"].stringValue
                //开始倒计时
                self.startTimer()
            }else{
                self.showSVProgressHUD(status:"获取验证码失败", type: .error)
            }
        }, failClosure: { (error) in
            self.showSVProgressHUD(status:error!, type: .error)
        })
    }
    ///提交
    @objc private func submit(){
        let payWd=txtPayPassword.text
        let code=txtCode.text
        if payWd == nil || payWd!.count == 0{
            self.showSVProgressHUD(status:"支付密码不能为空", type: HUD.info)
            return
        }
        if payWd!.count > 6 || payWd!.count < 6{
            self.showSVProgressHUD(status:"支付密码必须为6位", type: HUD.info)
            return
        }
        if code == nil || code?.count == 0{
            self.showSVProgressHUD(status:"验证码不能为空", type: HUD.info)
            return
        }
        if code != self.code{
            self.showSVProgressHUD(status:"验证码输入错误", type: HUD.info)
            return
        }
        self.showSVProgressHUD(status:"正在提交...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.updateMemberBalancePayPassword(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description, dicAny:["pw":payWd!])), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                let pw=json["payType"].string
                userDefaults.set(pw, forKey:"payPw")
                userDefaults.synchronize()
                self.dismissHUD()
                self.showSVProgressHUD(status:"支付密码设置成功", type: HUD.success)
                self.navigationController?.popViewController(animated:true)
            }else if success == "repeatError"{
                self.showSVProgressHUD(status:"支付密码没有改变", type: HUD.error)
            }else if success == "numberLengthError"{
                self.showSVProgressHUD(status:"只能是6位数量支付密码", type: HUD.error)
            }else{
                self.showSVProgressHUD(status:"设置支付密码失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }

    }
    //开始倒计时
    private func startTimer(){
        //禁用验证码按钮
        self.btnGetCode.disable()
        //创建定时器每隔一秒钟执行一次
        if self.timer == nil {
            self.timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true);
        }else{//如果已经创建
            secondCount=60
        }
    }
    //结算倒计时
    private func endTimer(){
        //恢复验证码点击
        btnGetCode.enable()
        self.timer?.invalidate();
        self.timer = nil;
    }
    //刷新秒
    @objc private func updateTimer(){
        secondCount-=1;
        btnGetCode.setTitle("还剩\(secondCount)秒", for: UIControlState())
        //计时数每次-1；

        //等于0的时候关闭计时器
        if secondCount <= 0 {
            endTimer()
            //重新设置验证lbl
            btnGetCode.setTitle("重新获取", for: UIControlState())
            secondCount=60;
        }
    }
    //监听密码框输入
    @objc func textFieldDidChange(_ textField:UITextField){
        if textField.text != nil && textField.text!.count > 0{
            btnSubmit.enable()
        }else{
            btnSubmit.disable()
        }
    }
}
