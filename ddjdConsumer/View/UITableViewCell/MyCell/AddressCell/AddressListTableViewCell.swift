//
//  AddressListTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/13.
//  Copyright © 2017年 zltx. All rights reserved.
//

import UIKit
//收货地址列表
class AddressListTableViewCell: UITableViewCell{
    //名称
    @IBOutlet weak var lblName: UILabel!
    //手机号码
    @IBOutlet weak var lblTel: UILabel!
    //收货地址
    @IBOutlet weak var lblAddress: UILabel!
    //是否是默认地址
    @IBOutlet weak var isDefaultAddress: UISwitch!
    //修改收货地址
    @IBOutlet weak var updateAddressView: UIView!
    //边线
    @IBOutlet weak var borderView: UIView!
    //顶部间隔
    @IBOutlet weak var topBacView: UIView!
    //定义闭包跳转页面
    var pushUpdateAddressVCClosure:(() -> Void)?
    //设置默认地址
    var setDefaultAddressClosure:(() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        borderView.backgroundColor=UIColor.viewBackgroundColor()
        topBacView.backgroundColor=UIColor.viewBackgroundColor()
        lblName.textColor=UIColor.color333()
        lblTel.textColor=UIColor.color333()
        lblAddress.textColor=UIColor.color333()
        isDefaultAddress.transform=CGAffineTransform(scaleX: 0.75, y: 0.75)
        isDefaultAddress.onTintColor = UIColor.applicationMainColor()
        isDefaultAddress.addTarget(self, action: #selector(setDefaultAddress), for: UIControlEvents.valueChanged)
        updateAddressView.isUserInteractionEnabled=true
        updateAddressView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(updateAddressInfo)))
        self.selectionStyle = .none
        // Initialization code
    }
    //更新数据
    func updateCell(entity:ShippAddressEntity){
        lblName.text=entity.shippName
        lblTel.text=entity.phoneNumber
        entity.address=entity.address ?? ""
        entity.detailAddress=entity.detailAddress ?? ""
        lblAddress.text=entity.address!+entity.detailAddress!
        if entity.defaultFlag == 1{//如果是默认地址
            isDefaultAddress.isOn=true
        }else{
            isDefaultAddress.isOn=false
        }
    }
    ///跳转到修改收货地址页面
    @objc private func updateAddressInfo(){
        pushUpdateAddressVCClosure?()
    }
    ///设置默认地址
    @objc private func setDefaultAddress(){
        setDefaultAddressClosure?()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
