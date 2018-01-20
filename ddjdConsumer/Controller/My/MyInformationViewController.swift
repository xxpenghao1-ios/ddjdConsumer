//
//  MyInformationViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/13.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Kingfisher
import TZImagePickerController
//我的信息
class MyInformationViewController:BaseViewController{
    ///接收会员信息
    var memberInfo:MemberEntity?
    //table
    @IBOutlet weak var table: UITableView!
    //会员头像
    private var memberImg:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="我的信息"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        table.backgroundColor=UIColor.viewBackgroundColor()
        table.delegate=self
        table.dataSource=self
        table.tableFooterView=UIView(frame: CGRect.zero)
        table.tableHeaderView=UIView(frame:CGRect(x:0,y:0,width:boundsWidth,height: 10))
        memberInfo=memberInfo ?? MemberEntity()
    }
}
extension MyInformationViewController{
    private func updateHeadportraiturl(headportraiturl:String?,nickName:String?){
        self.showSVProgressHUD(status:"正在修改...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.updateHeadportraiturl(memberId:MEMBERID, headportraiturl: headportraiturl, nickName: nickName), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"修改成功", type: HUD.success)
                self.memberInfo!.nickName=nickName
                self.table.reloadData()
            }else{
                self.showSVProgressHUD(status:"修改失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status: error!, type: HUD.error)
        }
    }
}
//table 协议
extension MyInformationViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"myInfoId")
        if cell == nil{
            cell=UITableViewCell(style: .value1, reuseIdentifier:"myInfoId")
        }
        cell!.textLabel!.textColor=UIColor.color333()
        cell!.textLabel!.font=UIFont.systemFont(ofSize:14)
        cell!.accessoryType = .disclosureIndicator
        cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:14)
        if indexPath.row == 0{
            cell!.textLabel!.text="昵称"
            cell!.detailTextLabel!.text=memberInfo!.nickName
        }else if indexPath.row == 1{
            cell!.textLabel!.text="修改密码"
        }else if indexPath.row == 2{
            cell!.textLabel!.text="修改支付密码"
        }else if indexPath.row == 3{
            cell!.textLabel!.text="合伙人福利信息"
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memberInfo?.partnerStatu == 2{
            return 4
        }
        return 3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中效果颜色
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0{
            showUpdateNickName()
        }else if indexPath.row == 1{
            let vc=self.storyboardPushView(type:.my, storyboardId:"UpdatePasswordVC") as! UpdatePasswordViewController
            self.navigationController?.pushViewController(vc, animated:true)
        }else if indexPath.row == 2{
            let vc=self.storyboardPushView(type:.my, storyboardId:"SetThePaymentPasswordVC") as! SetThePaymentPasswordViewController
            self.navigationController?.pushViewController(vc, animated:true)
        }else if indexPath.row == 3{
            let vc=MemberPartnerDetailViewController()
            self.navigationController?.pushViewController(vc, animated:true)
        }
    }
}
extension MyInformationViewController{
    ///修改昵称
    private func showUpdateNickName(){
        let alertController = UIAlertController(title:"", message:"修改昵称", preferredStyle: UIAlertControllerStyle.alert);
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.keyboardType=UIKeyboardType.default
            textField.placeholder="请输入昵称"
            NotificationCenter.default.addObserver(self, selector: #selector(self.alertTextFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
        }
        //确定
        let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default,handler:{ Void in
            let text=(alertController.textFields?.first)! as UITextField
            self.updateHeadportraiturl(headportraiturl:nil, nickName:text.text)
        })
        //取消
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        okAction.isEnabled = false
        self.present(alertController, animated: true, completion: nil)
    }
    //检测输入框的字符是否大于库存数量 是解锁确定按钮
    @objc func alertTextFieldDidChange(_ notification: Notification){
        let alertController = self.presentedViewController as! UIAlertController?
        if (alertController != nil) {
            let text = (alertController!.textFields?.first)! as UITextField
            let okAction = alertController!.actions.last! as UIAlertAction
            if text.text != nil && text.text! != ""{
                if text.text!.count > 0{
                    okAction.isEnabled = true
                }else{
                    okAction.isEnabled=false
                }
            }else{
                okAction.isEnabled=false
            }
        }
    }
}
