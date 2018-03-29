//
//  OtherSettingsViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/23.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Alamofire
///其他设置
class OtherSettingsViewController:BaseViewController{
    
    @IBOutlet weak var table: UITableView!
    
    private var nameArr=["提现账户信息","授权管理","红包管理","订单起送金额","配送范围","联系方式","营业时间","会员折扣"]
    
    private var entity=StoreEntity()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStoreInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="其他设置"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        table.dataSource=self
        table.delegate=self
        table.tableFooterView=UIView(frame: CGRect.zero)
        self.navigationItem.rightBarButtonItem=UIBarButtonItem.init(image:UIImage.init(named:"about_store")!.reSizeImage(reSize: CGSize.init(width:25, height:25)), style: UIBarButtonItemStyle.done, target:self, action: #selector(showCodeVC))
    }
    @objc private func showCodeVC(){
        let vc=self.storyboardPushView(type:.store, storyboardId: "StoreCodeInfoVC") as! StoreCodeInfoViewController
        vc.storeEntity=entity
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
extension OtherSettingsViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=tableView.dequeueReusableCell(withIdentifier:"osId")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier:"osId")
        }
        cell!.accessoryType = .disclosureIndicator
        cell!.textLabel!.text=nameArr[indexPath.row]
        cell!.textLabel!.font=UIFont.systemFont(ofSize:14)
        cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:12)
        switch  indexPath.row{
        case 3:
            cell!.detailTextLabel!.text=(entity.lowestMoney ?? 0).description+"元"
            break
        case 4:
            cell!.detailTextLabel!.text=(entity.distributionScope ?? 0).description+"km"
            break
        case 5:
            cell!.detailTextLabel!.text=entity.tel
            break
        case 6:
            if entity.distributionStartTime != nil && entity.distributionEndTime != nil{
                cell!.detailTextLabel!.text=(entity.distributionStartTime!)+"-"+(entity.distributionEndTime!)
            }
            break
        case 7:
            cell!.detailTextLabel!.text=entity.memberDiscount?.description
            break
        default:break
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated:true)
        
        switch indexPath.row {
        case 0:
            let vc=self.storyboardPushView(type:.store, storyboardId:"BindWxAndAliVC") as! BindWxAndAliViewController
            self.navigationController?.pushViewController(vc, animated:true)
            break
        case 1:
            let vc = MemberAuthorizationManagementViewController()
            self.navigationController?.pushViewController(vc, animated:true)
            break
        case 2:
            let vc=self.storyboardPushView(type:.store, storyboardId:"RedPackageManagementVC") as! RedPackageManagementViewController
            self.navigationController?.pushViewController(vc, animated:true)
            break
        case 3:
            pushUpdateInfoVC(type:1)
            break
        case 4:
            pushUpdateInfoVC(type:2)
            break
        case 5:
            pushUpdateInfoVC(type:3)
            break
        case 6:
            pushUpdateInfoVC(type:4)
            break
        case 7:
            pushUpdateInfoVC(type:5)
            break
        default:
            break
        }

    }
    ///跳转修改店铺信息页面
    private func pushUpdateInfoVC(type:Int){
        let vc=self.storyboardPushView(type:.store, storyboardId:"UpdateStoreInfoVC") as! UpdateStoreInfoViewController
        vc.type=type
        vc.entity=entity
        self.navigationController?.pushViewController(vc, animated:true)
    }
}

// MARK: - 网络请求
extension OtherSettingsViewController{
    ///请求店铺信息
    private func getStoreInfo(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreInfoApi.queryStoreById(bindstoreId:STOREID), successClosure: { (json) in
            self.entity=self.jsonMappingEntity(entity:StoreEntity.init(), object:json["store"].object) ?? StoreEntity()
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
