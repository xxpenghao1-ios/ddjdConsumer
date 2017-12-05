//
//  BindStoreListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/4.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///绑定店铺的集合
class BindStoreListViewController:BaseViewController{
    var addressEntity:ShippAddressEntity?
    var pt:CLLocationCoordinate2D?
    @IBOutlet weak var table: UITableView!
    private var arr=[StoreEntity]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="附近店铺"
        self.view.backgroundColor=UIColor.white
        self.table.tableFooterView=UIView.init(frame: CGRect.zero)
        self.setLoadingState(isLoading:true)
        self.setEmptyDataSetInfo(text:"附近没有可配送店铺")
        queryStoreForLocation()
    }
}
extension BindStoreListViewController{
    private func queryStoreForLocation(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreInfoApi.queryStoreForLocation(distributionScope:0, lat:self.pt!.latitude, lon:self.pt!.longitude), successClosure: { (json) in
            print(json)
            for(_,value) in json{
                let entity=self.jsonMappingEntity(entity:StoreEntity.init(), object:value.object)
                self.arr.append(entity!)
            }
            self.setLoadingState(isLoading:false)
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    private func bindStore(bindstoreId:Int){
        self.showSVProgressHUD(status:"正在绑定...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.bindStore(memberId:MEMBERID,bindstoreId:bindstoreId), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.saveAddress()
                self.showSVProgressHUD(status:"绑定成功", type: HUD.success)
                userDefaults.set(bindstoreId,forKey:"bindstoreId")
                userDefaults.synchronize()
                app.jumpToIndexVC()
            }else{
                self.showSVProgressHUD(status:"绑定失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    //保存收货地址
    private func saveAddress(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target: MyApi.saveShippAddress(lat:addressEntity!.lat!, lon:addressEntity!.lon!, address:addressEntity!.address!, detailAddress:addressEntity!.detailAddress!,shippName:addressEntity!.shippName!, phoneNumber:addressEntity!.phoneNumber!, memberId: MEMBERID, shippAddressId:addressEntity!.shippAddressId, defaultFlag:addressEntity!.defaultFlag!), successClosure: { (json) in
        }) { (error) in
            
        }
    }
}
extension BindStoreListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"bindStoreId") as? BindStoreListTableViewCell
        if cell == nil{
            cell=getXibClass(name:"BindStoreListTableViewCell", owner:self) as? BindStoreListTableViewCell
        }
        if arr.count > 0{
            let entity=arr[indexPath.row]
            if self.pt != nil {
                if entity.lat != nil && entity.lon != nil{
                    let distance=BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(self.pt!), BMKMapPointForCoordinate(CLLocationCoordinate2D.init(latitude:Double(entity.lat!) ?? 0, longitude: Double(entity.lon!) ?? 0)))
                    var distanceStr:String?
                    if distance >= 1000{
                        distanceStr="距离"+String(format:"%.1f",distance/1000)+"千米"
                    }else{
                        distanceStr="距离"+String(format:"%.0f",distance)+"米"
                    }
                    cell!.lblDistance.text=distanceStr
                }
            }
            cell!.updateCell(entity:entity)
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中效果颜色
        tableView.deselectRow(at: indexPath, animated: true)
        let entity=arr[indexPath.row]
        UIAlertController.showAlertYesNo(self, title:"", message:"确认绑定[\(entity.storeName ?? "")]吗?", cancelButtonTitle:"取消", okButtonTitle:"确认") { (action) in
            self.bindStore(bindstoreId:entity.storeId ?? 0)
        }
    }
}
