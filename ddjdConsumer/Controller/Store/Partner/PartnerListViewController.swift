//
//  PartnerListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/10.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///合伙人管理
class PartnerListViewController:BaseViewController{
    ///table
    @IBOutlet weak var table: UITableView!
    private var  arr=[PartnerEntity]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryStoreBindPartner()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="合伙人管理"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        self.navigationItem.rightBarButtonItem=UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target:self, action:#selector(pushAddPartnerVC))
        setUpView()
    }
    /// 跳转到添加合伙人页面
    @objc private func pushAddPartnerVC(){
        let vc=self.storyboardPushView(type:.store, storyboardId:"AddPartnerVC") as! AddPartnerViewController
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
///页面设置
extension PartnerListViewController{
    private func setUpView(){
        table.delegate=self
        table.dataSource=self
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        self.setLoadingState(isLoading:true)
        self.setEmptyDataSetInfo(text:"还木有合伙人")
        self.table.tableFooterView=UIView.init(frame: CGRect.zero)
    }
}

// MARK: - table
extension PartnerListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"cellid")
        if cell == nil{
            cell=UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier:"cellid")
        }
        cell!.accessoryType = .disclosureIndicator
        cell!.textLabel!.font=UIFont.systemFont(ofSize:15)
        cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:14)
        if arr.count > 0{
            let entity=arr[indexPath.row]
            cell!.textLabel!.text="合伙人-\(entity.storeAndPartnerNickName ?? "")"
            cell!.detailTextLabel!.text=entity.storeAndPartnerMemberTel
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中效果颜色
        tableView.deselectRow(at: indexPath, animated: true)
        let vc=PartnerDetailViewController()
        vc.entity=arr[indexPath.row]
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
///网络请求
extension PartnerListViewController{
    ///查询合伙人
    private func queryStoreBindPartner(){
        self.arr.removeAll()
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreInfoApi.queryStoreBindPartner(storeId:STOREID), successClosure: { (json) in
            print(json)
            for(_,value) in json{
                let entity=self.jsonMappingEntity(entity:PartnerEntity(), object: value.object)
                self.arr.append(entity!)
            }
            self.setLoadingState(isLoading:false)
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.setLoadingState(isLoading:false)
            self.table.reloadData()
        }
    }
}
