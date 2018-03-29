//
//  ImageDownloader.swift
//  T2
//
//  Created by hangge on 15/9/28.
//  Copyright © 2015年 hangge. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
//图片下载操作任务
class ImageDownloader: Operation {
    //商品
    let entity: GoodEntity
    init(entity: GoodEntity) {
        self.entity = entity
    }

    //在子类中重载Operation的main方法来执行实际的任务。
    override func main() {
        //在开始执行前检查撤消状态。任务在试图执行繁重的工作前应该检查它是否已经被撤消。
        if self.isCancelled {
            return
        }

        entity.goodsPic=entity.goodsPic ?? ""
        //检索图片是否已经在磁盘缓存中
        let img=cache.retrieveImageInDiskCache(forKey:urlImg+entity.goodsPic!)
        if img == nil{//不在

            //下载图片。
            let imageData = try? Data(contentsOf:URL.init(string:urlImg+self.entity.goodsPic!)!)
            //再一次检查撤销状态。
            if self.isCancelled {
                return
            }
            if imageData != nil {
                self.entity.image = UIImage(data:imageData!)
                if self.entity.image != nil{
                    ///存入缓存
                    cache.store(self.entity.image!, forKey:urlImg+self.entity.goodsPic!)
                    self.entity.state = .downloaded
                }
            }
        }else{//如果在缓存中 直接读取
            //再一次检查撤销状态。
            if self.isCancelled {
                return
            }
            self.entity.image = img
            self.entity.state = .downloaded
        }
    }
}
