//
//  BindWxAndAliViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/13.
//  Copyright © 2017年 zltx. All rights reserved.
//
import Foundation
///绑定微信支付宝
class BindWxAndAliViewController:BaseViewController{
    @IBOutlet weak var table: UITableView!
    private var nameArr=["微信账号","支付宝账号"]
    //是否绑定微信
    private var wxBindStatu=false
    //是否绑定支付宝
    private var aliBindStatu=false
    ///支付用户昵称
    private var alipayNickName:String?
    ///支付宝图像
    private var alipayAvatar:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="收款账号信息"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        table.dataSource=self
        table.delegate=self
        table.tableFooterView=UIView(frame: CGRect.zero)
        queryStoreBindWxOrAliStatu()
    }
}
extension BindWxAndAliViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=tableView.dequeueReusableCell(withIdentifier:"osId")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "osId")
        }
        cell!.accessoryType = .disclosureIndicator
        cell!.textLabel!.text=nameArr[indexPath.row]
        cell!.textLabel!.font=UIFont.systemFont(ofSize:14)
        cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:12)
        if indexPath.row == 0{
            if wxBindStatu{
                cell!.detailTextLabel!.text="已绑定"
            }else{
                cell!.detailTextLabel!.text="未绑定"
            }
        }else{
            if aliBindStatu{
                cell!.detailTextLabel!.text="已绑定"
            }else{
                cell!.detailTextLabel!.text="未绑定"
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated:true)
        if indexPath.row == 0{
            if wxBindStatu{//如果绑定跳转到详情页面
//                pushDetailVC(imgPic: <#T##String?#>, name: <#T##String?#>)
            }else{//绑定
                
            }
        }else{
            if aliBindStatu{ //如果绑定跳转到详情页面
                pushDetailVC(imgPic:alipayAvatar, name:alipayNickName)
            }else{//绑定
                query_ali_AuthParams()
            }
        }
    }
    private func pushDetailVC(imgPic:String?,name:String?){
        let vc=self.storyboardPushView(type:.store, storyboardId:"BindWxAndAliDetailVC") as! BindWxAndAliDetailViewController
        vc.imgPic=imgPic
        vc.name=name
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
///网络请求
extension BindWxAndAliViewController{
    //查询店铺是否绑定微信或者支付宝 ，并返回相应的基本信息
    private func queryStoreBindWxOrAliStatu(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreBindWxOrAlipayApi.queryStoreBindWxOrAliStatu(storeId:STOREID), successClosure: { (json) in
            print(json)
            self.wxBindStatu=json["wxBindStatu"].boolValue
            self.aliBindStatu=json["aliBindStatu"].boolValue
            if self.aliBindStatu{
                self.alipayNickName=json["alipayforstoreInfo"]["alipayNickName"].string
                self.alipayAvatar=json["alipayforstoreInfo"]["alipayAvatar"].string
            }
            if self.wxBindStatu{
            }
            self.table.reloadData()
            userDefaults.set(self.wxBindStatu, forKey:"wxBindStatu")
            userDefaults.set(self.aliBindStatu, forKey:"aliBindStatu")
            userDefaults.synchronize()
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
                UIAlertController.showAlertYes(self, title:"绑定成功", message:"您已成功绑定支付宝账号", okButtonTitle:"知道了")
                self.queryStoreBindWxOrAliStatu()
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
        PHMoyaHttp.sharedInstance.requestDataWithTargetString(target:StoreBindWxOrAlipayApi.query_ali_AuthParams(storeId:STOREID), successClosure: { (str) in
            self.dismissHUD()
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
}

