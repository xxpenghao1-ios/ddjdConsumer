//
//  ScanCodeGetBarcodeViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/8.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///扫码获取条形码
class ScanCodeGetBarcodeViewController:LBXScanViewController,LBXScanViewControllerDelegate{
    var codeInfoClosure:((_ code:String?) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="获取条形码"
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
//                code(scanResult.strScanned!)
            }else{
                self.codeInfoClosure?(scanResult.strScanned)
                self.navigationController?.popViewController(animated:true)
            }
        }
    }
}
