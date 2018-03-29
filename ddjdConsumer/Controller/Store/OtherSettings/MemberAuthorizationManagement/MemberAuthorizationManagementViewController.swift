//
//  MemberAuthorizationManagementViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/22.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///用户授权管理
class MemberAuthorizationManagementViewController:BaseViewController{
    ///table
    private var table:UITableView!

    ///数据源
    private var arr=[MemberAuthInfoEntity]()

    private var flag=false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if flag{
            queryAllStoreAuthMmeber()
        }
        flag=true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="授权管理"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        queryAllStoreAuthMmeber()
    }
}

// MARK: - 页面设置
extension MemberAuthorizationManagementViewController{

    private func setUpView(){
        table=UITableView(frame:CGRect.init(x:15, y:15, width:boundsWidth-30, height:boundsHeight-navHeight-bottomSafetyDistanceHeight), style: UITableViewStyle.grouped)
        table.delegate=self
        table.dataSource=self
        table.layer.cornerRadius=5
        table.backgroundColor=UIColor.clear
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        self.table.emptyDataSetSource=self
        self.table.emptyDataSetDelegate=self
        self.setEmptyDataSetInfo(text:"还没有授权会员")
        self.setLoadingState(isLoading:true)
        self.view.addSubview(table)
        setUpNav()
    }
    private func reloadTable(){
        self.setLoadingState(isLoading:false)
        self.table.reloadData()
    }
    ///设置导航栏
    private func setUpNav(){
        self.navigationItem.rightBarButtonItem=UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target:self, action: #selector(addAuthMember))
    }

    private func setCellHeaderView(view:UITableViewHeaderFooterView,section:Int) -> UITableViewHeaderFooterView{
        let entity=arr[section]
        view.contentView.backgroundColor=UIColor.white
        view.contentView.layer.cornerRadius=5
        var img=view.contentView.viewWithTag(11) as? UIImageView
        if img == nil{
            img=UIImageView(frame: CGRect.init(x:5, y:5, width:50, height:50))
            img!.image=UIImage.init(named:"member_auth")
            img!.tag=11
            view.contentView.addSubview(img!)
        }
        var lblAcc=view.contentView.viewWithTag(22) as? UILabel
        if lblAcc == nil{
            lblAcc=UILabel.buildLabel(textColor:UIColor.color333(), font:15, textAlignment: NSTextAlignment.left)
            lblAcc!.frame=CGRect.init(x:img!.frame.maxX+10, y:10, width:200, height: 20)
            lblAcc!.tag=22
            view.contentView.addSubview(lblAcc!)
        }
        lblAcc!.text=entity.account
        var lblNickName=view.contentView.viewWithTag(33) as? UILabel
        if lblNickName == nil{
            lblNickName=UILabel.buildLabel(textColor: UIColor.color666(), font:14, textAlignment: NSTextAlignment.left)
            lblNickName!.frame=CGRect.init(x:img!.frame.maxX+10, y:30, width: 200, height:20)
            lblNickName!.tag=33
            view.contentView.addSubview(lblNickName!)
        }
        lblNickName!.text=entity.nickName
        var btnCancel=view.contentView.viewWithTag(44) as? UIButton
        if btnCancel == nil{
            btnCancel=UIButton.init(frame: CGRect.init(x:boundsWidth-65, y:20, width:20, height: 20))
            btnCancel!.setImage(UIImage.init(named:"cancel"), for: UIControlState.normal)
            btnCancel!.addTarget(self, action:#selector(self.deleteAuthMember(sender:)), for: UIControlEvents.touchUpInside)
            btnCancel!.tag=44
            view.contentView.addSubview(btnCancel!)
        }
        btnCancel!.paramDic=["section":section]
        return view
    }

    ///删除授权会员
    @objc private func deleteAuthMember(sender:UIButton){
        let section=sender.paramDic!["section"] as! Int
        let entity=arr[section]
        self.httpDeleteAuthMember(memberId:entity.memberId ?? 0, section:section)
    }

    ///添加授权用户
    @objc private func addAuthMember(){
        let vc=self.storyboardPushView(type:.store, storyboardId:"AddMemberAuthorizationManagementVC") as! AddMemberAuthorizationManagementViewController
        self.navigationController?.pushViewController(vc, animated:true)
    }
}

// MARK: - 网络请求
extension MemberAuthorizationManagementViewController{

    /// 查询店铺已经授权的会员
    private func queryAllStoreAuthMmeber(){
        self.arr.removeAll()
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreAuthorizationMemberRelatedApi.queryAllStoreAuthMmeber(storeId:STOREID), successClosure: { (json) in
            print("授权会员信息=\(json)")
            for(_,value) in json{
                let entity=self.jsonMappingEntity(entity:MemberAuthInfoEntity(), object:value.object)
                var arrAuth=[AuthEntity]()
                for(_,value) in value["authInfo"]{
                    let authEntity=self.jsonMappingEntity(entity:AuthEntity(), object:value.object)
                    arrAuth.append(authEntity!)
                }
                entity!.arr=arrAuth
                self.arr.append(entity!)
            }
            self.reloadTable()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.reloadTable()
        }
    }

    ///删除授权会员
    private func httpDeleteAuthMember(memberId:Int,section:Int){
        self.showSVProgressHUD(status:"正在删除...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreAuthorizationMemberRelatedApi.deleteMemberAuth(memberId:memberId), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.arr.remove(at:section)
                self.table.deleteSections([section], with: UITableViewRowAnimation.fade)
                self.table.reloadData()
                self.dismissHUD()
            }else{
                self.showSVProgressHUD(status:"删除失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}

// MARK: - table协议
extension MemberAuthorizationManagementViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"MemberAuthTableViewCellId")
        if cell == nil{
            cell=UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier:"MemberAuthTableViewCellId")
            cell!.selectionStyle = .none
        }
        cell!.textLabel!.font=UIFont.systemFont(ofSize:14)
        let entity=arr[indexPath.section]
        if entity.arr != nil{
            cell!.textLabel!.text=entity.arr![indexPath.row].authName
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arr.count > 0{
            if arr[section].arr != nil{
                return arr[section].arr!.count
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view=table.dequeueReusableHeaderFooterView(withIdentifier:"HeaderId")
        if view == nil{
            view=UITableViewHeaderFooterView(reuseIdentifier:"HeaderId")
        }
        view=setCellHeaderView(view:view!, section:section)
        return view!
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
