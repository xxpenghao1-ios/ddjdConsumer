//
//  PartnerDetailViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/10.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///合伙人详情
class PartnerDetailViewController:BaseViewController{
    var entity:PartnerEntity?
    private var table:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        entity=entity ?? PartnerEntity()
        self.title="合伙人-\(entity?.storeAndPartnerNickName ?? "")"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
}

// MARK: - 页面设置
extension PartnerDetailViewController{
    private func setUpView(){
        table=UITableView.init(frame:self.view.bounds, style: UITableViewStyle.grouped)
        table.dataSource=self
        table.delegate=self
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        self.view.addSubview(table)
    }
}

// MARK: - table
extension PartnerDetailViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"partnerDetailId")
        if cell == nil{
            cell=UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier:"partnerDetailId")
        }
        cell!.textLabel!.font=UIFont.systemFont(ofSize:15)
        cell!.detailTextLabel!.font=UIFont.systemFont(ofSize:14)
        switch indexPath.row {
        case 0:
            cell!.textLabel!.text="姓名"
            cell!.detailTextLabel!.text=entity?.storeAndPartnerNickName
            break
        case 1:
            cell!.textLabel!.text="联系方式"
            cell!.detailTextLabel!.text=entity?.storeAndPartnerMemberTel
            cell!.accessoryType = .disclosureIndicator
            break
        case 2:
            cell!.textLabel!.text="添加时间"
            cell!.detailTextLabel!.text=entity?.storeAndPartnerAddTime
            break
        case 3:
            cell!.textLabel!.text="出资金额"
            cell!.detailTextLabel!.text=entity?.storeAndPartneAmountOfPayment?.description
            break
        case 4:
            cell!.textLabel!.text="占利润的百分比"
            cell!.detailTextLabel!.text="\(entity!.storeAndPartnerBFB ?? 1)%"
            break
        case 5:
            cell!.textLabel!.text="每月返回余额"
            cell!.detailTextLabel!.text=entity?.storeAndPartneMonthMoney?.description
            break
        case 6:
            cell!.textLabel!.text="总共返回余额多少月"
            cell!.detailTextLabel!.text=entity?.storeAndPartneMonthCount?.description
            break
        case 7:
            cell!.textLabel!.text="还需要返回余额多少月"
            cell!.detailTextLabel!.text=entity?.storeAndPartneSurplusMonthCount?.description
            break
        default:break
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "合伙人详细信息"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at:indexPath, animated:true)
        if indexPath.row == 1{
            if entity!.storeAndPartnerMemberTel != nil{
                UIApplication.shared.openURL(Foundation.URL(string :"tel://\(entity!.storeAndPartnerMemberTel!)")!)
            }
        }
    }
}
