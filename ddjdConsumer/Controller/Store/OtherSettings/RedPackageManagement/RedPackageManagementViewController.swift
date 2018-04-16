//
//  RedPackageManagementViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/26.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
/// 红包管理
class RedPackageManagementViewController:BaseViewController{

    ///剩余红包金额
    @IBOutlet weak var lblRemainingPrice: UILabel!
    ///剩余红包数量
    @IBOutlet weak var lblRemainingCount: UILabel!
    ///圆角view
    @IBOutlet weak var bacView: UIView!
    ///table
    @IBOutlet weak var table: UITableView!

    private var pageNumber=1

    private var arr=[ReceiveredPackeTrecordEntity]()

    private var flag=false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if flag{
            queryStoreRedPacket()
        }
        flag=true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="红包管理"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        queryStoreRedPacket()
        self.queryStoreRedpackReceivereRecord_storeId(pageNumber:self.pageNumber, pageSize:10)
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.queryStoreRedpackReceivereRecord_storeId(pageNumber:self.pageNumber, pageSize:10)
            self.queryStoreRedPacket()
        })
        table.mj_header=PHNormalHeader(refreshingBlock: {
            self.pageNumber=1
            self.arr.removeAll()
            self.queryStoreRedpackReceivereRecord_storeId(pageNumber:self.pageNumber, pageSize:10)
        })
        table.mj_footer.isHidden=true

    }
}

// MARK: - 页面设置
extension RedPackageManagementViewController{

    /// 设置页面
    private func setUpView(){
        bacView.layer.cornerRadius=5
        table.dataSource=self
        table.delegate=self
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        self.setLoadingState(isLoading:true)
        self.setEmptyDataSetInfo(text:"还没有红包领取记录")
        setUpNav()
    }
    private func reloadTable(){
        self.setLoadingState(isLoading:false)
        self.table.reloadData()
        self.table.mj_footer.endRefreshing()
        self.table.mj_header.endRefreshing()
    }
    /// 设置导航栏
    private func setUpNav(){
        self.navigationItem.rightBarButtonItem=UIBarButtonItem.init(title:"充值", style: UIBarButtonItemStyle.done, target:self, action:#selector(self.pushRedPackageRechargeVC))
    }
    /// 跳转到红包充值页面
    @objc private func pushRedPackageRechargeVC(){
        let vc=RedPackageRechargeViewController()
        self.navigationController?.pushViewController(vc, animated:true)
    }
}


// MARK: - 网络请求
extension RedPackageManagementViewController{

    private func queryStoreRedpackReceivereRecord_storeId(pageNumber:Int,pageSize:Int){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:RedPackageApi.queryStoreRedpackReceivereRecord_storeId(storeId:STOREID, pageNumber: pageNumber, pageSize: pageSize), successClosure: { (json) in
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:ReceiveredPackeTrecordEntity(), object:value.object)
                self.arr.append(entity!)
            }
            if self.arr.count < json["totalRow"].intValue{
                self.table.mj_footer.isHidden=false
            }else{
                self.table.mj_footer.isHidden=true
            }
            self.reloadTable()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.reloadTable()
        }
    }
    ///查询店铺红包信息
    private func queryStoreRedPacket(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:RedPackageApi.queryStoreRedPacket(storeId:STOREID), successClosure: { (json) in
            print(json)
            let entity=self.jsonMappingEntity(entity:StoreRedPackInfoEntity(), object:json.object)
            if entity != nil{
                self.lblRemainingCount.text="红包还剩\(entity!.storeRedPackSurplusCount ?? 0)个"
            self.lblRemainingPrice.text=entity?.storeRedPackMoney?.description
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}

// MARK: - table协议
extension RedPackageManagementViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"RedPackageReceiveRecordId") as? RedPackageReceiveRecordTableViewCell
        if cell == nil{
            cell=getXibClass(name:"RedPackageReceiveRecordTableViewCell", owner:self) as? RedPackageReceiveRecordTableViewCell
        }
        if arr.count > 0{
            cell!.updateCell(entity: arr[indexPath.row])
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
}
