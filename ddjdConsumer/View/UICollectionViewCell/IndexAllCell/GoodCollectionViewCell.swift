//
//  GoodCollectionViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/13.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
import Kingfisher
//商品cell
class GoodCollectionViewCell: UICollectionViewCell {
    //商品图片高度
    @IBOutlet weak var goodImgHeight: NSLayoutConstraint!
    //商品图片
    @IBOutlet weak var goodImg: UIImageView!
    //商品名称
    @IBOutlet weak var lblGoodName: UILabel!
    //商品价格
    @IBOutlet weak var lblPrice: UILabel!
    //商品销量
    @IBOutlet weak var lblSales: UILabel!
    //加入购物车图片
    @IBOutlet weak var addCar: UIImageView!
    //跳转到商品详情
    var pushGoodDetailsVCClosure:(() -> Void)?
    //加入购物
    var goodAddCarClosure:(() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        lblPrice.textColor=UIColor.applicationMainColor()
        goodImgHeight.constant=boundsWidth/2
        goodImg.isUserInteractionEnabled=true
        goodImg.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(pushDetailsVC)))
        addCar.isUserInteractionEnabled=true
        addCar.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(goodAddCarClick)))
    }
    //更新数据
    func updateCell(entity:GoodEntity){
//        entity.goodsPic=entity.goodsPic ?? ""
        entity.salesCount=entity.salesCount ?? 0
        goodImg.image=entity.image
        lblGoodName.text=entity.goodsName
        if entity.storeGoodsPrice != nil{
            lblPrice.text="￥\(entity.storeGoodsPrice!)"
        }
        if entity.salesCount! > 999{
            lblSales.text="销量999+"
        }else{
            lblSales.text="销量\(entity.salesCount!)"
        }
    }
    //跳转到商品详情
    @objc private func pushDetailsVC(){
        pushGoodDetailsVCClosure?()
    }
    //加入购物
    @objc private func goodAddCarClick(){
        goodAddCarClosure?()
    }
}
