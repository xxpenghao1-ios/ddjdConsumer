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
