//
//  BindWxAndAliDetailViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/13.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Kingfisher
///详情页面
class BindWxAndAliDetailViewController:BaseViewController{
    ///图像路径
    var imgPic:String?
    ///昵称
    var name:String?
    ///1微信 2支付宝
    var flag:Int?

    var randCode:String?
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if  flag == 1{
            self.title="微信账号信息"
        }else{
            self.title="支付宝账号信息"
        }
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        table.dataSource=self
        table.delegate=self
        table.tableFooterView=UIView(frame: CGRect.zero)
    }
    //修改绑定信息
    @IBAction func updateBindInfo(_ sender: UIButton) {
        verificationCode(flag:flag!)
    }
    ///验证  1微信 2支付宝
    private func verificationCode(flag:Int){
        if randCode == nil{//如果没有输入 发送验证码
            UIAlertController.showAlertYesNo(self, title:"安全验证", message:"防止账号被其他人绑定,请先获取验证码", cancelButtonTitle:"取消", okButtonTitle:"获取验证码") { (action) in
                self.sendVerificationCode(flag:flag)
            }
        }else{//直接去绑定
            if flag == 1{//微信
                WXApiManager.shared.login(self, loginSuccess: { (code) in
                    self.updateStoreBindWx(code:code)
                }, loginFail: {
                    self.showSVProgressHUD(status:"绑定失败", type: HUD.error)
                })
            }else{//支付宝
                self.query_ali_AuthParams()
            }
        }
    }
    ///1微信 2支付宝
    private func inputVerificationCode(flag:Int){
        let alert = UIAlertController(title:"重要提示", message:"如果您取消输入验证码,需要等待1分钟以后才能重新获得验证码", preferredStyle: UIAlertControllerStyle.alert);
        alert.addTextField(configurationHandler: { (txt) in
            txt.keyboardType = .numberPad
            txt.placeholder="请输入验证码"
            NotificationCenter.default.addObserver(self, selector: #selector(self.alertTextFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange,object:txt)
        })
        //确定
        let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default,handler:{ Void in
            let text=(alert.textFields?.first)! as UITextField
            if text.text != nil{
                if self.randCode == text.text{
                    if flag == 1{//微信
                        WXApiManager.shared.login(self, loginSuccess: { (code) in
                            self.updateStoreBindWx(code:code)
                        }, loginFail: {
                            self.showSVProgressHUD(status:"绑定失败", type: HUD.error)
                        })
                    }else{//支付宝
                        self.query_ali_AuthParams()
                    }
                }else{
                    self.showSVProgressHUD(status:"验证码输入错误", type: HUD.error)
                    self.inputVerificationCode(flag:flag)
                }
            }
        })
        let cAction=UIAlertAction(title:"取消", style: UIAlertActionStyle.cancel) { (action) in
            ///清空验证码
            self.randCode=nil
        }
        alert.addAction(cAction)
        alert.addAction(okAction)
        okAction.isEnabled=false
        self.present(alert, animated: true, completion: nil)
    }
    //检测输入框
    @objc func alertTextFieldDidChange(_ notification: Notification){
        let alertController = self.presentedViewController as! UIAlertController?
        if (alertController != nil) {
            let text = (alertController!.textFields?.first)! as UITextField
            let okAction = alertController!.actions.last! as UIAlertAction
            if text.text != nil && text.text!.count > 0 {
                okAction.isEnabled = true
            }else{
                okAction.isEnabled=false
            }
        }
    }
}
extension BindWxAndAliDetailViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=tableView.dequeueReusableCell(withIdentifier:"id")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "id")
        }
        cell!.textLabel!.font=UIFont.systemFont(ofSize:15)
        let img=UIImageView(frame:CGRect.init(x:boundsWidth-55,y:5,width:40,height: 40))
        cell!.contentView.addSubview(img)
        imgPic=imgPic ?? ""
        img.kf.setImage(with:URL(string:imgPic!), placeholder:UIImage(named:memberDefualtImg), options:[.transition(ImageTransition.fade(1))])
        if indexPath.row == 0{
            cell!.textLabel!.text=name
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated:true)
    }
}
///网络请求
extension BindWxAndAliDetailViewController{
    //查询店铺是否绑定微信或者支付宝 ，并返回相应的基本信息
    private func queryStoreBindWxOrAliStatu(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreBindWxOrAlipayApi.queryStoreBindWxOrAliStatu(storeId:STOREID), successClosure: { (json) in

            if self.flag == 2{
                self.name=json["alipayforstoreInfo"]["alipayNickName"].string
                self.imgPic=json["alipayforstoreInfo"]["alipayAvatar"].string
            }else{
                self.name=json["wxforstoreInfo"]["wx_nickname"].string
                self.imgPic=json["wxforstoreInfo"]["wx_headimgurl"].string
            }
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///绑定支付宝账号
    private func updateStoreBindAli(auth_code:String){
        self.showSVProgressHUD(status:"正在绑定...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreBindWxOrAlipayApi.updateStoreBindAli(storeId:STOREID,auth_code:auth_code), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.dismissHUD()
                UIAlertController.showAlertYes(self, title:"更换绑定账号成功", message: "您已成功更换绑定支付宝账号", okButtonTitle:"知道了", okHandler: { (action) in
                    self.queryStoreBindWxOrAliStatu()
                })

            }else if success == "exist"{
                self.showSVProgressHUD(status:"此店铺已绑定其他支付宝", type: HUD.info)
            }else if success == "aliUserIdExist"{
                self.showSVProgressHUD(status:"此支付宝已经绑定其他的账号了", type: HUD.info)
            }else{
                self.showSVProgressHUD(status:"绑定失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status: error!, type: HUD.error)
        }
    }
    ///获取支付宝授权参数 ； 调起支付宝授权所需的请求参数
    private func query_ali_AuthParams(){
        self.showSVProgressHUD(status:"正在调起支付宝...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreBindWxOrAlipayApi.query_ali_AuthParams(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description, dicAny: ["storeId":STOREID])),successClosure: { (json) in
            self.dismissHUD()
            let str=json["ali_auth_app_login"].stringValue

            AliPayManager.shared.login(self, withInfo:str, loginSuccess: { (str) in
                let resultArr=str.components(separatedBy:"&")
                for(subResult) in resultArr{
                    if subResult.count > 10 && subResult.hasPrefix("auth_code="){
                        let auth_code=subResult[subResult.index(subResult.startIndex, offsetBy:10)...]
                        self.updateStoreBindAli(auth_code:String(auth_code))
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
    ///绑定微信
    private func updateStoreBindWx(code:String){
        self.showSVProgressHUD(status:"正在绑定...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreBindWxOrAlipayApi.updateStoreBindWx(storeId:STOREID, code: code), successClosure: { (json) in

            let success=json["success"].stringValue
            if success == "success"{
                self.dismissHUD()
                UIAlertController.showAlertYes(self, title:"更换绑定账号成功", message: "您已成功更换绑定微信账号", okButtonTitle:"知道了", okHandler: { (action) in
                    self.queryStoreBindWxOrAliStatu()
                })
            }else if success == "openIdExist"{
                self.showSVProgressHUD(status:"此微信已经绑定了其他店铺", type: HUD.error)
            }else{
                self.showSVProgressHUD(status:"绑定失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///发送验证码 1微信 2支付宝
    private func sendVerificationCode(flag:Int){
        ///获取账号
        let account=userDefaults.object(forKey:"account") as? String ?? ""
        self.showSVProgressHUD(status:"正在获取验证码...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:LoginWithRegistrApi.duanxinValidate(account:account, flag:3), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.dismissHUD()
                self.randCode=json["randCode"].stringValue
                self.inputVerificationCode(flag:flag)
            }else{
                self.showSVProgressHUD(status:"获取验证码失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
