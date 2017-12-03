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
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.updateHeadportraiturl(memberId:MEMBERID, headportraiturl: headportraiturl, nickName: nickName), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"修改成功", type: HUD.success)
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
        cell!.textLabel!.textColor=UIColor.color666()
        cell!.textLabel!.font=UIFont.systemFont(ofSize:15)
        cell!.accessoryType = .disclosureIndicator
        cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:15)
        if indexPath.row == 0{
            cell!.textLabel!.text="更换头像"
            memberImg=UIImageView(frame:CGRect(x:boundsWidth-80, y:10, width:40, height:40))
            memberInfo!.headportraiturl=memberInfo!.headportraiturl ?? ""
            memberImg.kf.setImage(with:URL(string:urlImg+memberInfo!.headportraiturl!), placeholder:UIImage(named:memberDefualtImg), options:[.transition(ImageTransition.fade(1))])
            memberImg.clipsToBounds=true
            memberImg.layer.cornerRadius=20
            cell!.contentView.addSubview(memberImg)
        }else{
            cell!.textLabel!.text="昵称"
            cell!.detailTextLabel!.text=memberInfo!.nickName
            
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
        if indexPath.row == 0{
            let vc=TZImagePickerController.init(maxImagesCount:1, columnNumber:4, delegate:nil,pushPhotoPickerVc:true)
            //隐藏原图按钮
            vc?.allowPickingOriginalPhoto=false
            //用户不能选择视频
            vc?.allowPickingVideo=false
            vc?.showSelectBtn = false;
            
            //允许圆形剪裁
            vc?.needCircleCrop = true
            // 设置竖屏下的裁剪尺寸
            let widthHeight = self.view.tz_width - 2 * 30;
            let top = (self.view.tz_height - widthHeight) / 2;
            vc!.cropRect = CGRect.init(x:30, y:top, width: widthHeight, height: widthHeight)
            vc?.didFinishPickingPhotosHandle={ (photos,assets,isSelectOriginalPhoto) in
                
            }
            self.present(vc!, animated:true, completion:nil)
        }else{
            
        }
    }
}

