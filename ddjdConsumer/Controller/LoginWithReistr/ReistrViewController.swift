//
//  ReistrViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/11.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
//注册页面
class ReistrViewController:BaseViewController{
    ///如果不等于空 找回密码
    var passwordFlag:Int?
    //会员账号
    @IBOutlet weak var txtMemberName: UITextField!
    //验证码
    @IBOutlet weak var txtCode: UITextField!
    //密码
    @IBOutlet weak var txtPassword: UITextField!
    //注册按钮
    @IBOutlet weak var btnReistr: UIButton!
    //登录按钮
    @IBOutlet weak var btnLogin: UIButton!
    //边框颜色
    private let borderColor=UIColor.RGBFromHexColor(hexString:"fbebef").cgColor
    //获取验证码按钮
    private var btnGetCode:UIButton!
    /// 定时器
    private var timer:Timer?;
    ///保存获取到的验证
    private var code:String?
    //默认60秒
    private var secondCount=60
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        if passwordFlag != nil{
            self.title="忘记密码"
            btnReistr.setTitle("设置", for: UIControlState.normal)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //关闭计时器
        self.endTimer()
    }
}

// MARK: - 设置页面
extension ReistrViewController{
    private func setUpView(){
        //设置背景图片
        self.view.layer.contents=UIImage(named: "login_bac")?.cgImage
        self.view.backgroundColor=UIColor.clear
        
        setUpMemberName()
        setUpCode()
        setUpPassword()
    
        //设置注册按钮
        btnReistr.layer.borderColor=UIColor.applicationMainColor().cgColor
        btnReistr.layer.borderWidth=1
        btnReistr.layer.cornerRadius=5
       
        btnReistr.disable()
        btnReistr.addTarget(self, action: #selector(submit), for: UIControlEvents.touchUpInside)
        btnLogin.addTarget(self, action:#selector(popLogin), for: .touchUpInside)
    }

    //账号输入框
    func setUpMemberName(){
        txtMemberName.layer.borderColor=borderColor
        txtMemberName.layer.borderWidth=0.5
        txtMemberName.layer.cornerRadius=5
        txtMemberName.adjustsFontSizeToFitWidth=true;
        txtMemberName.tintColor=UIColor.color999()
        txtMemberName.keyboardType=UIKeyboardType.phonePad
        txtMemberName.font=UIFont.systemFont(ofSize: 14)
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtMemberName.clearButtonMode=UITextFieldViewMode.whileEditing
        //左视图
        let txtNameLeft=UIView(frame: CGRect(x:0, y:0, width:45, height:45))
        txtNameLeft.backgroundColor=UIColor.RGBFromHexColor(hexString:"e77493")
        txtNameLeft.layer.cornerRadius=5
        let txtNameLeftImg=UIImageView(frame:CGRect(x:10,y:10,width:25,height:25))
        txtNameLeftImg.image=UIImage(named: "memberName")
        txtNameLeft.addSubview(txtNameLeftImg)
        txtMemberName.leftView=txtNameLeft
        txtMemberName.leftViewMode=UITextFieldViewMode.always;
    }
    //设置验证码
    func setUpCode(){
        //设置验证码
        txtCode.layer.borderColor=borderColor
        txtCode.layer.borderWidth=0.5
        txtCode.layer.cornerRadius=5
        txtCode.font=UIFont.systemFont(ofSize: 14)
        txtCode.adjustsFontSizeToFitWidth=true;
        txtCode.tintColor=UIColor.color999()
        txtCode.keyboardType=UIKeyboardType.numberPad;
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtCode.clearButtonMode=UITextFieldViewMode.whileEditing;
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
        
        btnGetCode=UIButton.button(type: .cornerRadiusButton, text:"获取验证码", textColor: .white, font:15, backgroundColor:UIColor.RGBFromHexColor(hexString:"e77493"), cornerRadius:5)
        btnGetCode.frame=CGRect(x:0, y:0, width:80, height:45)
        btnGetCode.addTarget(self, action: #selector(getCode), for:UIControlEvents.touchUpInside)
        txtCode.rightView=btnGetCode
        txtCode.rightViewMode = .always
    }
    //设置密码框
    func setUpPassword(){
        txtPassword.layer.borderColor=borderColor
        txtPassword.layer.borderWidth=0.5
        txtPassword.layer.cornerRadius=5
        txtPassword.font=UIFont.systemFont(ofSize: 14)
        txtPassword.adjustsFontSizeToFitWidth=true;
        txtPassword.tintColor=UIColor.color999()
        txtPassword.keyboardType=UIKeyboardType.default;
        txtPassword.delegate=self
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtPassword.clearButtonMode=UITextFieldViewMode.whileEditing;
        //左视图
        let txtPasswordLeft=UIView(frame:CGRect(x:0,y:0,width:45,height:45))
        txtPasswordLeft.layer.cornerRadius=5
        txtPasswordLeft.backgroundColor=UIColor.RGBFromHexColor(hexString:"e77493")
        let txtPasswordLeftImg=UIImageView(frame:CGRect(x:(45-22)/2,y:8.5,width:22,height:28))
        txtPasswordLeftImg.image=UIImage(named:"password")
        txtPasswordLeft.addSubview(txtPasswordLeftImg)
        txtPassword.leftView=txtPasswordLeft
        txtPassword.leftViewMode=UITextFieldViewMode.always;
        txtPassword.addTarget(self, action:#selector(textFieldDidChange), for: UIControlEvents.editingChanged)
    }
}

// MARK: - 页面点击事件
extension ReistrViewController{
    //提交注册信息
    @objc private func submit(){
        let memberName=txtMemberName.text
        let strCode=txtCode.text
        let password=txtPassword.text
        if strCode == nil || strCode!.count == 0{
            self.showSVProgressHUD(status:"请输入验证码", type: HUD.info)
            return
        }
        if strCode != code{
            self.showSVProgressHUD(status:"验证码错误", type: HUD.error)
            return
        }
        if password == nil || password!.count == 0{
            self.showSVProgressHUD(status:"请设置您的密码", type: HUD.info)
        }
        if password!.count < 6{
            self.showSVProgressHUD(status:"密码最少6位", type: HUD.info)
        }
        if passwordFlag == nil{
            self.showSVProgressHUD(status:"正在注册...", type: HUD.textClear)
            PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:LoginWithRegistrApi.reg(account:memberName!, password: password!), successClosure: { (json) in
                let success=json["success"].stringValue
                if success == "success"{
                    self.showSVProgressHUD(status:"注册成功", type: HUD.success)
                    self.navigationController?.popViewController(animated:true)
                }else{
                    self.showSVProgressHUD(status:"注册失败", type: HUD.error)
                }
            }) { (error) in
                self.showSVProgressHUD(status:error!, type: HUD.error)
            }
        }else{
            self.showSVProgressHUD(status:"正在提交...", type: HUD.textClear)
            PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:LoginWithRegistrApi.fingPwd(account:memberName!, password:password!), successClosure: { (json) in
                let success=json["success"].stringValue
                if success == "success"{
                    self.showSVProgressHUD(status:"设置成功", type: HUD.success)
                    self.navigationController?.popViewController(animated:true)
                }else if success == "notExist"{
                    self.showSVProgressHUD(status:"账号不存在", type: HUD.error)
                }else{
                    self.showSVProgressHUD(status:"设置失败", type: HUD.error)
                }
            }, failClosure: { (error) in
                self.showSVProgressHUD(status:error!, type: HUD.error)
            })
        }
        
    }
    //获取验证码
    @objc private func getCode(){
        let memberName=txtMemberName.text
        if memberName == nil || memberName!.count == 0{
            self.showSVProgressHUD(status:"请输入手机号码", type: .info)
            return
        }
        if memberName!.count != 11{
            self.showSVProgressHUD(status:"请输入正确的手机号码", type: .info)
            return
        }
        self.showSVProgressHUD(status:"正在获取验证码...", type: HUD.textClear)
        let flag=passwordFlag==nil ? 1:2
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target: LoginWithRegistrApi.duanxinValidate(account:memberName!,flag:flag), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.dismissHUD()
                self.code=json["randCode"].stringValue
                //开始倒计时
                self.startTimer()
            }else if success == "exist"{//注册时才会返回
                self.showSVProgressHUD(status:"该账号已存在", type: .info)
            }else if success == "notExist"{// 忘记密码时才会返回
                self.showSVProgressHUD(status:"账号不存在", type: .info)
            }else{
                self.showSVProgressHUD(status:"获取验证码失败", type: .error)
            }
        }, failClosure: { (error) in
            self.showSVProgressHUD(status:error!, type: .error)
        })
    }
    ///返回登录页面
    @objc private func popLogin(){
        self.navigationController?.popViewController(animated:true)
    }
}
//倒计时
extension ReistrViewController{
    //开始倒计时
    private func startTimer(){
        //禁用验证码按钮
        self.btnGetCode.isEnabled=false
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
        btnGetCode.isEnabled=true
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
}
// MARK: - 验证注册按钮是否可以点击
extension ReistrViewController:UITextFieldDelegate{
    //监听密码框输入
    @objc func textFieldDidChange(_ textField:UITextField){
        if textField.text != nil && textField.text!.count > 0{
            btnReistr.enable()
        }else{
            btnReistr.disable()
        }
    }
}
