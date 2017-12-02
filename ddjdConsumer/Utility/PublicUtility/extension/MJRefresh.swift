//
//  MJRefresh.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/2.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import MJRefresh
///自定义刷新控件
class PHNormalHeader:MJRefreshNormalHeader{
    override func prepare() {
        super.prepare()
        // 隐藏时间
        self.lastUpdatedTimeLabel.isHidden=true
        // 隐藏状态
        self.stateLabel.isHidden = true;
    }
}
class PHNormalFooter:MJRefreshAutoStateFooter{
    override func prepare() {
        super.prepare()
        self.stateLabel.textColor=UIColor.color666()
    }
}
