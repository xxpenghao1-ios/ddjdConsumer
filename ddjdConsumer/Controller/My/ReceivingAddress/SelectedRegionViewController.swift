//
//  SelectedRegionViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/22.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///区域选择
class SelectedRegionViewController:BaseViewController{
    ///接收地图信息
    var poiEntity:PoiEntity?
    var poiAddressInfoClosure:((_ entity:PoiEntity) ->Void)?
    //拖动地图位置
    private var locImageView:UIImageView!
    //搜索框
    private var txtSearch:UITextField!
    //地址信息结果
    private var addressTable:UITableView!
    //区域地址信息
    private var addressArr=[PoiEntity]()
    //百度地图
    fileprivate var bmkMapView:BMKMapView?
    //定位信息
    fileprivate var locService: BMKLocationService?
    //搜索结果
    fileprivate var geoCode:BMKGeoCodeSearch?;
    //用经纬度反编译成地址信息
    fileprivate var option:BMKReverseGeoCodeOption!;
    //判断页面是否是push到下一页 还是返回上一页  true push到下一页
    private var isPush=false
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated);
        bmkMapView?.viewWillAppear()
        isPush=false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bmkMapView?.viewWillDisappear()
        if isPush == false{//如果是返回上一页 清除百度地图协议
            bmkMapView?.delegate=nil
            locService?.delegate = nil
            geoCode?.delegate=nil;
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.white
        setUpNav()
        setUpView()
    }
}
///设置页面
extension SelectedRegionViewController{
    private func setUpNav(){
        //直接创建一个文本框
        txtSearch=UITextField(frame:CGRect(x:0,y:0, width:boundsWidth-80, height:30))
        txtSearch.backgroundColor=UIColor.RGBFromHexColor(hexString:"f0f2f5")
        txtSearch.placeholder="查找小区/大厦/学校等"
        txtSearch.font=UIFont.systemFont(ofSize: 14)
        txtSearch.tintColor=UIColor.clear
        txtSearch.delegate=self
        txtSearch.returnKeyType = .search
        txtSearch.clearButtonMode = .whileEditing
        txtSearch.resignFirstResponder()
        txtSearch.layer.cornerRadius=15
        //左边搜索图片
        let leftView=UIView(frame:CGRect(x:0,y:0, width:30, height:30))
        let leftImageView=UIImageView(frame:CGRect(x:10,y:8.5,width:13.5,height:13))
        leftImageView.image=UIImage(named:"search")
        leftView.addSubview(leftImageView)
        txtSearch.leftView=leftView
        txtSearch.leftViewMode=UITextFieldViewMode.always
        self.navigationItem.titleView=txtSearch
        
    }
    private func setUpView(){
        //地图
        setUpMapView()
        //geo搜索服务
        geoCode=BMKGeoCodeSearch();
        geoCode!.delegate=self
        //反geo检索信息类
        option=BMKReverseGeoCodeOption();
        //locImageView定位在当前位置，换算为屏幕的坐标，创建的定位的图标
        self.locImageView=UIImageView(frame: CGRect.init(x:0, y:0, width:40, height: 40))
        self.locImageView.center=CGPoint.init(x:boundsWidth/2,y:150-20)
        self.locImageView.image=UIImage.init(named:"region")
        self.bmkMapView!.addSubview(self.locImageView)
        //设置地址信息显示集合
        addressTable=UITableView(frame: CGRect.init(x:0,y:bmkMapView!.frame.maxY, width:boundsWidth,height:boundsHeight-bmkMapView!.frame.maxY-navHeight-bottomSafetyDistanceHeight), style: UITableViewStyle.plain)
        addressTable.delegate=self
        addressTable.dataSource=self
        addressTable.tableFooterView=UIView(frame: CGRect.zero)
        self.view.addSubview(addressTable)
        
        //初始化BMKLocationService
        locService = BMKLocationService()
        locService!.distanceFilter=10.0
        locService!.delegate=self
        if poiEntity == nil{//新增地址第一次加载进来  会为空 开始定位
            //启动LocationService
            startLocationService()
        }else{//已经选择过位置了  进来直接显示当前位置
            let pt=CLLocationCoordinate2D.init(latitude:poiEntity!.lat ?? 0, longitude:poiEntity!.lon ?? 0)
            //添加标题
            let annotation=BMKPointAnnotation()
            annotation.coordinate=pt
            bmkMapView!.addAnnotation(annotation)
            option.reverseGeoPoint = pt
            geoCode!.reverseGeoCode(option)
            bmkMapView!.setCenter(pt,animated:true)
        }
    }
    func setUpMapView(){
        bmkMapView=BMKMapView(frame:CGRect.init(x:0, y:0, width:boundsWidth, height:300));
        bmkMapView!.userTrackingMode=BMKUserTrackingModeFollow
        bmkMapView!.delegate=self
        //设置显示尺寸
        bmkMapView!.zoomLevel=19;
        self.view.addSubview(bmkMapView!);
    }
    //启动LocationService
    func startLocationService(){
        locService!.startUserLocationService()
    }
    ///设置位置图标动画
    private func setLocImageAnimate(){
        UIView.animate(withDuration:0.3, delay:0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.locImageView.center=CGPoint.init(x:boundsWidth/2, y:150-35)
        }) { (finished) in
            UIView.animate(withDuration:0.3, delay:0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.locImageView.center=CGPoint.init(x:boundsWidth/2, y:150-20)
            }, completion: nil)
        }
    }
}
extension SelectedRegionViewController:UITextFieldDelegate{
    //实现导航控制器文本框的协议 跳转到搜索页面
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //点击文本框不让键盘弹出来
        textField.resignFirstResponder()
        let vc=self.storyboardPushView(type:.my, storyboardId:"PoiSearchAddressVC") as! PoiSearchAddressViewController
        if addressArr.count > 0{
            vc.city=addressArr[0].city
        }
        ///接收到地址信息立马传回上一页面
        vc.poiAddressInfoClosure={ (entity) in
            if entity.lat != nil && entity.lon != nil{
                self.poiAddressInfoClosure?(entity)
                self.navigationController?.popViewController(animated:true)
            }
        }
        self.navigationController?.pushViewController(vc, animated:true)
        isPush=true
    }
}
///table协议
extension SelectedRegionViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=addressTable.dequeueReusableCell(withIdentifier:"poiTableViewCellId") as? poiTableViewCell
        if cell == nil{
            cell=getXibClass(name:"poiTableViewCell", owner:self) as? poiTableViewCell
        }
        if addressArr.count > 0{
            let entity=addressArr[indexPath.row]
            if indexPath.row == 0{
                cell!.lblName.textColor=UIColor.red
                cell!.lblName.text="[当前]"+entity.name!
            }else{
                cell!.lblName.textColor=UIColor.black
                cell!.lblName.text=entity.name
            }
            cell!.updateCell(entity:entity, distance: nil)
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
///百度地图
extension SelectedRegionViewController:BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate{
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        // 从缓存池取出大头针数据视图
        var customView=mapView.dequeueReusableAnnotationView(withIdentifier:"pinId")
        // 如果取出的为nil , 那么就手动创建大头针视图
        if customView == nil{
            customView=BMKAnnotationView.init(annotation:annotation, reuseIdentifier:"pinId")
        }
        if  annotation.isKind(of: BMKPointAnnotation.self){
            // 1. 设置大头针图片
            customView!.image = UIImage.init(named:"point")
        }
        return customView!
    }
    //处理位置坐标更新
    func didUpdate(_ userLocation: BMKUserLocation!) {
        if userLocation.location != nil{//判断地址信息是否获取到  获取
            self.setLocImageAnimate()
            let pt=CLLocationCoordinate2D.init(latitude:userLocation.location.coordinate.latitude, longitude: userLocation.location.coordinate.longitude)
            option.reverseGeoPoint=pt
            geoCode!.reverseGeoCode(option)
            bmkMapView!.updateLocationData(userLocation)
            locService!.stopUserLocationService()//取消定位  这个一定要写，不然无法移动定位了
            bmkMapView!.centerCoordinate = userLocation.location.coordinate
            //添加标题
            let annotation=BMKPointAnnotation()
            annotation.coordinate=pt
            bmkMapView!.addAnnotation(annotation)
        }
    }
    ///返回检索位置
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error.rawValue == BMK_SEARCH_NO_ERROR.rawValue{//检索结果正常返回
            addressArr.removeAll()
            for i in 0..<result.poiList.count{
                let poi=result.poiList[i] as! BMKPoiInfo
                let poiEntity=PoiEntity()
                poiEntity.name=poi.name
                poiEntity.city=poi.city
                poiEntity.address=poi.address
                poiEntity.lat=poi.pt.latitude
                poiEntity.lon=poi.pt.longitude
                if self.poiEntity?.name == poiEntity.name{//如果搜索结果中有等于传入地址信息 保存起来 循环结束把这个地址信息插入第一行
                    self.poiEntity=poiEntity
                    continue
                }
                addressArr.append(poiEntity)
            }
            if self.poiEntity != nil{//把当前插入第一行
                addressArr.insert(self.poiEntity!, at:0)
            }
            addressTable.reloadData()
            if addressArr.count > 0{
                self.addressTable.scrollToRow(at: IndexPath.init(row:0, section:0), at: UITableViewScrollPosition.none, animated:true)
            }
        }
    }
    func mapView(_ mapView: BMKMapView!, onClickedMapPoi mapPoi: BMKMapPoi!) {
        print("点击底部")
    }
    func mapview(_ mapView: BMKMapView!, onDoubleClick coordinate: CLLocationCoordinate2D) {
        print("点击了地图")
    }
    //地图区域改变完成后会调用此接口
    func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        setLocImageAnimate()
        ///清空保存地址信息 不然每次移动地图都会把这个地址信息显示到第一位
        self.poiEntity=nil
        let pt=CLLocationCoordinate2D.init(latitude:mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        option.reverseGeoPoint = pt
        geoCode!.reverseGeoCode(option)
    }
    //定位失败会调用此方法
    func didFailToLocateUserWithError(_ error:Error!){
        self.showSVProgressHUD(status:error.localizedDescription, type: HUD.error)
    }
}
