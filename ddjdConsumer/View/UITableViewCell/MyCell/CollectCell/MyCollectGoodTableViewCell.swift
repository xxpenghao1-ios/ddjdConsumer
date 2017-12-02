//
//  MyCollectGoodTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/18.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
import Kingfisher
//我的收藏
class MyCollectGoodTableViewCell: UITableViewCell {
    //商品图片
    @IBOutlet weak var goodImg: UIImageView!
    //商品名称
    @IBOutlet weak var lblGoodName: UILabel!
    //商品价格
    @IBOutlet weak var lblGoodPrice: UILabel!
    //加入购物车图片
    @IBOutlet weak var addCarImg: UIImageView!
    
    var addCarClosure:(() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        addCarImg.isUserInteractionEnabled=true
        addCarImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addCar)))
    }
    ///加入购物车
    @objc private func addCar(){
        addCarClosure?()
    }
    func updateCell(entity:GoodEntity){
        lblGoodName.text=entity.goodsName
        entity.storeGoodsPrice=entity.storeGoodsPrice ?? 0.0
        lblGoodPrice.text="￥\(entity.storeGoodsPrice!)"
        entity.goodsPic=entity.goodsPic ?? ""
        goodImg.kf.setImage(with:URL(string:urlImg+entity.goodsPic!), placeholder:UIImage(named:goodDefaultImg), options:[.transition(ImageTransition.fade(1))])
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
