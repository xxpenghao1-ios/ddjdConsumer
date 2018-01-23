//
//  OrderListTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/26.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
import Kingfisher
//订单列表cell
class OrderListTableViewCell: UITableViewCell {
    ///促销图片标识
    @IBOutlet weak var promotionImg: UIImageView!
    //商品单位
    @IBOutlet weak var lblUnit: UILabel!
    ///促销提示信息
    @IBOutlet weak var lblPromotionMsg: UILabel!
    ///促销信息提示图片
    @IBOutlet weak var promotionPromptImg: UIImageView!
    //商品图片
    @IBOutlet weak var goodImg: UIImageView!
    //商品价格
    @IBOutlet weak var lblGoodPrice: UILabel!
    //商品数量
    @IBOutlet weak var lblGoodCount: UILabel!
    //商品名称
    @IBOutlet weak var lblGoodName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        promotionImg.isHidden=true
        promotionPromptImg.isHidden=true
    }
    func updateCell(entity:GoodEntity){
        entity.goodsPic=entity.goodsPic ?? ""
        goodImg.kf.setImage(with:URL(string:urlImg+entity.goodsPic!), placeholder:UIImage(named:goodDefaultImg), options:[.transition(ImageTransition.fade(1))])
        lblGoodName.text=entity.goodsName
        entity.goodsMoney=entity.goodsMoney ?? 0.0
        lblGoodPrice.text="￥\(entity.goodsMoney!)"
        lblGoodCount.text="x\(entity.goodsCount!)"
        lblUnit.text="/\(entity.goodsUnit ?? "")"
        if entity.goodsStutas == 3{
            promotionImg.isHidden=false
            promotionPromptImg.isHidden=false
            lblPromotionMsg.text=entity.promotionMsg
        }else{
            promotionImg.isHidden=true
            promotionPromptImg.isHidden=true
            lblPromotionMsg.text=nil
        }

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
