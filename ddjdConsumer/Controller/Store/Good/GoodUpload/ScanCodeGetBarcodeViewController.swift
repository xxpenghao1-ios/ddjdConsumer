//
//  ScanCodeGetBarcodeViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/8.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import AVFoundation
///扫码获取条形码 或2二维码
class ScanCodeGetBarcodeViewController:LBXScanViewController,LBXScanViewControllerDelegate{
    ///有值获取二维码 否则条形码
    var flag:Int?
    var codeInfoClosure:((_ code:String?) -> Void)?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavColor()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if flag == nil{
            self.title="获取条形码"
            self.arrayCodeType=[AVMetadataObject.ObjectType.ean13,AVMetadataObject.ObjectType.ean8,AVMetadataObject.ObjectType.code128,AVMetadataObject.ObjectType.code39,AVMetadataObject.ObjectType.code93]
        }else{
            self.title="获取二维码"
            self.arrayCodeType=[AVMetadataObject.ObjectType.qr]
        }
        //设置扫码区域参数
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44;
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.On;
        style.photoframeLineW = 6;
        style.photoframeAngleW = 24;
        style.photoframeAngleH = 24;
        style.isNeedShowRetangle = true;
        style.anmiationStyle = LBXScanViewAnimationStyle.NetGrid;
        //使用的支付宝里面网格图片
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_part_net");
        self.scanStyle=style
        self.isOpenInterestRect = true
        self.scanResultDelegate=self
    }
    ///扫码结果返回
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        if scanResult.strBarCodeType != nil{
            if scanResult.strBarCodeType! == "org.iso.QRCode"{//判断是否是二维码
                self.codeInfoClosure?(scanResult.strScanned)
            }else{
                self.codeInfoClosure?(scanResult.strScanned)
            }
        }
        self.navigationController?.popViewController(animated:true)
    }
    //设置导航栏颜色
    private func setUpNavColor(){
        self.navigationController?.navigationBar.barTintColor=UIColor.applicationMainColor()
        self.navigationController?.navigationBar.titleTextAttributes=NSDictionary(object:UIColor.white, forKey:NSAttributedStringKey.foregroundColor as NSCopying) as? [NSAttributedStringKey : Any]
        self.navigationController?.navigationBar.tintColor=UIColor.white
        self.navigationController?.navigationBar.shadowImage=UIImage.imageFromColor(UIColor.applicationMainColor())
    }
}
