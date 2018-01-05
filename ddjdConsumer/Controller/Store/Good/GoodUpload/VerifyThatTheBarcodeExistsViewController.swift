//
//  VerifyThatTheBarcodeExistsViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/6.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///验证条码是否存在
class VerifyThatTheBarcodeExistsViewController:BaseViewController{
    //条形码
    @IBOutlet weak var txtCode: UITextField!
    
    @IBOutlet weak var txtCodeView: UIView!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="条码验证"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        
        txtCodeView.layer.cornerRadius=45/2
        
        txtCode.font=UIFont.systemFont(ofSize: 14)
        txtCode.attributedPlaceholder=NSAttributedString(string:"请输入条形码", attributes: [NSAttributedStringKey.foregroundColor:UIColor.color999()])
        txtCode.tintColor=UIColor.applicationMainColor()
        txtCode.keyboardType=UIKeyboardType.default;
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtCode.clearButtonMode=UITextFieldViewMode.whileEditing;
        
        codeView.isUserInteractionEnabled=true
        codeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushScanCodeVC)))
        
        btnSubmit.layer.cornerRadius=20
        
        self.navigationItem.rightBarButtonItem=UIBarButtonItem.init(title:"商品库", style: UIBarButtonItemStyle.done, target:self, action:#selector(pushPublicLibraryVC))
    }
    ///跳转到公共商品库
    @objc private func pushPublicLibraryVC(){
        let vc=self.storyboardPushView(type:.storeGood, storyboardId:"GoodPublicLibraryListVC") as! GoodPublicLibraryListViewController
        self.navigationController?.pushViewController(vc,animated:true)
    }
    ///跳转到扫码获取条形码页面
    @objc private func pushScanCodeVC(){
        LBXPermissions.authorizeCameraWith { [weak self] (granted) in

            if granted
            {
                if let strongSelf = self
                {
                    let vc=ScanCodeGetBarcodeViewController()
                    vc.codeInfoClosure={ (code) in
                        strongSelf.txtCode.text=code
                    }
                    strongSelf.navigationController?.pushViewController(vc, animated:true)
                }
            }
            else
            {
                LBXPermissions.jumpToSystemPrivacySetting()
            }
        }
    }
    @IBAction func submit(_ sender: UIButton) {
        queryGoodsCodeIsExist()
    }
    private func queryGoodsCodeIsExist(){
        let code=txtCode.text
        if code == nil || code!.count == 0{
            self.showSVProgressHUD(status:"条形码不能为空", type: HUD.info)
            return
        }
        self.showSVProgressHUD(status:"正在验证...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.queryGoodsCodeIsExist(goodsCode:code!, storeId:STOREID), successClosure: { (json) in
            let success=json["success"].stringValue
            self.dismissHUD()
            if success == "notExist"{//如果条码不存在
                let entity=GoodUploadEntity()
                entity.goodsCode=code
                self.pushGoodUploadVC(entity:entity)
                return
            }
            let exist=json["exist"].bool
            if exist != nil{
                if exist!{ //店铺已拥有
                    let goodEnity=self.jsonMappingEntity(entity:GoodEntity.init(), object:json["querySag"].object)
                    UIAlertController.showAlertYesNo(self, title:"", message:"该商品已经在您的商品库了", cancelButtonTitle:"不去", okButtonTitle:"去看看", okHandler: { (action) in
                        let vc=self.storyboardPushView(type:.storeGood, storyboardId:"UpdateStoreGoodDetailVC") as! UpdateStoreGoodDetailViewController
                        vc.goodEntity=goodEnity
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                }else{//店铺未拥有 商品库存在
                    let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object:json["queryGoodsInfo"].object)
                    let vc=self.storyboardPushView(type:.storeGood, storyboardId:"UpdateStoreGoodDetailVC") as! UpdateStoreGoodDetailViewController
                    ///默认上架状态
                    entity?.goodsFlag=1
                    vc.goodEntity=entity
                    vc.flag=1
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    private func pushGoodUploadVC(entity:GoodUploadEntity?){
        let vc=UIStoryboard(name:storyboardType.storeGood.rawValue, bundle:nil).instantiateViewController(withIdentifier:"GoodUploadVC") as! GoodUploadViewController;
        vc.goodEntity=entity
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
