//
//  StoreCodeInfoViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/20.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
import Kingfisher
///店铺二维码信息
class StoreCodeInfoViewController:BaseViewController {
    var storeEntity:StoreEntity?
    ///二维码图片
    @IBOutlet weak var codeImg: UIImageView!
    ///门店联系方式
    @IBOutlet weak var lblStoreTel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title=storeEntity?.storeName
        self.view.backgroundColor=UIColor.white
        storeEntity!.storeQRcode=storeEntity!.storeQRcode ?? ""
        codeImg.kf.setImage(with:URL.init(string:urlImg+storeEntity!.storeQRcode!), placeholder:UIImage.init(named:goodDefaultImg),options:[.transition(ImageTransition.fade(1))])
        lblStoreTel.text="门店电话:\(storeEntity?.tel ?? "")"
    }
}
