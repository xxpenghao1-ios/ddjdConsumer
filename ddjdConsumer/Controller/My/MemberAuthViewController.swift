//
//  MemberAuthViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/26.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///消费者授权管理
class MemberAuthViewController:BaseViewController{

    private var table:UITableView!

    private var arr=[AuthEntity]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reinstateNavColor()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setUpNavColor()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="门店授权"
        self.view.backgroundColor=UIColor.viewBackgroundColor()

        table=UITableView.init(frame:self.view.bounds, style: UITableViewStyle.plain)
        table.dataSource=self
        table.delegate=self
        table.backgroundColor=UIColor.clear
        table.tableFooterView=UIView.init(frame:CGRect.zero)
        self.view.addSubview(table)
        httpQueryMemberAuthList()
    }
}


// MARK: - 网络请求
extension MemberAuthViewController{

    /// 查询为某会员授权的所有功能
    private func httpQueryMemberAuthList(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreAuthorizationMemberRelatedApi.queryMemberAuthList(memberId:MEMBERID), successClosure: { (json) in
            for(_,value) in json{
                let entity=self.jsonMappingEntity(entity:AuthEntity(), object: value.object)
                self.arr.append(entity!)
            }
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}

// MARK: - table协议
extension MemberAuthViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"id")
        if cell == nil{
            cell=UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier:"id")
        }
        cell!.textLabel!.font=UIFont.systemFont(ofSize:15)
        cell!.accessoryType = .disclosureIndicator
        let entity=arr[indexPath.row]
        var name=""
        switch entity.authNo ?? 0 {
        case 101:
            name="门店订单"
            break
        case 102:
            name="商品管理"
            break
        case 103:
            name="促销商品"
            break
        case 104:
            name="门店推荐"
            break
        default:break
        }
        cell!.textLabel!.text=name
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at:indexPath, animated:true)
        let entity=arr[indexPath.row]
        switch entity.authNo ?? 0 {
        case 101:
            let vc=PageStoreOrderListViewController()
            self.navigationController?.pushViewController(vc, animated:true)
            break
        case 102:
            let vc=PageStoreGoodListViewController()
            self.navigationController?.pushViewController(vc, animated:true)
            break
        case 103:
            let vc=self.storyboardPushView(type:.storeGood, storyboardId:"StorePromotionGoodListVC") as! StorePromotionGoodListViewController
            self.navigationController?.pushViewController(vc, animated:true)
            break
        case 104:
            let vc=self.storyboardPushView(type:.storeGood, storyboardId:"HotGoodListVC") as! HotGoodListViewController
            self.navigationController?.pushViewController(vc, animated:true)
            break
        default:break
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }

}

