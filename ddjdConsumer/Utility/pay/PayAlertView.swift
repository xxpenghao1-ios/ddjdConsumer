//
//  PayAlertView.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/28.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///支付view
class PayAlert: UIView,UITextFieldDelegate {

    var contentView:UIView?

    var completeBlock : (((String) -> Void)?)

    private var price:String!
    private var textField:UITextField!
    private var inputViewWidth:CGFloat!
    private var passCount:CGFloat!
    private var passWidth:CGFloat!
    private var inputViewX:CGFloat!
    private var pwdCircleArr = [UILabel]()
    ///1订单支付 2提现
    private var payType:Int!
    ///折扣
    private var discount:String!

    init(frame:CGRect,price:String,view:UIView,payType:Int,discount:String) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(red:0, green: 0, blue: 0, alpha:0.5)
        self.inputViewX = 15
        self.passCount = 6
        self.passWidth = (boundsWidth-80-inputViewX*2)/6
        self.inputViewWidth = passWidth * passCount
        self.price=price
        self.payType=payType
        self.discount=discount
        setupView()
        show(view:view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView(){

        contentView =  UIView(frame:CGRect.init(x:40, y:100, width:boundsWidth-80, height:197.5+passWidth))
        contentView!.backgroundColor = UIColor.white
        contentView?.layer.cornerRadius = 5;
        self.addSubview(contentView!)


        let btn:UIButton = UIButton(type: .custom)
        btn.frame = CGRect.init(x:0, y:0, width:46, height:46)
        btn.addTarget(self, action:#selector(close), for: .touchUpInside)
        btn.setTitle("╳", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        contentView!.addSubview(btn)

        let titleLabel:UILabel = UILabel(frame: CGRect.init(x:0, y:0, width: contentView!.frame.size.width, height:46))
        titleLabel.text = "请输入支付密码"
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.systemFont(ofSize:18)
        contentView!.addSubview(titleLabel)

        let linView:UIView = UIView (frame: CGRect.init(x:0, y:46, width: contentView!.frame.size.width,height:0.5))
        linView.backgroundColor = UIColor.lightGray
        contentView?.addSubview(linView)

        let lblPayType=UILabel.init(frame:CGRect.init(x:0, y:linView.frame.maxY+20, width:contentView!.frame.size.width, height:20))
        lblPayType.textAlignment = .center
        lblPayType.textColor=UIColor.color333()
        lblPayType.font=UIFont.systemFont(ofSize:17)
        contentView?.addSubview(lblPayType)

        let moneyLabel:UILabel = UILabel(frame:CGRect.init(x:0, y:lblPayType.frame.maxY+15, width:contentView!.frame.size.width, height:26))
        moneyLabel.text = "￥\(price!)"
        moneyLabel.textAlignment = NSTextAlignment.center
        moneyLabel.font = UIFont.systemFont(ofSize:30)
        contentView?.addSubview(moneyLabel)

        let lblDiscount=UILabel.buildLabel(textColor:UIColor.RGBFromHexColor(hexString:"aeaeae"), font:16, textAlignment: NSTextAlignment.center)
        lblDiscount.frame=CGRect.init(x:0, y:moneyLabel.frame.maxY+15, width: contentView!.frame.size.width, height:14)
        contentView?.addSubview(lblDiscount)

        if payType == 1{
            lblPayType.text="订单支付"
            lblDiscount.text="已优惠￥\(self.discount!)"
        }else{
            lblPayType.text="提现"
            lblDiscount.text="额外扣除￥\(self.discount!)手续费"
        }
        textField = UITextField(frame:CGRect.init(x:0, y:lblDiscount.frame.maxY+20, width:contentView!.frame.size.width, height:passWidth))
        textField.delegate = self
        textField.isHidden = true
        textField.keyboardType = UIKeyboardType.numberPad
        contentView?.addSubview(textField!)

        let inputView:UIView = UIView(frame:CGRect.init(x:self.inputViewX, y: lblDiscount.frame.maxY+20, width: inputViewWidth, height:passWidth))
        inputView.layer.borderWidth = 0.5;
        inputView.layer.borderColor = UIColor.lightGray.cgColor;
        contentView?.addSubview(inputView)

        let rect:CGRect = inputView.frame
        let x:CGFloat = rect.origin.x + (inputViewWidth/12)
        let y:CGFloat = rect.origin.y + passWidth / 2 - 5
        for i in 0..<6{
            let circleLabel:UILabel =  UILabel(frame:CGRect.init(x:x + passWidth * CGFloat(i)-5, y: y, width: 10, height: 10))
            circleLabel.backgroundColor = UIColor.black
            circleLabel.layer.cornerRadius = 5
            circleLabel.layer.masksToBounds = true
            circleLabel.isHidden = true
            contentView?.addSubview(circleLabel)
            pwdCircleArr.append(circleLabel)

            if i == 5 {
                continue
            }
            let line:UIView = UIView(frame:CGRect.init(x:rect.origin.x + (inputViewWidth / 6)*CGFloat(i + 1), y: rect.origin.y, width: 1, height: passWidth))
            line.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            line.alpha = 0.4
            contentView?.addSubview(line)
        }
    }

    private func show(view:UIView){
        view.addSubview(self)
        contentView!.transform = CGAffineTransform(scaleX: 1.21, y: 1.21)
        contentView!.alpha = 0;
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.textField.becomeFirstResponder()
            self.contentView!.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.contentView!.alpha = 1;

        }, completion: nil)

    }

    @objc private func close(){
        self.removeFromSuperview()
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text ?? "0").count > 6{
            return false
        }

        var password : String
        if string.count <= 0 {
            let index = textField.text!.index(textField.text!.endIndex,offsetBy:-1)
            password = String(textField.text!.prefix(upTo:index))
        }
        else {
            password = textField.text! + string
        }
        self.setCircleShow(count:password.count)
        DispatchQueue.main.asyncAfter(deadline:.now()+0.3) {//延时0.3
            if password.count == 6 {
                self.completeBlock?(password)
                self.close()
            }
        }
        return true;
    }

    private func setCircleShow(count:NSInteger){
        for circle in pwdCircleArr {
            circle.isHidden = true;
        }
        for i in 0..<count{
            pwdCircleArr[i].isHidden = false
        }
    }
}
