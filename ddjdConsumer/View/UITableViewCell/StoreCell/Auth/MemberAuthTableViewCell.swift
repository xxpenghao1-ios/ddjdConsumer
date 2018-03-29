//
//  MemberAuthTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/23.
//  Copyright © 2018年 zltx. All rights reserved.
//

import UIKit

/// 用户权限信息
class MemberAuthTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bacView: UIView!

    ///会员账号
    @IBOutlet weak var lblAcc: UILabel!

    ///会员昵称
    @IBOutlet weak var lblNickName: UILabel!

    ///删除按钮
    @IBOutlet weak var cancelImg: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bacView.layer.cornerRadius=5
    }

    func updateCell(entity:MemberAuthInfoEntity){
        lblAcc.text=entity.account
        lblNickName.text=entity.nickName
        if entity.arr != nil{
            var y:CGFloat=70
            for i in 0 ..< entity.arr!.count {
                var lab=bacView.viewWithTag(i) as? UILabel
                if lab == nil{
                    lab=UILabel.buildLabel(textColor:UIColor.color333(), font: 14, textAlignment: NSTextAlignment.left)
                    lab?.tag=i
                    lab?.frame=CGRect.init(x:15,y:y,width:200, height:20)
                    lab?.text=entity.arr![i].authName
                    bacView.addSubview(lab!)
                    y+=20
                }
            }
            self.contentView.frame.size.height=y
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
