//
//  OtherSettingsViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/23.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///其他设置
class OtherSettingsViewController:BaseViewController{
    //
    @IBOutlet weak var table: UITableView!
    private var nameArr=["绑定微信账号","绑定支付宝账号"]
    //是否绑定微信
    private var wxBingStatu=false
    //是否绑定支付宝
    private var aliBingStatu=false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="其他设置"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        table.dataSource=self
        table.delegate=self
        table.tableFooterView=UIView(frame: CGRect.zero)
        queryStoreBindWxOrAliStatu()
    }
}
extension OtherSettingsViewController:UITableViewDataSource,UITableViewDelegate{
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
            if wxBingStatu{
                cell!.detailTextLabel!.text="已绑定"
            }
        }else{
            if aliBingStatu{
                cell!.detailTextLabel!.text="已绑定"
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AliPayManager.shared.login(self, paySuccess: {
            
        }) {
            
        }
    }
}
///网络请求
extension OtherSettingsViewController{
    //查询店铺是否绑定微信或者支付宝 ，并返回相应的基本信息
    func queryStoreBindWxOrAliStatu(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreBindWxOrAlipayApi.queryStoreBindWxOrAliStatu(storeId:STOREID), successClosure: { (json) in
            self.wxBingStatu=json["wxBingStatu"].boolValue
            self.aliBingStatu=json["aliBingStatu"].boolValue
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
