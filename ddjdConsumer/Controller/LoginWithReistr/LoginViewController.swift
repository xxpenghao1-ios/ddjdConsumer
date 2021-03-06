//
//  LoginViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/10.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///登录
class LoginViewController:BaseViewController{
    ///如果为空 没有返回按钮 不为空 有返回按钮
    var flag:Int?
    //会员账号
    @IBOutlet weak var txtMemberName: UITextField!
    //密码
    @IBOutlet weak var txtPassword: UITextField!
    //登录按钮
    @IBOutlet weak var btnLogin: UIButton!
    //注册按钮
    @IBOutlet weak var btnReistr: UIButton!
    //忘记密码
    @IBOutlet weak var btnForgotPassword: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    //点击view区域收起键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
///页面设置
extension LoginViewController{
    private func setUpView(){
        //设置背景图片
        self.view.layer.contents=UIImage(named: "login_bac")?.cgImage
        self.view.backgroundColor=UIColor.clear
        //账号输入框
        setUpMemebrName()
        //设置密码输入框
        setUpPassword()
        //设置登录按钮
        btnLogin.layer.borderColor=UIColor.applicationMainColor().cgColor
        btnLogin.layer.borderWidth=1
        btnLogin.layer.cornerRadius=5
        //默认禁用登录按钮
        btnLogin.disable()
        btnLogin.addTarget(self, action:#selector(submit), for: .touchUpInside)
        btnForgotPassword.addTarget(self,action:#selector(pushForgotPassword), for: UIControlEvents.touchUpInside)
        if flag != nil{
            self.navigationItem.leftBarButtonItem=UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.cancel, target:self, action: #selector(cancelVC))
        }
        
    }
    @objc private func cancelVC(){
        app.tab.selectedIndex=0
        self.dismiss(animated:true, completion:nil)
    }
    //账号输入框
    private func setUpMemebrName(){
        txtMemberName.layer.borderColor=UIColor.RGBFromHexColor(hexString:"fbebef").cgColor
        txtMemberName.layer.borderWidth=0.5
        txtMemberName.layer.cornerRadius=5
        txtMemberName.adjustsFontSizeToFitWidth=true;
        let userAccount=userDefaults.object(forKey:"account") as? String
        if userAccount != nil{
            txtMemberName.text=userAccount
        }
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
    
    //设置密码输入框
    private func setUpPassword(){
        txtPassword.layer.borderColor=UIColor.RGBFromHexColor(hexString:"fbebef").cgColor
        txtPassword.layer.borderWidth=0.5
        txtPassword.layer.cornerRadius=5
        txtPassword.font=UIFont.systemFont(ofSize: 14)
        txtPassword.adjustsFontSizeToFitWidth=true;
        txtPassword.tintColor=UIColor.color999()
        txtPassword.keyboardType=UIKeyboardType.default;
        txtPassword.delegate=self
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtPassword!.clearButtonMode=UITextFieldViewMode.whileEditing;
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

// MARK: - 点击事件
extension LoginViewController{


    @objc private func submit(){
        let memberName=txtMemberName.text
        let password=txtPassword.text
        if memberName == nil || memberName!.count == 0{
            self.showSVProgressHUD(status:"账号不能为空", type: HUD.info)
            return
        }
        if password == nil || password!.count == 0{
            self.showSVProgressHUD(status:"密码不能为空", type: HUD.info)
            return
        }
        let deviceToken=userDefaults.object(forKey:"deviceToken") as? String ?? "penghao"
        self.showSVProgressHUD(status:"登录中...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:LoginWithRegistrApi.memberLogin(account:memberName!, password: password!, deviceToken:deviceToken,deviceName:UIDevice().name), successClosure: { (json) in
            print(json)
            let success=json["success"].stringValue
            
            if success == "success"{
                let memberEntity=self.jsonMappingEntity(entity:MemberEntity(), object:json["member"].object)
                //查询会员是否被授权订单管理 ; true已经授权； false 没有
                let authOrderStatu=json["authOrderStatu"].boolValue
                userDefaults.set(memberEntity!.memberId, forKey:"memberId")
                userDefaults.set(memberEntity!.account, forKey:"account")
                userDefaults.set(memberEntity!.storeId, forKey:"storeId")
                userDefaults.set(memberEntity!.bindstoreId, forKey:"bindstoreId")
                userDefaults.set(memberEntity!.token,forKey:"token")
                userDefaults.set(memberEntity!.payPw, forKey:"payPw")
                userDefaults.set(memberEntity!.vipStatu, forKey:"vipStatu")
                userDefaults.synchronize()
                self.dismissHUD {
                    //登录成功设置应用程序别名
                    JPUSHService.setAlias("m_\(memberEntity!.memberId ?? -1)", completion:nil,seq:22)
                    if memberEntity!.bindstoreId != nil{//如果用户绑定了店铺
                        if memberEntity!.storeFlag == 1{
                            JPUSHService.setTags(["s_"+memberEntity!.bindstoreId!.description], completion:nil,seq: 11)
                        }else{
                            if authOrderStatu {//如果用户已经被授权了
                                JPUSHService.setTags(["s_"+memberEntity!.bindstoreId!.description], completion:nil,seq: 11)
                            }
                        }

                        //跳转到主页面
                        app.jumpToIndexVC()
                    }else{
                        let vc=self.storyboardPushView(type:.loginWithRegistr, storyboardId:"BindStoreVC") as! BindStoreViewController
                        self.navigationController?.pushViewController(vc, animated:true)
                    }
                    
                }
            }else if success == "flagError"{
                self.showSVProgressHUD(status:"您已经被禁止登录了", type: HUD.info)
            }else if success == "fail"{
                self.showSVProgressHUD(status:"账号密码错误", type: HUD.error)
            }else if success == "notExist"{
                self.showSVProgressHUD(status:"账号不存在", type: HUD.error)
            }else{
                self.showSVProgressHUD(status:"登录失败", type:HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///跳转到忘记密码页面
    @objc private func pushForgotPassword(){
        let vc=self.storyboardPushView(type:.loginWithRegistr, storyboardId:"ReistrVC") as! ReistrViewController
        vc.passwordFlag=1
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
// MARK: - 验证登录按钮是否可以点击
extension LoginViewController:UITextFieldDelegate{
    //监听密码框输入
    @objc func textFieldDidChange(_ textField:UITextField){
        if textField.text != nil && textField.text != ""{
            btnLogin.enable()
        }else{
            btnLogin.disable()
        }
    }
}
