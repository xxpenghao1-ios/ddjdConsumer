//
//  AddressListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/13.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
//收货地址list
class AddressListViewController:BaseViewController{
    ///是否是选择收货地址
    var isSelectedAddressInfo:Int?
    //table
    @IBOutlet weak var table: UITableView!
    //添加收货地址
    @IBOutlet weak var btnAddAddress: UIButton!
    //保存收货地址
    private var arr=[ShippAddressEntity]()
    //保存当前选中的收货地址
    var addressInfoClosure:((_ entity:ShippAddressEntity) -> Void)?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLoadingState(isLoading:true)
        getAllShippaddress()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="管理收货地址"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
}
//设置页面
extension AddressListViewController{
    private func setUpView(){
        table.dataSource=self
        table.delegate=self
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        table.backgroundColor=UIColor.viewBackgroundColor()
        table.tableFooterView=UIView(frame: CGRect.zero)
        table.separatorStyle = .none
        btnAddAddress.addTarget(self, action:#selector(pushAddAddressVC), for: UIControlEvents.touchUpInside)
        self.setEmptyDataSetInfo(text:"收货地址为空")
        self.setDisplay(isDisplay:true)
        
    }
}
//网络请求
extension AddressListViewController{
    ///查询所有地址信息
    private func getAllShippaddress(){
        self.arr.removeAll()
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.getAllShippaddress(memberId:MEMBERID), successClosure: { (json) in
            for(_,value) in json{
                let entity=self.jsonMappingEntity(entity:ShippAddressEntity.init(), object: value.object)
                self.arr.append(entity!)
            }
            self.setLoadingState(isLoading:false)
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///删除地址
    private func delShippaddress(index:IndexPath){
        let entity=self.arr[index.row]
        entity.shippAddressId=entity.shippAddressId ?? 0
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.delShippaddress(memberId:MEMBERID, shippAddressId: entity.shippAddressId!), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                //获取对应cell
                let cell = self.table.cellForRow(at: index) as? AddressListTableViewCell
                if cell != nil{
                    self.arr.remove(at:index.row)
                    self.table!.deleteRows(at:[index], with: UITableViewRowAnimation.fade)
                    self.table.reloadData()
                }
            }else{
                self.showSVProgressHUD(status:"删除失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///设置默认地址
    private func setDefault(shippAddressId:Int){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.setDefault(memberId:MEMBERID, shippAddressId:shippAddressId), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.getAllShippaddress()
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
///table协议
extension AddressListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"AddressListTableViewCellId") as? AddressListTableViewCell
        if cell == nil{
            cell = Bundle.main.loadNibNamed("AddressListTableViewCell", owner:self, options: nil)?.last as? AddressListTableViewCell
        }
        if arr.count > 0{
            let entity=arr[indexPath.row]
            cell!.updateCell(entity:entity)
            //跳转到修改收货地址页面
            cell!.pushUpdateAddressVCClosure={
                self.pushUpdateAddressVC(entity:entity)
            }
            //设置默认地址
            cell!.setDefaultAddressClosure={
                self.setDefault(shippAddressId:entity.shippAddressId ?? 0)
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSelectedAddressInfo != nil{
            let entity=arr[indexPath.row]
            self.addressInfoClosure?(entity)
            self.navigationController?.popViewController(animated:true)
        }
    }
    //删除操作
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            self.delShippaddress(index:indexPath)
        }
    }
    //把delete 该成中文
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "删除"
    }
}
///跳转页面
extension AddressListViewController{
    //跳转到添加收货地址页面
    @objc func pushAddAddressVC(){
        let vc=self.storyboardPushView(type:.my, storyboardId:"UpdateAddAddressInfoVC") as! UpdateAddAddressInfoViewController
        vc.flag=1
        self.navigationController?.pushViewController(vc,animated:true)
    }
    //跳转到修改收货地址页面
    func pushUpdateAddressVC(entity: ShippAddressEntity) {
        let vc=self.storyboardPushView(type:.my, storyboardId:"UpdateAddAddressInfoVC") as! UpdateAddAddressInfoViewController
        vc.flag=2
        vc.entity=entity
        self.navigationController?.pushViewController(vc,animated:true)
    }
}
