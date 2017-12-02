//
//  PoiSearchAddressViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/1.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///周边检索、区域检索和城市内检索
class PoiSearchAddressViewController:BaseViewController{
    ///接收城市
    var city:String?
    var poiAddressInfoClosure:((_ entity:PoiEntity) ->Void)?
    @IBOutlet weak var table: UITableView!
    ///地图搜索服务
    private var poiSearch:BMKPoiSearch!
    private var locService:BMKLocationService!
    private var txtSearch:UITextField!
    private var addressArr=[PoiEntity]()
    //保存经纬度
    private var pt:CLLocationCoordinate2D?
    override func viewDidLoad() {
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpNav()
        //初始化BMKLocationService
        locService = BMKLocationService()
        locService!.distanceFilter=10.0
        locService!.delegate=self
        locService!.startUserLocationService()
        poiSearch=BMKPoiSearch()
        poiSearch.delegate=self
        table.tableFooterView=UIView.init(frame:CGRect.zero)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        poiSearch.delegate=nil
        locService.delegate=nil
    }
}
///设置页面
extension PoiSearchAddressViewController{
    private func setUpNav(){
        //直接创建一个文本框
        txtSearch=UITextField(frame:CGRect(x:0,y:0, width:boundsWidth-80, height:30))
        txtSearch.backgroundColor=UIColor.RGBFromHexColor(hexString:"f0f2f5")
        txtSearch.placeholder="查找小区/大厦/学校等"
        txtSearch.font=UIFont.systemFont(ofSize: 14)
        txtSearch.addTarget(self,action:#selector(textFieldTextChange), for: UIControlEvents.editingChanged)
        txtSearch.delegate=self
        txtSearch.returnKeyType = .search
        txtSearch.clearButtonMode = .whileEditing
        txtSearch.layer.cornerRadius=15
        //左边搜索图片
        let leftView=UIView(frame:CGRect(x:0,y:0, width:30, height:30))
        let leftImageView=UIImageView(frame:CGRect(x:10,y:8.5,width:13.5,height:13))
        leftImageView.image=UIImage(named:"search")
        leftView.addSubview(leftImageView)
        txtSearch.leftView=leftView
        txtSearch.leftViewMode=UITextFieldViewMode.always
        self.navigationItem.titleView=txtSearch
        
        ///提示视图
        self.setEmptyDataSetInfo(text:"没找到? 在地图上拖动试试")
        self.setDisplay(isDisplay:false)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
extension PoiSearchAddressViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"poiTableViewCellId") as? poiTableViewCell
        if cell == nil{
            cell=getXibClass(name:"poiTableViewCell", owner:self) as? poiTableViewCell
        }
        if addressArr.count > 0{
            let entity=addressArr[indexPath.row]
            if self.pt != nil {
                let distance=BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(self.pt!), BMKMapPointForCoordinate(CLLocationCoordinate2D.init(latitude:entity.lat ?? 0, longitude: entity.lon ?? 0)))
                var distanceStr:String?
                if distance >= 1000{
                    distanceStr=String(format:"%.1f",distance/1000)+"千米"
                }else{
                    distanceStr=String(format:"%.0f",distance)+"米"
                }
                cell!.updateCell(entity:entity,distance:distanceStr)
            }else{
                cell!.updateCell(entity:entity, distance: nil)
            }
            let searchStr=txtSearch.text ?? ""
            let str=NSString(string:entity.name ?? "")
            let range=str.range(of:searchStr)
            cell!.lblName.attributedText=UILabel.setAttributedText(str:entity.name ?? "", textColor:UIColor.applicationMainColor(),font:14,range:range)
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity=addressArr[indexPath.row]
        if entity.lat != nil && entity.lon != nil{
            self.poiAddressInfoClosure?(entity)
            self.navigationController?.popViewController(animated:true)
        }
    }
}
extension PoiSearchAddressViewController:UITextFieldDelegate{
    //点击键盘搜索按钮
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != nil{
            getAddressInfo(keyword:textField.text!)
        }
        return true
    }
    @objc private func textFieldTextChange(textField:UITextField){
        if textField.text != nil{
            getAddressInfo(keyword:textField.text!)
        }
    }
    
    ///获取地址信息
    private func getAddressInfo(keyword:String){
        let citySearchOption=BMKCitySearchOption()
        citySearchOption.pageIndex=0
        citySearchOption.pageCapacity=50
        citySearchOption.city=city ?? ""
        citySearchOption.keyword=keyword
        let flag=poiSearch.poiSearch(inCity:citySearchOption)
        if flag{//城市内检索发送成功
            self.addressArr.removeAll()
        }else{//城市内检索发送失败
            self.addressArr.removeAll()
            reloadData()
        }
    }
    private func reloadData(){
        self.setDisplay(isDisplay:true)
        self.table.reloadData()
    }
}
///百度地图
extension PoiSearchAddressViewController:BMKPoiSearchDelegate,BMKLocationServiceDelegate{
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPoiResult!, errorCode: BMKSearchErrorCode) {
        if errorCode.rawValue == BMK_SEARCH_NO_ERROR.rawValue{//正常结果
            if poiResult.poiInfoList != nil{
                for i in 0..<poiResult.poiInfoList.count{
                    let poi=poiResult.poiInfoList[i] as! BMKPoiInfo
                    let poiEntity=PoiEntity()
                    poiEntity.name=poi.name
                    poiEntity.city=poi.city
                    poiEntity.address=poi.address
                    poiEntity.lat=poi.pt.latitude
                    poiEntity.lon=poi.pt.longitude
                    self.addressArr.append(poiEntity)
                }
            }
        }else if errorCode.rawValue == BMK_SEARCH_AMBIGUOUS_KEYWORD.rawValue{////当在设置城
            
        }else{//没有找到结果
            
        }
        reloadData()
    }
    func didUpdate(_ userLocation: BMKUserLocation!) {
        pt=CLLocationCoordinate2D.init(latitude:userLocation.location.coordinate.latitude, longitude: userLocation.location.coordinate.longitude)
    }
}

