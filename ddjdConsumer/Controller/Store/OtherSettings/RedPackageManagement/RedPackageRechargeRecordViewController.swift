//
//  RedPackageRechargeRecordViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/27.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation

/// 红包充值记录
class RedPackageRechargeRecordViewController:BaseViewController{

    private var table:UITableView!

    private var arr=[StoreRedPackreChargeRecordEntity]()

    private var pageNumber=1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="红包充值记录"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        self.queryStoreRedpackrechargerecord(pageNumber:self.pageNumber, pageSize: 10)
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.queryStoreRedpackrechargerecord(pageNumber:self.pageNumber, pageSize: 10)
        })
        table.mj_footer.isHidden=true
    }
}

// MARK: - 网络请求
extension RedPackageRechargeRecordViewController{

    private func queryStoreRedpackrechargerecord(pageNumber:Int,pageSize:Int){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:RedPackageApi.queryStoreRedpackrechargerecord(storeId:STOREID, pageNumber: pageNumber, pageSize: pageSize), successClosure: { (json) in
//            print(json)
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:StoreRedPackreChargeRecordEntity(), object:value.object)
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
}
// MARK: - 设置页面
extension RedPackageRechargeRecordViewController{
    private func setUpView(){
        table=UITableView.init(frame:self.view.bounds, style: UITableViewStyle.plain)
        table.delegate=self
        table.dataSource=self
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        self.view.addSubview(table)
        self.setLoadingState(isLoading:true)
        self.setEmptyDataSetInfo(text:"还没有红包充值记录")
    }
    private func reloadTable(){
        self.setLoadingState(isLoading:false)
        self.table.reloadData()
        self.table.mj_footer.endRefreshing()
    }
}

// MARK: - table协议
extension RedPackageRechargeRecordViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"RedPackageRechargeRecordTableViewCellId") as? RedPackageRechargeRecordTableViewCell
        if cell == nil{
            cell=getXibClass(name:"RedPackageRechargeRecordTableViewCell", owner:self) as? RedPackageRechargeRecordTableViewCell
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
