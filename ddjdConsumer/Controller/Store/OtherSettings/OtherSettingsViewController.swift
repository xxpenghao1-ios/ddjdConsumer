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
    @IBOutlet weak var table: UITableView!
    private var nameArr=["收款账号信息"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="其他设置"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        table.dataSource=self
        table.delegate=self
        table.tableFooterView=UIView(frame: CGRect.zero)
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
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated:true)
        if indexPath.row == 0{
            let vc=self.storyboardPushView(type:.store, storyboardId:"BindWxAndAliVC") as! BindWxAndAliViewController
            self.navigationController?.pushViewController(vc, animated:true)
        }else{
            
        }
    }
}
