//
//  BindStoreViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/4.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///绑定店铺
class BindStoreViewController:BaseViewController{
    //扫码绑定
    @IBOutlet weak var btnSweepCodeBind: UIButton!
    //搜索绑定
    @IBOutlet weak var btnManualOperationBind: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavColor()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reinstateNavColor()
    }
    override func navigationShouldPopOnBackButton() -> Bool {
        userDefaults.removeObject(forKey:"memberId")
        userDefaults.synchronize()
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="绑定门店"
        btnSweepCodeBind.layer.borderColor=UIColor.white.cgColor
        btnSweepCodeBind.layer.borderWidth=1
        btnSweepCodeBind.layer.cornerRadius=5
        btnSweepCodeBind.addTarget(self, action:#selector(sweepCodeBindStore), for: UIControlEvents.touchUpInside)
        btnManualOperationBind.layer.borderWidth=1
        btnManualOperationBind.layer.cornerRadius=5
        btnManualOperationBind.layer.borderColor=UIColor.white.cgColor
        btnManualOperationBind.addTarget(self, action:#selector(searchBindStore), for: UIControlEvents.touchUpInside)
    }
    ///扫码绑定店铺
    @objc private func sweepCodeBindStore(){
        let camera: PrivateResource = .camera
        let propose: Propose = {
            proposeToAccess(camera, agreed: {
                let vc=ScanCodeGetBarcodeViewController()
                vc.flag=1
                vc.codeInfoClosure={ (str) in
                    if str != nil{
                        let arr=str!.components(separatedBy:"_")
                        if arr.count > 2{
                            self.bindStore(bindstoreId:Int(arr[2])!)
                        }else{
                            self.showSVProgressHUD(status:"请扫描店铺二维码", type: HUD.error)
                        }
                    }
                }
                self.navigationController?.pushViewController(vc, animated:true)
            }, rejected: {
                self.alertNoPermissionToAccess(camera)
            })
        }
        showProposeMessageIfNeedFor(camera, andTryPropose: propose)
    }
    ///搜索绑定店铺
    @objc private func searchBindStore(){
        let vc=self.storyboardPushView(type:.my, storyboardId:"UpdateAddAddressInfoVC") as! UpdateAddAddressInfoViewController
        vc.bindStoreFlag=1
        vc.flag=1
        self.navigationController?.pushViewController(vc, animated:true)
    }
    private func bindStore(bindstoreId:Int){
        self.showSVProgressHUD(status:"正在绑定...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.bindStore(memberId:MEMBERID,bindstoreId:bindstoreId), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"绑定成功", type: HUD.success)
                userDefaults.set(bindstoreId,forKey:"bindstoreId")
                userDefaults.synchronize()
                app.jumpToIndexVC()
            }else{
                self.showSVProgressHUD(status:"绑定失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
