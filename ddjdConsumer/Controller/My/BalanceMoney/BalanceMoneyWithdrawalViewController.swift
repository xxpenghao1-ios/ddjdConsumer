//
//  BalanceMoneyWithdrawalViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/5.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///余额提现
class BalanceMoneyWithdrawalViewController:BaseViewController {
    ///余额
    @IBOutlet weak var lblBalanceMoney: UILabel!
    ///提现
    @IBOutlet weak var btnSubmit: UIButton!
    ///提现金额
    @IBOutlet weak var txtWithdrawalMoney: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="余额提现"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
    ///全部提现
    @IBAction func allWithdrawal(_ sender: UIButton) {
    }
}

// MARK: - 页面设置
extension BalanceMoneyWithdrawalViewController{
    private func setUpView(){
        txtWithdrawalMoney.font=UIFont.systemFont(ofSize: 14)
        txtWithdrawalMoney.adjustsFontSizeToFitWidth=true;
        txtWithdrawalMoney.tintColor=UIColor.applicationMainColor()
        txtWithdrawalMoney.keyboardType=UIKeyboardType.decimalPad;
        txtWithdrawalMoney.layer.cornerRadius=45/2
        txtWithdrawalMoney.backgroundColor=UIColor.white
        //不为空，且在编辑状态时（及获得焦点）显示清空按钮
        txtWithdrawalMoney.clearButtonMode=UITextFieldViewMode.whileEditing;
        txtWithdrawalMoney.delegate=self
        //左视图
        let txtWithdrawalMoneyLeft=UIView(frame:CGRect(x:0,y:0,width:50,height:45))
        let txtWithdrawalMoneyLeftImg=UIImageView(frame:CGRect(x:20,y:10,width:25,height:25))
        txtWithdrawalMoneyLeftImg.image=UIImage(named: "balance_money")
        txtWithdrawalMoneyLeft.addSubview(txtWithdrawalMoneyLeftImg)
        txtWithdrawalMoney.leftView=txtWithdrawalMoneyLeft
        txtWithdrawalMoney.leftViewMode=UITextFieldViewMode.always;
        txtWithdrawalMoney.addTarget(self, action:#selector(textFieldDidChange), for: UIControlEvents.editingChanged)


//        btnSubmit.addTarget(self, action:#selector(submit), for: UIControlEvents.touchUpInside)
        btnSubmit.layer.cornerRadius=40/2
    }
}
extension BalanceMoneyWithdrawalViewController:UITextFieldDelegate{
    //监听输入
    @objc func textFieldDidChange(_ textField:UITextField){
        if textField.text != nil && textField.text != ""{
            btnSubmit.enable()
        }else{
            btnSubmit.disable()
        }
    }
}
