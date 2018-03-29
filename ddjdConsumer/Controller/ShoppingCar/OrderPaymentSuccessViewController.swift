//
//  OrderPaymentSuccessViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/28.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///订单付款成功页面
class OrderPaymentSuccessViewController:BaseViewController {

    var orderSN:String?
    var price:String?
    var payType:String?
    var orderId:Int!
    ///店铺剩余红包
    var storeRedPackSurplusCount:Int!
    ///店铺名称
    var storeName=userDefaults.object(forKey:"storeName") as? String
    @IBOutlet weak var table: UITableView!
    ///查看订单
    @IBOutlet weak var btnPushOrder: UIButton!

    private var nameArr=["订单号码:","订单状态","订单总金额:","支付方式:"]

    private var valueArr:[String?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="付款详情"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        if storeRedPackSurplusCount > 0{//如果店铺有红包
            WSRedPacketView.showRedPacker(withData:storeName ?? "店铺", cancel: {

            }, open: { () -> String? in
                self.getOneRedPacket()
                return nil
            })
        }
    }
    override func navigationShouldPopOnBackButton() -> Bool {
        self.navigationController?.popViewController(animated:true)
        return true
    }

}


// MARK: - 设置页面
extension OrderPaymentSuccessViewController{

    private func setUpView(){
        valueArr=[orderSN,"待发货",price,payType]
        btnPushOrder.layer.cornerRadius=5
        btnPushOrder.layer.borderWidth=1
        btnPushOrder.backgroundColor=UIColor.clear
        btnPushOrder.setTitleColor(UIColor.applicationMainColor(), for: UIControlState.normal)
        btnPushOrder.layer.borderColor=UIColor.applicationMainColor().cgColor
        table.delegate=self
        table.dataSource=self
        table.isScrollEnabled=false
        btnPushOrder.addTarget(self, action:#selector(pushOrderList), for: UIControlEvents.touchUpInside)
    }
    ///跳转到待发货订单列表
    @objc private func pushOrderList(){
        let vc=OrderListPageController()
        vc.orderStatus=2
        vc.popFlag=1
        self.navigationController?.pushViewController(vc, animated:true)
    }
}


// MARK: - 网络请求
extension OrderPaymentSuccessViewController{

    ///开红包
    private func getOneRedPacket(){
        var result:String?=nil
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:RedPackageApi.getOneRedPacket(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description, dicAny:["orderId":self.orderId])), successClosure: { (json) in
            print(json)
            let success=json["success"].stringValue
            switch success{
            case "success":
                let oneMoney=json["oneMoney"].doubleValue.description
                result="恭喜你,获得\(oneMoney)元红包"
                break
            default:
                result="红包已经被抢完了"
                break
            }
            NotificationCenter.default.post(name: NSNotification.Name.init("stopOpen"), object:nil, userInfo: ["result":result!])
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            NotificationCenter.default.post(name: NSNotification.Name.init("stopOpen"), object:nil, userInfo:nil)
        }
    }
}

// MARK: - table
extension OrderPaymentSuccessViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"orderPaymentSuccessId")
        if cell == nil{
            cell=UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier:"orderPaymentSuccessId")
            cell!.textLabel!.font=UIFont.systemFont(ofSize:14)
            cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:14)

        }
        cell!.textLabel!.text=nameArr[indexPath.row]
        cell!.detailTextLabel!.text=valueArr[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}



