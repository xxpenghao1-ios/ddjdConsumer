//
//  CarTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/2.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
import Kingfisher

//购物车cell
class CarTableViewCell: UITableViewCell {
    ///促销图片
    @IBOutlet weak var promotionImg: UIImageView!
    ///促销文字提示图片
    @IBOutlet weak var promtionPromptImg: UIImageView!
    ///促销提示信息
    @IBOutlet weak var lblPromtionMsg: UILabel!
    ///库存背景view
    @IBOutlet weak var stockBacView: UIView!
    ///库存
    @IBOutlet weak var lblStock: UILabel!
    //购物车选中按钮
    @IBOutlet weak var btnChecked: UIButton!
    //商品图片
    @IBOutlet weak var goodImg: UIImageView!
    //商品名称
    @IBOutlet weak var lblGoodName: UILabel!
    //商品价格
    @IBOutlet weak var lblPrice: UILabel!
    //商品数量
    @IBOutlet weak var lblCount: UILabel!
    //增加商品数量
    @IBOutlet weak var btnAddCount: UIButton!
    //减少购物商品数量
    @IBOutlet weak var btnReduceCount: UIButton!
    //商品数量加减view
    @IBOutlet weak var goodCountView: UIView!
    //添加商品数量
    var addGoodCountClosure:(() -> Void)?
    //减少商品数量
    var reduceGoodCountClosure:(() -> Void)?
    //选中商品
    var isSelectedGoodClosure:((_ checkOrCance:Int) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        lblCount.layer.borderWidth=1
        lblCount.layer.borderColor=UIColor.borderColor().cgColor
        lblCount.backgroundColor=UIColor.RGBFromHexColor(hexString: "f1f2f6")
        
        btnAddCount.setTitleColor(UIColor.color666(), for: UIControlState.normal)
        btnAddCount.addTarget(self, action:#selector(addCount), for: UIControlEvents.touchUpInside)
        
        btnChecked.setImage(UIImage(named:"uncheck"), for: UIControlState.normal)
        btnChecked.setImage(UIImage(named:"checked"), for: UIControlState.selected)
        btnChecked.addTarget(self, action:#selector(isChecked), for: UIControlEvents.touchUpInside)
        
        btnReduceCount.setTitleColor(UIColor.color666(), for: .normal)
        btnReduceCount.addTarget(self, action:#selector(reduceCount), for: UIControlEvents.touchUpInside)
        
        goodCountView.layer.borderWidth=1
        goodCountView.layer.borderColor=UIColor.borderColor().cgColor

        stockBacView.backgroundColor=UIColor.init(red:0, green:0, blue:0,alpha: 0.5)

        promotionImg.isHidden=true
        promtionPromptImg.isHidden=true
        self.selectionStyle = .none
        // Initialization code
    }
    //更新购物车
    func updateCell(entity:GoodEntity){
        entity.goodsPic=entity.goodsPic ?? ""
        entity.goodsCount=entity.goodsCount ?? 1
        entity.checkOrCance=entity.checkOrCance ?? 2
        lblGoodName.text=entity.goodsName
        if entity.storeGoodsPrice != nil{
            lblPrice.text="￥\(entity.storeGoodsPrice!)"
        }
        goodImg.kf.setImage(with:URL.init(string:urlImg+entity.goodsPic!), placeholder:UIImage.init(named:goodDefaultImg),options:[.transition(ImageTransition.fade(1))])
        lblCount.text="\(entity.goodsCount!)"
        if entity.checkOrCance == 1{
            btnChecked.isSelected=true
        }else{
            btnChecked.isSelected=false
        }
        if entity.goodsStutas == 3{
            promotionImg.isHidden=false
            promtionPromptImg.isHidden=false
            lblPromtionMsg.text=entity.promotionMsg
            lblStock.text="库存:\(entity.promotionStock ?? 0)"
        }else{
            promotionImg.isHidden=true
            promtionPromptImg.isHidden=true
            lblPromtionMsg.text=nil
            lblStock.text="库存:\(entity.stock ?? 0)"
        }
    }
    //增加商品数量
    @objc private func addCount(){
        addGoodCountClosure?()
    }
    //减少商品数量
    @objc private func reduceCount(){
        reduceGoodCountClosure?()
    }
    //是否选中
    @objc private func isChecked(sender:UIButton){
        if sender.isSelected{
            sender.isSelected=false
            isSelectedGoodClosure?(2)
        }else{
            sender.isSelected=true
            isSelectedGoodClosure?(1)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
