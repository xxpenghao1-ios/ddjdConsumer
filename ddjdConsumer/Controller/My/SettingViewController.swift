//
//  SettingViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/15.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import Kingfisher
///设置页面
class SettingViewController:BaseViewController{
    //table
    @IBOutlet weak var table: UITableView!
    //退出登录
    @IBOutlet weak var btnReturnLogin: UIButton!
    
    //获取缓存
    let cache = KingfisherManager.shared.cache
    
    private var nameArr=["清除缓存","关于我们","当前版本"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="设置"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
}
///设置页面
extension SettingViewController{
    private func setUpView(){
        let headerView=UIView(frame: CGRect(x:0, y:0, width:boundsWidth, height: 10))
        headerView.backgroundColor=UIColor.viewBackgroundColor()
        table.delegate=self
        table.dataSource=self
        table.tableFooterView=UIView(frame: CGRect.zero)
        table.tableHeaderView=headerView
        table.backgroundColor=UIColor.clear
        btnReturnLogin.addTarget(self, action:#selector(returnLogin), for: UIControlEvents.touchUpInside)
    }
}
/// table协议
extension SettingViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=tableView.dequeueReusableCell(withIdentifier:"settingId")
        if cell == nil{
            cell=UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier:"settingId")
        }
        cell!.textLabel!.text=nameArr[indexPath.row]
        cell!.textLabel!.font=UIFont.systemFont(ofSize: 15)
        cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:14)
        cell!.accessoryType = .disclosureIndicator
        cell!.selectionStyle = .none
        if indexPath.row == 2{
            cell!.detailTextLabel!.text="1.0"
            cell!.accessoryType = .none
        }else if indexPath.row == 0{
            cache.calculateDiskCacheSize(completion: { (size) in
                cell!.detailTextLabel!.text="\(size/1024/1024)MB"
            })
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
        if indexPath.row == 0{
            UIAlertController.showAlertYesNo(self, title:"", message:"确认清除缓存吗?", cancelButtonTitle:"取消", okButtonTitle:"确定", okHandler: { (action) in
                self.cache.clearDiskCache(completion: {
                    self.showSVProgressHUD(status:"缓存清除完毕", type: HUD.success)
                    self.table.reloadData()
                })
            })
        }
    }
}
extension SettingViewController{
    //退出登录
    @objc private func returnLogin(){
        UIAlertController.showAlertYesNo(self, title:"温馨提示", message:"确定退出登录吗?退出登录后将接收不到任何信息", cancelButtonTitle:"取消", okButtonTitle:"确定") { (ation) in
            app.jumpToLoginVC()
        }
    }
    
}
