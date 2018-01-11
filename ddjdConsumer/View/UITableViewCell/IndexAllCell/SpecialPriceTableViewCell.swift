//
//  SpecialPriceTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/2.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
import Kingfisher
//特价cell
class SpecialPriceTableViewCell: UITableViewCell {
    ///促销信息图片
    @IBOutlet weak var promotionMsgImg: UIImageView!
    ///加入购物车
    @IBOutlet weak var addCarImg: UIImageView!
    ///商品名称
    @IBOutlet weak var lblGoodName: UILabel!
    ///库存
    @IBOutlet weak var lblStock: UILabel!
    //销量
    @IBOutlet weak var lblSales: UILabel!
    //价格
    @IBOutlet weak var lblPrice: UILabel!
    //商品图片
    @IBOutlet weak var goodImg: UIImageView!
    ///活动时间
    @IBOutlet weak var lblDate: UILabel!
    //促销信息
    @IBOutlet weak var lblPromotionMsg: UILabel!
    ///活动时间背景view
    @IBOutlet weak var dateBacView: UIView!
    //提示图片
    @IBOutlet weak var promptImg: UIImageView!
    var addCarClosure:(() -> Void)?
    ///更新促销结束时间
    var updatePromotionEndTimeSecondsClosure:(() -> Void)?
    private var entity:GoodEntity?

    ///更新促销结束时间
    var updatePromotionEndTimeClosure:(() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        lblDate.adjustsFontSizeToFitWidth=true
        dateBacView.backgroundColor=UIColor.init(red:0, green:0, blue:0,alpha: 0.5)
        addCarImg.isUserInteractionEnabled=true
        let gr=UITapGestureRecognizer(target:self, action: #selector(addCar))
        gr.delegate=self
        addCarImg.addGestureRecognizer(gr)
        ///默认隐藏提示图片
        promptImg.isHidden=true
        //监听倒计时通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.countDownNotification), name:.OYCountDownNotification, object: nil)
    }
    ///加入购物车
    @objc private func addCar(){
        self.addCarClosure?()
    }
    //更新cell
    func updateCell(entity:GoodEntity){
        self.entity=entity
        lblGoodName.text=entity.goodsName
        lblStock.text="库存:\(entity.promotionStock ?? 0)"
        lblSales.text="销量:\(entity.salesCount ?? 0)"
        lblPrice.text="￥\(entity.storeGoodsPrice ?? 0.0)"
        goodImg.kf.setImage(with:URL.init(string:urlImg+entity.goodsPic!), placeholder:UIImage.init(named:goodDefaultImg),options:[.transition(ImageTransition.fade(1))])
        lblPromotionMsg.text=entity.promotionMsg
        ///默认隐藏提示图片
        promptImg.isHidden=true
        ///默认显示促销信息
        lblPromotionMsg.isHidden=false
        promotionMsgImg.isHidden=false
        addCarImg.isHidden=false
        if entity.promotionEndTimeSeconds == nil || entity.promotionEndTimeSeconds! <= 0 {//如果活动时间小于等于0  或者为空 显示活动已结束
            showPromptImg(named: "to_sell_end")
            addCarImg.isHidden=true
        }else{//如果活动没有结束
            if entity.promotionStock == nil || entity.promotionStock! <= 0{//如果促销库存为0
                showPromptImg(named: "to_sell_out")
                addCarImg.isHidden=true
            }
        }
        //赋值
        lblDate.text=lessSecondToDay(entity.promotionEndTimeSeconds ?? 0)
    }
    ///显示提示图片
    private func showPromptImg(named:String){
        promptImg.isHidden=false
        promptImg.image=UIImage.init(named:named)
        self.contentView.isUserInteractionEnabled=false
        lblPromotionMsg.isHidden=true
        promotionMsgImg.isHidden=true
        self.addCarImg.isHidden=true
    }
    ///每次倒计时
    @objc private func countDownNotification() {
        // 计算倒计时
        let countDown = (self.entity?.promotionEndTimeSeconds ?? 0)-OYCountDownManager.sharedManager.timeInterval
        // 重新赋值
        lblDate.text=lessSecondToDay(countDown)
        if countDown <= 0 {//活动结束
            showPromptImg(named: "to_sell_end")
            self.updatePromotionEndTimeSecondsClosure?()
            return;
        }
    }
    /**
     计算剩余时间

     - parameter seconds: 秒

     - returns: 字符
     */
    private func lessSecondToDay(_ seconds:Int) -> String{
        let day=seconds/(24*3600)
        let hour=(seconds%(24*3600))/3600
        let min=(seconds%(3600))/60
        let second=(seconds%60)
        var time:NSString=""
        if seconds >= 0{
            if day == 0{//如果天数等于0
                time=NSString(format:"还剩%i小时%i分%i秒",hour,min,second)
                if hour == 0{
                    time=NSString(format:"还剩%i分%i秒",min,second)
                    if min == 0{
                        time=NSString(format:"还剩%i秒",second)
                        if seconds == 0{
                            return "活动已结束"
                        }
                    }
                }
            }else{
                time=NSString(format:"还剩%i日%i小时%i分%i秒",day,hour,min,second)
            }
        }else{
            return "活动已结束"
        }
        return time as String
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
///监听view点击事件
extension SpecialPriceTableViewCell{
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if NSStringFromClass((touch.view?.classForCoder)!) == "UITableViewCellContentView"{
            return false
        }
        return true
    }
}
