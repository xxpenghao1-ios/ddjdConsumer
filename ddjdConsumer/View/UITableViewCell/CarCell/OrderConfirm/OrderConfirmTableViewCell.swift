//
//  OrderConfirmTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/18.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
import Kingfisher
//确认订单cell
class OrderConfirmTableViewCell: UITableViewCell {
    //促销图片
    @IBOutlet weak var promotionImg: UIImageView!
    //商品名称
    @IBOutlet weak var lblGoodName: UILabel!
    //商品数量
    @IBOutlet weak var lblGoodCount: UILabel!
    //商品价格
    @IBOutlet weak var lblGoodPrice: UILabel!
    //商品图片
    @IBOutlet weak var goodImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        promotionImg.isHidden=true
    }
    func updateCell(entity:GoodEntity){
        lblGoodName.text=entity.goodsName
        entity.goodsCount=entity.goodsCount ?? 1
        lblGoodCount.text="x\(entity.goodsCount!)"
        entity.storeGoodsPrice=entity.storeGoodsPrice ?? 0.0
        lblGoodPrice.text="￥\(entity.storeGoodsPrice!)"
        entity.goodsPic=entity.goodsPic ?? ""
        goodImg.kf.setImage(with:URL(string:urlImg+entity.goodsPic!), placeholder:UIImage(named:goodDefaultImg), options:[.transition(ImageTransition.fade(1))])
        if entity.goodsStutas == 3{
            promotionImg.isHidden=false
        }else{
            promotionImg.isHidden=true
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
