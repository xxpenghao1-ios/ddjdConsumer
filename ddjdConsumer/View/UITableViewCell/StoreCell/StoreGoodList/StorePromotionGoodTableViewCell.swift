//
//  StorePromotionGoodTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/8.
//  Copyright © 2018年 zltx. All rights reserved.
//

import UIKit
import Kingfisher
///店铺促销商品
class StorePromotionGoodTableViewCell: UITableViewCell {
    @IBOutlet weak var dateBacView: UIView!
    ///商品图片
    @IBOutlet weak var goodImg: UIImageView!
    ///活动结束时间
    @IBOutlet weak var lblGoodEndTime: UILabel!
    ///商品价格
    @IBOutlet weak var lblGoodPrice: UILabel!
    ///商品销量
    @IBOutlet weak var lblSales: UILabel!
    ///商品库存
    @IBOutlet weak var lblStock: UILabel!
    ///商品名称
    @IBOutlet weak var lblGoodName: UILabel!
    ///促销信息
    @IBOutlet weak var lblPromotionMsg: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        lblGoodEndTime.adjustsFontSizeToFitWidth=true
        dateBacView.backgroundColor=UIColor.init(red:0, green:0, blue:0,alpha: 0.5)
    }
    func updateCell(entity:GoodEntity){
        lblGoodName.text=entity.goodsName
        lblStock.text="库存:\(entity.promotionStock ?? 0)"
        lblSales.text="销量:\(entity.salesCount ?? 0)"
        lblGoodPrice.text="￥\(entity.storeGoodsPrice ?? 0.0)"
        goodImg.kf.setImage(with:URL.init(string:urlImg+entity.goodsPic!), placeholder:UIImage.init(named:goodDefaultImg),options:[.transition(ImageTransition.fade(1))])
        lblPromotionMsg.text=entity.promotionMsg
        if entity.promotionEndTimeSeconds == nil || entity.promotionEndTimeSeconds! <= 0{
            self.lblGoodEndTime.text="活动已结束"
        }else{
            if entity.promotionStock == nil || entity.promotionStock! <= 0{
                self.lblGoodEndTime.text="库存不足"
            }else{
                self.lblGoodEndTime.text="\(entity.promotionEndTime ?? "")结束"
            }
        }

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
