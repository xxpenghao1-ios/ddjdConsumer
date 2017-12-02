//
//  MyInformationViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/13.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
//我的信息
class MyInformationViewController:BaseViewController{
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
    }
}
//table 协议
extension MyInformationViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"myInfoId")
        if cell == nil{
            cell=UITableViewCell(style: .value1, reuseIdentifier:"myInfoId")
        }
        cell!.textLabel!.textColor=UIColor.color666()
        cell!.textLabel!.font=UIFont.systemFont(ofSize:15)
        cell!.accessoryType = .disclosureIndicator
        cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:15)
        if indexPath.row == 0{
            cell!.textLabel!.text="更换头像"
            memberImg=UIImageView(frame:CGRect(x:boundsWidth-80, y:10, width:40, height:40))
            memberImg.image=UIImage(named:memberDefualtImg)
            memberImg.clipsToBounds=true
            memberImg.layer.cornerRadius=20
            cell!.contentView.addSubview(memberImg)
        }else{
            cell!.textLabel!.text="昵称"
            cell!.detailTextLabel!.text="我去"
            
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 60
        }
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

