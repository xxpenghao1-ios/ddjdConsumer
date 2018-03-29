//
//  AddMemberAuthorizationManagementViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/22.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///添加授权用户
class AddMemberAuthorizationManagementViewController:BaseViewController{

    ///输入用户账号
    @IBOutlet weak var txtMemberAcc: UITextField!

    ///权限table
    @IBOutlet weak var table: UITableView!

    ///提交
    private var btnSubmit:UIButton!

    ///数据源
    private var arr=[AuthEntity]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="添加授权用户"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        queryAllAuthList()
    }
}

// MARK: - 网络请求
extension AddMemberAuthorizationManagementViewController{

    /// 查询店铺可以授权功能
    private func queryAllAuthList(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreAuthorizationMemberRelatedApi.queryAllAuthList(), successClosure: { (json) in

            self.arr=self.jsonMappingArrEntity(entity:AuthEntity(), object:json.object)
            self.table.reloadData()
        }) { (error) in

            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }

    /// 验证账号 并为账号授权
    private func validateAccAndInertAuth(acc:String,authStr:String){
        self.showSVProgressHUD(status:"正在授权...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreAuthorizationMemberRelatedApi.validateAccAndInertAuth(storeId:STOREID, acc:acc, authStr:authStr), successClosure: { (json) in
            let success=json["success"].stringValue
            switch success{
            case "success":
                self.showSVProgressHUD(status:"授权成功", type: HUD.success)
                self.navigationController?.popViewController(animated:true)
                break
            case "notOpen":
                self.showSVProgressHUD(status:"此账号已经有授权，不能再添加授权。 请删除授权后重新添加", type: HUD.error)
                break
            case "noBind":
                self.showSVProgressHUD(status:"这个账号没有绑定你的店铺，不能授权", type: HUD.error)
                break
            case "haveNoRight":
                self.showSVProgressHUD(status:"不能授权给店铺", type: HUD.error)
                break
            case "notExist":
                self.showSVProgressHUD(status:"账号不存在", type: HUD.error)
                break
            default:
                self.showSVProgressHUD(status:"授权失败", type: HUD.error)
                break

            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }

    }
}
///页面设置
extension AddMemberAuthorizationManagementViewController{

    /// 设置页面
    private func setUpView(){

        txtMemberAcc.clearButtonMode=UITextFieldViewMode.whileEditing
        txtMemberAcc.addTarget(self, action:#selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        table.dataSource=self
        table.delegate=self
        table.tableFooterView=tableFooterView()

    }

    private func tableFooterView() -> UIView{
        let view=UIView.init(frame: CGRect.init(x:0, y:0, width:boundsWidth, height: 80))
        view.backgroundColor=UIColor.clear

        btnSubmit=UIButton.button(type: ButtonType.cornerRadiusButton, text:"确认添加", textColor:UIColor.white, font:15, backgroundColor: UIColor.applicationMainColor(),cornerRadius:20)
        btnSubmit.addTarget(self, action:#selector(submit), for: UIControlEvents.touchUpInside)
        btnSubmit.frame=CGRect.init(x:30,y:20,width:boundsWidth-60,height:40)
        btnSubmit.disable()
        view.addSubview(btnSubmit)

        return view
    }

    ///提交
    @objc private func submit(){
        let acc=txtMemberAcc.text
        if acc == nil || acc!.count == 0{
            self.showSVProgressHUD(status:"请输入授权账号", type: HUD.info)
            return
        }
        var authStr=""
        for entity in arr {
            entity.authId=entity.authId ?? -1
            if entity.isSelected == true{
                authStr+=entity.authId!.description+","
            }
        }
        if authStr == "" || authStr.count < 1{
            self.showSVProgressHUD(status:"请选择授权权限", type: HUD.info)
            return
        }
        self.validateAccAndInertAuth(acc:acc!, authStr:authStr)
    }
    //监听输入框输入
    @objc func textFieldDidChange(_ textField:UITextField){
        if textField.text != nil && textField.text != ""{
            btnSubmit.enable()
        }else{
            btnSubmit.disable()
        }
    }
}
extension AddMemberAuthorizationManagementViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"addAuthid")
        if cell == nil{
            cell=UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier:"addAuthid")
        }
        cell!.textLabel!.textColor=UIColor.color666()
        cell!.textLabel!.font=UIFont.systemFont(ofSize:14)
        let entity=arr[indexPath.row]
        cell!.textLabel!.text=entity.authName
        return cell!

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated:true)
        let entity=arr[indexPath.row]
        let cell=table.cellForRow(at:indexPath)
        if cell!.accessoryType == .checkmark{
            cell?.accessoryType = .none
            entity.isSelected=false
        }else{
            cell?.accessoryType = .checkmark
            entity.isSelected=true
        }
    }
}

