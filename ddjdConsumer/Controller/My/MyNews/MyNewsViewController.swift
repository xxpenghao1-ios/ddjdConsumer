//
//  MyNewsViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/18.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///消息中心
class MyNewsViewController:BaseViewController{
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="消息中心"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        table.tableFooterView=UIView(frame: CGRect.zero)
        table.estimatedRowHeight=10
        table.rowHeight=UITableViewAutomaticDimension
    }
}
extension MyNewsViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"NewsTableViewCellId") as? NewsTableViewCell
        if cell == nil{
            cell=getXibClass(name:"NewsTableViewCell", owner:self) as? NewsTableViewCell
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}

