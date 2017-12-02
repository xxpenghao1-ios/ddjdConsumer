//
//  UpdateAddAddressInfoViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/13.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
class UpdateAddAddressInfoViewController:BaseViewController{
    ///1添加 2修改
    var flag:Int?
    ///接收传入地址信息
    var entity:ShippAddressEntity?
    //收货人姓名
    @IBOutlet weak var txtName: UITextField!
    //收货人电话
    @IBOutlet weak var txtTel: UITextField!
    //收货地址
    @IBOutlet weak var lblAddress: UILabel!
    //详细地址
    @IBOutlet weak var txtDetailsAddress: UITextField!
    //是否是默认地址
    @IBOutlet weak var isDefault: UISwitch!
    ///保存地图信息
    private var poiEntity:PoiEntity?
    override func viewDidLoad() {
        super.viewDidLoad()
        if flag == 1{
            self.title="添加收货地址"
        }else{
            self.title="修改收货地址"
        }
        if entity != nil{
            poiEntity=PoiEntity()
            poiEntity?.lat=Double(entity!.lat!)
            poiEntity?.lon=Double(entity!.lon!)
            poiEntity?.name=entity!.address
            txtName.text=entity?.shippName
            txtTel.text=entity?.phoneNumber
            lblAddress.text=entity?.address
            txtDetailsAddress.text=entity?.detailAddress
            isDefault.isOn=entity?.defaultFlag == 1 ? true : false
        }
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
    //保存
    @IBAction func save(_ sender: UIButton) {
        let name=txtName.text
        let tel=txtTel.text
        let detailsAddress=txtDetailsAddress.text
        let address=lblAddress.text
        if name == nil || name!.count == 0{
            self.showSVProgressHUD(status:txtName.placeholder!, type: HUD.info)
            return
        }
        if tel == nil || tel!.count == 0{
            self.showSVProgressHUD(status:txtTel.placeholder!, type: HUD.info)
            return
        }
        if tel!.count != 11{
            self.showSVProgressHUD(status:"请输入正确的手机号码", type: HUD.info)
            return
        }
        if address == "请选择收货地址"{
            self.showSVProgressHUD(status:address!, type: HUD.info)
            return
        }
        if detailsAddress == nil || detailsAddress!.count == 0{
            self.showSVProgressHUD(status:txtDetailsAddress.placeholder!, type: HUD.info)
            return
        }
        if poiEntity == nil{
            self.showSVProgressHUD(status:"没有获取到正确的位置信息,请重新选择收货地址", type: HUD.info)
            return
        }
        let defaultFlag=isDefault.isOn ? 1:2
        self.showSVProgressHUD(status:"正在保存...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target: MyApi.saveShippAddress(lat:"\(poiEntity!.lat!)", lon:"\(poiEntity!.lon!)", address:address!, detailAddress:detailsAddress!,shippName:name!, phoneNumber:tel!, memberId: MEMBERID, shippAddressId:entity?.shippAddressId, defaultFlag:defaultFlag), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"保存成功", type: HUD.success)
                self.navigationController?.popViewController(animated:true)
            }else{
                self.showSVProgressHUD(status:"保存失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
        
    }
    //点击view区域收起键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
//设置页面
extension UpdateAddAddressInfoViewController{
    private func setUpView(){
        txtName.textColor=UIColor.color333()
        txtTel.textColor=UIColor.color333()
        txtTel.keyboardType = .phonePad
        lblAddress.textColor=UIColor.color333()
        txtDetailsAddress.textColor=UIColor.color333()
        isDefault.transform=CGAffineTransform(scaleX: 0.75, y: 0.75)
        isDefault.onTintColor = UIColor.applicationMainColor()
        lblAddress.isUserInteractionEnabled=true
        lblAddress.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(pushSelectedRegion)))
    }
    ///跳转到区域选择页面
    @objc private func pushSelectedRegion(){
        let vc=SelectedRegionViewController()
        vc.poiAddressInfoClosure={ (entity) in
            self.poiEntity=entity
            self.lblAddress.text=self.poiEntity?.name
        }
        vc.poiEntity=self.poiEntity
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
