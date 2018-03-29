//
//  MapNav.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/3/17.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
///地图导航类型
public enum MapNavType{
    case baidu  //百度
    case gaode  //高德
    case iPhone //苹果
}
///地图导航
class MapNav:NSObject{
    static let shared=MapNav()
    private override init() { }
    ///调用地图
    func openMapNav(coordinate:CLLocationCoordinate2D,name:String,mapType:MapNavType) -> Bool{
        switch mapType {
        case .baidu:
            return self.openBaiduMapNav(coordinate: coordinate, name:name)
        case .gaode:
            return self.openGaodeMapNav(coordinate:coordinate, name:name)
        case .iPhone:
            return self.openiPhoneMapNav(coordinate:coordinate, name:name)
        }
    }
    //调用高德地图 APP导航
    private func openGaodeMapNav(coordinate:CLLocationCoordinate2D,name:String) -> Bool{
        let gaoDeCoordinate=self.GCJ02FromBD09(coor:coordinate)
        if UIApplication.shared.canOpenURL(URL.init(string:"iosamap://")!) == true{
            let urlString="iosamap://navi?sourceApplication=点单相邻&backScheme=iosamap://&lat=\(gaoDeCoordinate.latitude)&lon=\(gaoDeCoordinate.longitude)&dev=0&style=2".addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed) ?? ""
            let url=URL.init(string:urlString)
            UIApplication.shared.openURL(url!)
            return true
        }
        return false
    }
    // 调启百度地图 APP 导航
    private func openBaiduMapNav(coordinate:CLLocationCoordinate2D,name:String) -> Bool {
//        // 初始化调启导航的参数管理类
//        let parameter = BMKNaviPara()
//        // 指定导航类型
////        parameter.naviType = BMK_NAVI_TYPE_NATIVE
//        // 初始化终点节点
//        let end = BMKPlanNode()
//        // 指定终点经纬度
//        end.pt = coordinate
//        // 指定终点名称
//        end.name = name
//        // 指定终点
//        parameter.endPoint = end
//        //指定返回自定义 scheme
//        parameter.appScheme = "baidumapddjdconsumer://c.ddjd.com"
//        // 调启百度地图客户端导航
//        BMKNavigation.openBaiduMapwalkARNavigation(parameter)
        if UIApplication.shared.canOpenURL(URL.init(string:"baidumap://")!) == true{
            let urlString="baidumap://map/direction?origin={{我的位置}}&destination=latlng:\(coordinate.latitude),\(coordinate.longitude)|name=\(name)&mode=driving&coord_type=gcj02".addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed) ?? ""
            let url=URL.init(string:urlString)
            UIApplication.shared.openURL(url!)
            return true
        }
        return false
    }
    ///调用苹果地图导航
    private func openiPhoneMapNav(coordinate:CLLocationCoordinate2D,name:String) -> Bool{
        let gaoDeCoordinate=self.GCJ02FromBD09(coor:coordinate)
        let currentLocation=MKMapItem.forCurrentLocation()
        let toLocation=MKMapItem.init(placemark: MKPlacemark.init(coordinate: gaoDeCoordinate, addressDictionary:nil))
        ///指定位置名称
        toLocation.name=name
        if MKMapItem.openMaps(with:[currentLocation,toLocation], launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey:true]){
            return true
        }
        return false
    }
    /// 百度坐标转高德坐标
    private func GCJ02FromBD09(coor:CLLocationCoordinate2D) -> CLLocationCoordinate2D{
        let x_pi:CLLocationDegrees=3.14159265358979324 * 3000.0 / 180.0;
        let x=coor.longitude - 0.0065
        let y=coor.latitude - 0.006
        let z=sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
        let theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
        let gg_lon = z * cos(theta);
        let gg_lat = z * sin(theta);
        return CLLocationCoordinate2D.init(latitude: gg_lat,longitude:gg_lon)
    }
    // 高德坐标转百度坐标
    private func BD09FromGCJ02(coor:CLLocationCoordinate2D) -> CLLocationCoordinate2D{
        let x_pi:CLLocationDegrees = 3.14159265358979324 * 3000.0 / 180.0;
        let x = coor.longitude, y = coor.latitude;
        let z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
        let theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
        let bd_lon = z * cos(theta) + 0.0065;
        let bd_lat = z * sin(theta) + 0.006;
        return CLLocationCoordinate2D.init(latitude: bd_lat, longitude: bd_lon)
    }
}
