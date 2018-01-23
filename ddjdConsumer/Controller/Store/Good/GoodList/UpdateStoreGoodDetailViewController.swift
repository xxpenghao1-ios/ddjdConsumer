//
//  UpdateStoreGoodDetailViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/11.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import SwiftyJSON
import SVProgressHUD
import ObjectMapper
///修改店铺商品详细信息
class UpdateStoreGoodDetailViewController:FormViewController{
    ///接收商品列表中的行索引
    var index:IndexPath?
    ///接收商品信息
    var goodEntity:GoodEntity?
    ///如果值 添加到店铺商品库
    var flag:Int?
    struct Static {
        static let goodsCodeTag = "goodsCode"
        static let goodsNameTag = "goodsName"
        static let goodsUnitTag = "goodsUnit"
        static let goodUcodeTag = "goodUcode"
        static let goodsPriceTag = "goodsPrice"
        static let goodsLiftTag = "goodsLift"
        static let brandTag = "brand"
        static let goodsMixedTag = "goodsMixed"
        static let stockTag = "stock"
        static let offlineStockTag = "offlineStock"
        static let goodsFlagTag = "goodsFlag"
        static let categoryTag = "category"
        static let uploadImgTag = "uploadImg"
        static let button = "button"
        static let flTag="fl"
        static let purchasePriceTag="purchasePrice"
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        goodEntity=goodEntity ?? GoodEntity()
        self.loadForm()
        if flag == nil{
            self.queryStoreAndGoodsDetail()
            self.title="修改商品信息"
        }else{
            self.queryGoodsInfoByGoodsId_store()
            self.title="添加商品"
        }
    }
}
extension UpdateStoreGoodDetailViewController{
    private func loadForm(){
        let form = FormDescriptor()
        
        let section0 = FormSectionDescriptor(headerTitle:"可修改信息", footerTitle:"说明:库存下限（总库存低于此值，线上此商品将显示已售罄)")

        var row=FormRowDescriptor(tag: Static.purchasePriceTag, type: .decimal, title: "商品进货价:")
        if goodEntity!.purchasePrice != nil{
            row.value="\(goodEntity!.purchasePrice!)" as AnyObject
        }
        row.configuration.cell.placeholder="请输入商品进货价"
        section0.rows.append(row)

        row=FormRowDescriptor(tag: Static.goodsPriceTag, type: .decimal, title: "商品零售价:")
        if goodEntity!.storeGoodsPrice != nil{
            row.value="\(goodEntity!.storeGoodsPrice!)" as AnyObject
        }
        row.configuration.cell.placeholder="请输入商品零售价"
        section0.rows.append(row)

        row=FormRowDescriptor(tag: Static.stockTag, type: .number, title: "商品库存:")
        if goodEntity!.stock != nil{
            row.value="\(goodEntity!.stock!)" as AnyObject
        }
        row.configuration.cell.placeholder="请输入商品库存"
        section0.rows.append(row)

        row=FormRowDescriptor(tag: Static.offlineStockTag, type: .number, title: "库存下限:")
        if goodEntity!.offlineStock != nil{
            row.value="\(goodEntity!.offlineStock!)" as AnyObject
        }
        row.configuration.cell.placeholder="请输入库存下限"
        section0.rows.append(row)

        row = FormRowDescriptor(tag: Static.goodsFlagTag, type: .segmentedControl, title: "商品状态")
        row.value=goodEntity!.goodsFlag as AnyObject
        row.configuration.selection.options = ([1, 2] as [Int]) as [AnyObject]
        row.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? Int else { return "" }
            switch option {
            case 1:
                return "上架"
            case 2:
                return "下架"
            default:
                return ""
            }
        }
        row.configuration.cell.appearance = ["titleLabel.font" : UIFont.systemFont(ofSize: 14),"segmentedControl.tintColor":UIColor.applicationMainColor()]
        section0.rows.append(row)
        
        
        let section1 = FormSectionDescriptor(headerTitle:"不可修改(公共商品库信息)", footerTitle: nil)
        row = FormRowDescriptor(tag: Static.goodsCodeTag, type:.label, title: "商品条形码:")
        row.value=goodEntity!.goodsCode as AnyObject
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.goodsNameTag, type:.label, title: "商品名称:")
        row.value=goodEntity!.goodsName as AnyObject
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.goodsUnitTag, type: .label, title: "商品单位:")
        row.value=goodEntity!.goodsUnit as AnyObject
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.goodUcodeTag, type: .label, title: "商品规格:")
        row.value=goodEntity!.goodUcode as AnyObject
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.flTag, type: .label, title:"商品分类:")
        row.value=goodEntity!.goodsCategoryName as AnyObject
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.goodsLiftTag, type: .label, title: "商品保质期:")
        if goodEntity!.goodsLift != nil{
            row.value="\(goodEntity!.goodsLift!)" as AnyObject
        }
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag:Static.brandTag, type: .label, title: "商品品牌:")
        row.value=goodEntity!.brand as AnyObject
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.goodsMixedTag, type: .label, title: "商品配料:")
        row.value=goodEntity!.goodsMixed as AnyObject
        section1.rows.append(row)
        
        let uploadImgRow=FormRowDescriptor(tag: Static.uploadImgTag, type:.uploadImg,title:"")
        uploadImgRow.value=goodEntity!.goodsPic as AnyObject
        section1.rows.append(uploadImgRow)
        
        let section2 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        row = FormRowDescriptor(tag: Static.button, type: .button, title:"提交")
        row.configuration.button.didSelectClosure = { _ in
            self.updateGoodsByStoreAndGoodsId(formValues:self.form.formValues())
        }
        section2.rows.append(row)
        form.sections = [section0,section1,section2]
        self.form=form
    }
}
///网络请求
extension UpdateStoreGoodDetailViewController{
    ///查询店铺商品详情
    private func queryStoreAndGoodsDetail(){
        SVProgressHUD.show(withStatus:"正在加载...")
        SVProgressHUD.setDefaultMaskType(.clear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.queryStoreAndGoodsDetail(storeAndGoodsId:goodEntity!.storeAndGoodsId ?? 0, storeId:STOREID), successClosure: { (json) in

            self.goodEntity=Mapper<GoodEntity>().map(JSONObject:json.object)
            SVProgressHUD.dismiss()
            self.setFormEntity()
            
        }) { (error) in
            self.showInfo(withStatus:error!)
        }
    }
    ///添加值到table中
    private func setFormEntity(){
        self.setValue(self.goodEntity!.brand as AnyObject, forTag:Static.brandTag)
        
        self.setValue(self.goodEntity!.goodsCategoryName as AnyObject, forTag:Static.flTag)
        
        if self.goodEntity!.goodsFlag != nil{
            self.setValue(self.goodEntity!.goodsFlag! as AnyObject, forTag:Static.goodsFlagTag)
        }
        
        self.setValue(self.goodEntity!.goodsCode as AnyObject, forTag:Static.goodsCodeTag)
        
        if self.goodEntity!.goodsLift != nil{
            self.setValue("\(self.goodEntity!.goodsLift!)" as AnyObject, forTag:Static.goodsLiftTag)
        }
        if self.goodEntity!.goodsMixed != nil{
            self.setValue("\(self.goodEntity!.goodsMixed!)" as AnyObject, forTag:Static.goodsMixedTag)
        }
        if self.goodEntity!.offlineStock != nil{
            self.setValue("\(self.goodEntity!.offlineStock!)" as AnyObject, forTag:Static.offlineStockTag)
        }
        self.setValue(self.goodEntity!.goodsUnit as AnyObject, forTag:Static.goodsUnitTag)
        
        self.setValue(self.goodEntity!.goodsName as AnyObject, forTag:Static.goodsNameTag)
        
        self.setValue(self.goodEntity!.goodUcode as AnyObject, forTag:Static.goodUcodeTag)
        
        self.setValue(self.goodEntity!.goodsPic as AnyObject, forTag:Static.uploadImgTag)
        if self.goodEntity!.purchasePrice != nil{
            self.setValue(self.goodEntity!.purchasePrice!.description as AnyObject,forTag:Static.purchasePriceTag)
        }
    }
    ///店铺查询公共商品库商品详情
    private func queryGoodsInfoByGoodsId_store(){
        SVProgressHUD.show(withStatus:"正在加载...")
        SVProgressHUD.setDefaultMaskType(.clear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.queryGoodsInfoByGoodsId_store(goodsId:goodEntity!.goodsId ?? 0), successClosure: { (json) in
            
            self.goodEntity=Mapper<GoodEntity>().map(JSONObject:json.object)
            SVProgressHUD.dismiss()
            self.setFormEntity()
        }) { (error) in
            self.showInfo(withStatus:error!)
        }
    }
    ///修改店铺商品信息
    private func updateGoodsByStoreAndGoodsId(formValues:[String : AnyObject]){
        let json=JSON(formValues)
        let goodsFlag=json[Static.goodsFlagTag].intValue
        let storeGoodsPrice=json[Static.goodsPriceTag].string
        let stock=json[Static.stockTag].string
        let offlineStock=json[Static.offlineStockTag].string
        let purchasePrice=json[Static.purchasePriceTag].string
        if storeGoodsPrice == nil || storeGoodsPrice!.count == 0{
            self.showInfo(withStatus:"商品零售价不能为空")
            return
        }
        if Double(storeGoodsPrice!) == nil || Double(storeGoodsPrice!)! <= 0{
            self.showInfo(withStatus:"商品零售价不能小于0")
            return
        }
        if stock == nil || stock!.count == 0{
            self.showInfo(withStatus:"库存不能为空")
            return
        }
        if Int(stock!) == nil || Int(stock!)! <= 0{
            self.showInfo(withStatus:"库存不能小于0")
            return
        }
        if offlineStock == nil || offlineStock!.count == 0{
            self.showInfo(withStatus:"库存下限不能为空")
            return
        }
        if purchasePrice == nil || purchasePrice!.count == 0{
            self.showInfo(withStatus:"商品进货价不能为空")
            return
        }
        if Double(purchasePrice!) == nil || Double(purchasePrice!)! <= 0{
            self.showInfo(withStatus:"商品进货价不能小于0")
            return
        }
        SVProgressHUD.show(withStatus:"正在提交...")
        SVProgressHUD.setDefaultMaskType(.clear)
        if flag == nil{//修改商品信息
            PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.updateGoodsByStoreAndGoodsId(storeAndGoodsId:goodEntity!.storeAndGoodsId ?? 0, goodsFlag:goodsFlag, storeGoodsPrice: storeGoodsPrice!, stock:Int(stock!) ?? 0,offlineStock: Int(offlineStock!) ?? 0,purchasePrice:purchasePrice!), successClosure: { (json) in
                let success=json["success"].stringValue
                if success == "success"{
                    ///通知列表刷新指定行
                    NotificationCenter.default.post(name:notificationNameUpdateStoreGoodList, object:nil, userInfo:["index":self.index ?? "","goodsFlag":self.goodEntity!.goodsFlag ?? 0])
                    SVProgressHUD.dismiss()
                    UIAlertController.showAlertYesNo(self, title:"修改成功", message:"零售价格:\(storeGoodsPrice!),进货价格:\(purchasePrice!),库存:\(stock!),库存下限:\(offlineStock!),状态:\(goodsFlag==1 ? "上架":"下架")", cancelButtonTitle:"继续修改", okButtonTitle:"返回", okHandler: { (action) in
                        self.navigationController?.popViewController(animated:true)
                    }, cancelHandler: { (action) in
                    })
                }else if success == "error"{
                    self.showError(withStatus:"商品价格或进货价填写有误")
                }else{
                    self.showError(withStatus:"修改失败")
                }
            }) { (error) in
                self.showError(withStatus:error!)
            }
        }else{//分配到店铺商品库
            PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.addGoodsInfoGoToStoreAndGoods_detail(storeId:STOREID, goodsId:goodEntity!.goodsId ?? 0, storeGoodsPrice:storeGoodsPrice!, goodsFlag:goodsFlag, stock:Int(stock!)!, offlineStock:Int(offlineStock!)!,purchasePrice:purchasePrice!), successClosure: { (json) in
                let success=json["success"].stringValue
                if success == "success"{
                    SVProgressHUD.dismiss()
                    UIAlertController.showAlertYes(self, title:"添加成功", message:"零售价格:\(storeGoodsPrice!),进货价格:\(purchasePrice!),库存:\(stock!),库存下限:\(offlineStock!),状态:\(goodsFlag==1 ? "上架":"下架")", okButtonTitle:"确定", okHandler: { (action) in
                        self.navigationController?.popViewController(animated:true)
                    })
                    ///通知列表刷新页面
                    NotificationCenter.default.post(name:notificationNameUpdateStoreGoodList, object:nil, userInfo:nil)
                }else if success == "storeGoodsPrice_error"{
                    self.showError(withStatus:"商品价格或进货价填写有误")
                }else{
                    self.showError(withStatus:"提交失败")
                }
            }) { (error) in
                self.showError(withStatus:error!)
            }
        }
    }
    private func showInfo(withStatus:String){
        SVProgressHUD.showInfo(withStatus:withStatus)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.dismiss(withDelay:2)
    }
    private func showError(withStatus:String){
        SVProgressHUD.showError(withStatus:withStatus)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.dismiss(withDelay:2)
    }
}
