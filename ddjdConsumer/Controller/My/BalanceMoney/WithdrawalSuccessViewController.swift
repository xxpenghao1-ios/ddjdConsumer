//
//  WithdrawalSuccessViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/10.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///提现成功提示页面
class  WithdrawalSuccessViewController:BaseViewController {
    @IBOutlet weak var btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="提现成功"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        btn.layer.cornerRadius=5
        btn.addTarget(self, action:#selector(popVC), for: UIControlEvents.touchUpInside)
    }
    override func navigationShouldPopOnBackButton() -> Bool {
        popVC()
        return false
    }
    @objc private func popVC(){
        for vc:UIViewController in (self.navigationController?.viewControllers)!{
            if vc.isKind(of:BalanceMoneyRecordViewController.classForCoder()){
                self.navigationController?.popToViewController(vc, animated:true)
            }
        }
    }
}
