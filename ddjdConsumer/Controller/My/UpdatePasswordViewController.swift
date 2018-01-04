//
//  UpdatePasswordViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/5.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///修改密码
class UpdatePasswordViewController:BaseViewController{
    
    @IBOutlet weak var txtOldPwd: UITextField!
    
    @IBOutlet weak var txtNewPwd: UITextField!
    
    @IBOutlet weak var txtNewPwds: UITextField!
    
    @IBOutlet weak var btnSubmit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="修改密码"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
}
extension UpdatePasswordViewController{
    private func setUpView(){
        //设置密码输入框
        txtOldPwd.font=UIFont.systemFont(ofSize: 14)
        txtOldPwd.attributedPlaceholder=NSAttributedString(string:"请输入原密码", attributes: [NSAttributedStringKey.foregroundColor:UIColor.color999()])
        txtOldPwd.adjustsFontSizeToFitWidth=true;
        txtOldPwd.tintColor=UIColor.applicationMainColor()
        txtOldPwd.isSecureTextEntry=true
        txtOldPwd.keyboardType=UIKeyboardType.default;
        txtOldPwd.layer.cornerRadius=45/2
        txtOldPwd.backgroundColor=UIColor.white
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtOldPwd.clearButtonMode=UITextFieldViewMode.whileEditing;
        //左视图
        let txtPasswordLeft=UIView(frame:CGRect(x:0,y:0,width:50,height:45))
        let txtPasswordLeftImg=UIImageView(frame:CGRect(x:20,y:12.5,width:20,height:20))
        txtPasswordLeftImg.image=UIImage(named: "login_password")
        txtPasswordLeft.addSubview(txtPasswordLeftImg)
        txtOldPwd.leftView=txtPasswordLeft
        txtOldPwd.leftViewMode=UITextFieldViewMode.always;
        
        //设置密码输入框
        txtNewPwd.font=UIFont.systemFont(ofSize: 14)
        txtNewPwd.attributedPlaceholder=NSAttributedString(string:"请输入新密码", attributes: [NSAttributedStringKey.foregroundColor:UIColor.color999()])
        txtNewPwd.adjustsFontSizeToFitWidth=true;
        txtNewPwd.tintColor=UIColor.applicationMainColor()
        txtNewPwd.isSecureTextEntry=true
        txtNewPwd.keyboardType=UIKeyboardType.default;
        txtNewPwd.layer.cornerRadius=45/2
        txtNewPwd.backgroundColor=UIColor.white
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtNewPwd.clearButtonMode=UITextFieldViewMode.whileEditing;
        //左视图
        let txtNewPwdLeft=UIView(frame:CGRect(x:0,y:0,width:50,height:45))
        let txtNewPwdLeftImg=UIImageView(frame:CGRect(x:20,y:12.5,width:20,height:20))
        txtNewPwdLeftImg.image=UIImage(named: "login_password")
        txtNewPwdLeft.addSubview(txtNewPwdLeftImg)
        txtNewPwd.leftView=txtNewPwdLeft
        txtNewPwd.leftViewMode=UITextFieldViewMode.always;
        
        //设置密码输入框
        txtNewPwds.font=UIFont.systemFont(ofSize: 14)
        txtNewPwds.attributedPlaceholder=NSAttributedString(string:"请重复输入新密码", attributes: [NSAttributedStringKey.foregroundColor:UIColor.color999()])
        txtNewPwds.adjustsFontSizeToFitWidth=true;
        txtNewPwds.tintColor=UIColor.applicationMainColor()
        txtNewPwds.isSecureTextEntry=true
        txtNewPwds.keyboardType=UIKeyboardType.default;
        txtNewPwds.layer.cornerRadius=45/2
        txtNewPwds.backgroundColor=UIColor.white
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtNewPwd.clearButtonMode=UITextFieldViewMode.whileEditing;
        //左视图
        let txtNewPwdsLeft=UIView(frame:CGRect(x:0,y:0,width:50,height:45))
        let txtNewPwdsLeftImg=UIImageView(frame:CGRect(x:20,y:12.5,width:20,height:20))
        txtNewPwdsLeftImg.image=UIImage(named: "login_password")
        txtNewPwdsLeft.addSubview(txtNewPwdsLeftImg)
        txtNewPwds.leftView=txtNewPwdsLeft
        txtNewPwds.leftViewMode=UITextFieldViewMode.always;
        
        btnSubmit.addTarget(self, action:#selector(submit), for: UIControlEvents.touchUpInside)
        btnSubmit.layer.cornerRadius=40/2
    }
    @objc private func submit(){
        let newPwd=txtNewPwd.text
        let newPwds=txtNewPwds.text
        let oldPwd=txtOldPwd.text
        if oldPwd == nil || oldPwd!.count == 0{
            self.showSVProgressHUD(status: "请输入原密码", type: HUD.info)
            return
        }
        if newPwd == nil || newPwd!.count == 0{
            self.showSVProgressHUD(status: "新密码不能为空", type: HUD.info)
            return
        }
        if newPwd!.count < 6{
            self.showSVProgressHUD(status: "新密码最少需要6位数", type: HUD.info)
            return
        }
        if newPwd != newPwds{
            self.showSVProgressHUD(status: "两次输入的密码不一致", type: HUD.info)
            return
        }
        self.showSVProgressHUD(status: "正在修改...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.updatePwd(memberId:MEMBERID, oldpassword: oldPwd!, password: newPwd!), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status: "修改成功", type: HUD.success)
                self.navigationController?.popViewController(animated: true)
            }else if success == "error"{
                self.showSVProgressHUD(status:"原始密码错误", type: HUD.error)
            }else{
                self.showSVProgressHUD(status: "修改密码失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status: error!, type: HUD.error)
        }
    }
}
