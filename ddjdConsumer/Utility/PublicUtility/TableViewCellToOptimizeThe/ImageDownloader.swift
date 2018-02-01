//
//  ImageDownloader.swift
//  T2
//
//  Created by hangge on 15/9/28.
//  Copyright © 2015年 hangge. All rights reserved.
//

import UIKit
import Kingfisher
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
        //下载图片。
        let imageData = try? Data(contentsOf:URL.init(string:urlImg+entity.goodsPic!)!)

        //再一次检查撤销状态。
        if self.isCancelled {
            return
        }

        //如果有数据，创建一个图片对象并加入记录，然后更改状态。如果没有数据，将记录标记为失败并设置失败图片。
        if imageData != nil {
            self.entity.image = UIImage(data:imageData!)
            ///存入缓存
            cache.store(self.entity.image!, forKey:urlImg+entity.goodsPic!)
            self.entity.state = .downloaded
        }
        else
        {
            self.entity.state = .failed
            self.entity.image = UIImage(named:goodDefaultImg)
        }
    }
}
