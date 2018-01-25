//
//  DDVIPViewCcontroller.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/11.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///点单VIP
class DDVIPViewCcontroller:BaseViewController {
    private let storeTel=userDefaults.object(forKey:"storeTel") as? String
    private let vipStatu=userDefaults.object(forKey:"vipStatu") as? Int
    private let partnerStatu=userDefaults.object(forKey:"partnerStatu") as? Int
    @IBOutlet weak var scrollView: UIScrollView!
    ///vip内容
    @IBOutlet weak var lblVIP: UILabel!
    ///合伙人内容
    @IBOutlet weak var lblPartner: UILabel!
    ///vip按钮
    @IBOutlet weak var btnVIP: UIButton!
    ///合伙人按钮
    @IBOutlet weak var btnPartner: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="点单VIP"
        btnVIP.layer.cornerRadius=5
        btnPartner.layer.cornerRadius=5
        if vipStatu == 2{
            btnVIP.setTitle("您已是VIP", for: UIControlState.normal)
            btnVIP.disable()
        }
        if partnerStatu == 2{
            btnPartner.setTitle("您已是合伙人", for: UIControlState.normal)
            btnPartner.disable()
        }
        getVIP()
    }
    ///跳转到充值页面
    @IBAction func pushTopUpVC(_ sender: UIButton) {
        let vc=self.storyboardPushView(type:.my, storyboardId:"BalanceMoneyTopUpVC") as! BalanceMoneyTopUpViewController
        self.navigationController?.pushViewController(vc, animated:true)
    }
    ///联系店铺成为合伙人
    @IBAction func contactStorePartner(_ sender: UIButton) {
        UIAlertController.showAlertYesNo(self, title:"联系店铺老板", message:"您确定要联系店铺老板成为合伙人吗?", cancelButtonTitle:"取消", okButtonTitle:"确定") { (action) in
            if self.storeTel != nil{
                UIApplication.shared.openURL(Foundation.URL(string :"tel://\(self.storeTel!)")!)
            }else{
                self.showSVProgressHUD(status:"没有找到店铺老板联系方式", type: HUD.error)
            }
        }
    }

}

// MARK: - 网络请求
extension DDVIPViewCcontroller{
    private func getVIP(){
        self.showSVProgressHUD(status:"正在加载...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:IndexApi.ddjdvip(storeId:BINDSTOREID), successClosure: { (json) in
            self.lblVIP.text=json["ddjdVipKey"].stringValue
            self.lblPartner.text=json["ddjdPartnerKey"].stringValue
            self.dismissHUD()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.navigationController?.popViewController(animated:true)
        }
    }
}
