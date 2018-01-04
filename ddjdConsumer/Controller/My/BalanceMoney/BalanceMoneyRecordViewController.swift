//
//  BalanceMoneyRecordViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/4.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///余额明细
class BalanceMoneyRecordViewController:BaseViewController{
    
    @IBOutlet weak var table: UITableView!
    ///余额
    @IBOutlet weak var lblBlanceMoney: UILabel!

    private var arr=[BalanceRecordEntity]()

    private var pageNumber=1

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavColor()
        queryMemberBalanceMoney()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.reinstateNavColor()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="余额明细"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        self.queryMemberBalanceRecord(pageNumber:self.pageNumber, pageSize:10)
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.queryMemberBalanceRecord(pageNumber:self.pageNumber, pageSize:10)
        })
        table.mj_footer.isHidden=true
    }
    //跳转到充值页面
    @IBAction func pushTopUp(_ sender: UIButton) {
        let vc=self.storyboardPushView(type:.my, storyboardId:"BalanceMoneyTopUpVC") as! BalanceMoneyTopUpViewController
        self.navigationController?.pushViewController(vc, animated:true)
    }
    //跳转到提现页面
    @IBAction func pushWithdrawal(_ sender: UIButton) {
    }


}
///页面设置
extension BalanceMoneyRecordViewController{

    private func setUpView(){
        table.dataSource=self
        table.delegate=self
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        self.setEmptyDataSetInfo(text:"您暂时还没有任何余额明细哦")
        self.setLoadingState(isLoading:true)
    }
}

// MARK: - table协议
extension BalanceMoneyRecordViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"bmId") as? BalanceMoneyRecordTableViewCell
        if cell == nil{
            cell=getXibClass(name:"BalanceMoneyRecordTableViewCell", owner:self) as? BalanceMoneyRecordTableViewCell
        }
        if arr.count > 0{
            cell!.updateCell(entity:arr[indexPath.row])
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
}
// MARK: - 网络请求
extension BalanceMoneyRecordViewController{
    ///获取余额记录
    private func queryMemberBalanceRecord(pageNumber:Int,pageSize:Int){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryMemberBalanceRecord(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description, dicAny:["pageNumber":pageNumber,"pageSize":pageSize])), successClosure: { (json) in
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:BalanceRecordEntity.init(), object:value.object)
                self.arr.append(entity!)
            }
            if self.arr.count < json["totalRow"].intValue{
                self.table.mj_footer.isHidden=false
            }else{
                self.table.mj_footer.isHidden=true
            }
            self.setLoadingState(isLoading:false)
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.setLoadingState(isLoading:false)
            self.table.reloadData()
        }
    }
    ///获取用户余额
    private func queryMemberBalanceMoney(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryMemberBalanceMoney(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description)), successClosure: { (json) in
            print(json)
            let success=json["success"].stringValue
            if success == "success"{
                self.lblBlanceMoney.text=json["memberBalanceMoney"].doubleValue.description
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
