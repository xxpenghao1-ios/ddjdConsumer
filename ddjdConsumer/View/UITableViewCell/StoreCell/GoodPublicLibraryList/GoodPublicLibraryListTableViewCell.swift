//
//  GoodPublicLibraryListTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/21.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
import Kingfisher
///公共商品库cell
class GoodPublicLibraryListTableViewCell: UITableViewCell {
    ///商品图片
    @IBOutlet weak var goodImg: UIImageView!
    ///商品名称
    @IBOutlet weak var lblGoodName: UILabel!
    ///商品价格
    @IBOutlet weak var lblStoreGoodsPrice: UILabel!
    ///商品单位
    @IBOutlet weak var lblGoodsUnit: UILabel!
    ///选择
    @IBOutlet weak var btnSelected:UIButton!
    ///添加
    @IBOutlet weak var btnAdd: UIButton!
    //选中商品
    var isSelectedGoodClosure:((_ checkOrCance:Int) -> Void)?
    //添加到门店
    var addClosure:(() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        btnSelected.setImage(UIImage(named:"uncheck"), for: UIControlState.normal)
        btnSelected.setImage(UIImage(named:"checked"), for: UIControlState.selected)
        btnSelected.addTarget(self, action: #selector(isChecked), for: UIControlEvents.touchUpInside)
        btnAdd.addTarget(self, action: #selector(add), for: UIControlEvents.touchUpInside)
        // Initialization code
    }
    func updateCell(entity:GoodEntity){
        lblGoodName.text=entity.goodsName
        lblGoodsUnit.text="/\(entity.goodsUnit ?? "")"
        lblStoreGoodsPrice.text="￥\(entity.goodsPrice ?? 0.0)"
        self.goodImg.image=entity.image
        btnSelected.isSelected=entity.checkOrCance == 1 ? true:false
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
    ///添加到门店
    @objc private func add(){
        addClosure?()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
