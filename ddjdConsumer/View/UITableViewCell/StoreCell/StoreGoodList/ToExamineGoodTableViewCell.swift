//
//  ToExamineGoodTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/18.
//  Copyright © 2018年 zltx. All rights reserved.
//

import UIKit
import Kingfisher
///审核商品cell
class ToExamineGoodTableViewCell: UITableViewCell {
    ///商品图片
    @IBOutlet weak var goodImg: UIImageView!
    ///商品名称
    @IBOutlet weak var lblGoodName: UILabel!
    ///审核错误信息
    @IBOutlet weak var lblExamineInfo: UILabel!
    ///审核状态
    @IBOutlet weak var lblExamineGoodsFlag: UILabel!
    ///商品价格
    @IBOutlet weak var lblPrice: UILabel!
    ///商品单位
    @IBOutlet weak var lblUnit: UILabel!
    ///商品库存
    @IBOutlet weak var lblStock: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    func updateCell(entity:GoodEntity){
        lblGoodName.text=entity.goodsName
        lblUnit.text="/\(entity.goodsUnit ?? "")"
        lblStock.text="库存:\(entity.stock ?? 0)"
        lblPrice.text="￥\(entity.storeGoodsPrice ?? 0.0)"
        if entity.examineGoodsFlag != nil{
            switch entity.examineGoodsFlag!{
            case 1:
                lblExamineGoodsFlag.text="审核中"
                self.accessoryType = .none
                break
            case 2:
                lblExamineGoodsFlag.text="审核失败"
                lblExamineInfo.text="失败原因:\(entity.examineInfo ?? "")"
                self.accessoryType = .disclosureIndicator
                break
            case 3:
                lblExamineGoodsFlag.text="审核成功"
                self.accessoryType = .none
                break
            default:
                break
            }
        }
        entity.goodsPic=entity.goodsPic ?? ""
        goodImg.kf.setImage(with:URL(string:urlImg+entity.goodsPic!), placeholder:UIImage(named:goodDefaultImg), options:[.transition(ImageTransition.fade(1))])
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
