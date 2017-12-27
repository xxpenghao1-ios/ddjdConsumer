//
//  AccountDetailsViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/25.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation

/// 账户明细
class AccountDetailsViewController:BaseViewController{
    
    @IBOutlet weak var table: UITableView!
    
    private var arr=[TransferAccountSrecordEntity]()
    
    private var pageNumber=1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="账户明细"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        self.queryStoreTransferaccountsrecord(pageNumber:self.pageNumber, pageSize:10, queryStatu:0)
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.queryStoreTransferaccountsrecord(pageNumber:self.pageNumber, pageSize:10, queryStatu:0)
        })
        table.mj_footer.isHidden=true
    }
}

// MARK: - 页面设置
extension AccountDetailsViewController{
    
    /// 设置页面
    private func setUpView(){
        table.delegate=self
        table.dataSource=self
        table.emptyDataSetSource=self
        table.emptyDataSetSource=self
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        table.separatorInset=UIEdgeInsets.init(top:0, left:0, bottom:0,right:0)
        self.setEmptyDataSetInfo(text:"还没有相关数据")
        self.setLoadingState(isLoading:true)
    }
    /// 刷新table
    private func reloadTable(){
        self.setLoadingState(isLoading:false)
        self.table.mj_footer.endRefreshing()
        self.table.reloadData()
    }
}

// MARK: - table相关
extension AccountDetailsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=tableView.dequeueReusableCell(withIdentifier:"accountId") as? AccountDetailsTableViewCell
        if cell == nil{
            cell=getXibClass(name:"AccountDetailsTableViewCell", owner:self) as? AccountDetailsTableViewCell
        }
        if arr.count > 0{
            cell!.updateCell(entity:arr[indexPath.row])
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - 网络请求
extension AccountDetailsViewController{
    
    /// 查询店铺收入明细（转账明细）记录
    ///
    /// - Parameters:
    ///   - pageNumber:
    ///   - pageSize:
    ///   - queryStatu: 查询状态 ；传 0 代表微信和支付宝的转账记录都查询； 如果传 1 只查询微信转账记录； 传 2 查询支付宝转账记录
    private func queryStoreTransferaccountsrecord(pageNumber:Int,pageSize:Int,queryStatu:Int){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreInfoApi.queryStoreTransferaccountsrecord(storeId:STOREID, pageNumber: pageNumber, pageSize: pageSize, queryStatu:queryStatu), successClosure: { (json) in
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:TransferAccountSrecordEntity.init(), object:value.object)
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
