//
//  StoreGoodListTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/8.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
import Kingfisher
///店铺商品列表cell
class StoreGoodListTableViewCell: UITableViewCell {
    ///商品图片
    @IBOutlet weak var goodImg: UIImageView!
    ///库存
    @IBOutlet weak var lblStock: UILabel!
    ///商品名称
    @IBOutlet weak var lblGoodName: UILabel!
    ///商品价格
    @IBOutlet weak var lblStoreGoodsPrice: UILabel!
    ///商品单位
    @IBOutlet weak var lblGoodsUnit: UILabel!
    ///商品销量
    @IBOutlet weak var lblSalesCount: UILabel!
    ///商品上下架
    @IBOutlet weak var lblGoodsFlag: UILabel!
    ///热门推荐图片
    @IBOutlet weak var hotGoodImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        hotGoodImg.isHidden=true
        // Initialization code
    }
    func updateCell(entity:GoodEntity){
        lblGoodName.text=entity.goodsName
        lblGoodsUnit.text="/\(entity.goodsUnit ?? "")"
        lblStock.text="库存:\(entity.stock ?? 0)"
        lblSalesCount.text="销量\(entity.salesCount ?? 0)"
        lblStoreGoodsPrice.text="￥\(entity.storeGoodsPrice ?? 0.0)"
        if entity.goodsFlag != nil{
            lblGoodsFlag.text=entity.goodsFlag == 1 ? "已上架" : "已下架"
        }
        entity.goodsPic=entity.goodsPic ?? ""
        goodImg.kf.setImage(with:URL(string:urlImg+entity.goodsPic!), placeholder:UIImage(named:goodDefaultImg), options:[.transition(ImageTransition.fade(1))])
        if entity.goodsStutas == 1{//普通商品
            hotGoodImg.image=UIImage.init(named:"good_tj")
            if entity.indexGoodsId == nil{
                hotGoodImg.isHidden=true
            }else{
                hotGoodImg.isHidden=false
            }
        }else if entity.goodsStutas == 3{//促销
            hotGoodImg.image=UIImage.init(named:"sales_promotion")
            hotGoodImg.isHidden=false
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
