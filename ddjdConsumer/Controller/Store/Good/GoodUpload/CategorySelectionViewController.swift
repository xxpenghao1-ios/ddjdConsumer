//
//  CategorySelectionViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/7.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///分类选择
class CategorySelectionViewController:BaseViewController,UITableViewDataSource,UITableViewDelegate{
    var table:UITableView?
    var displayType=0
    //全部分类
    var arr=[GoodscategoryEntity]()
    //2级分类
    var arr2=[GoodscategoryEntity]()
    //3级分类
    var arr3=[GoodscategoryEntity]()
    var selected1Category:String?
    var selected2Category:String?
    var selected3Category:String?
    //1级分类id
    var fCategoryId:Int?
    //2级分类id
    var sCategoryId:Int?
    //3级分类id
    var tCategoryId:Int?
    var selectedIndexPath:IndexPath?
    var selectedStr:UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="分类选择"
        self.view.backgroundColor=UIColor.white
        configureData()
        configureViews()
        
    }
    func configureData(){
        if (self.displayType == 0) {
            arr=requestAddressInfo(pid:9999)
        }else if (self.displayType == 1){
            arr2=requestAddressInfo(pid:Int64(fCategoryId ?? 0))
        }else if (self.displayType == 2){
            arr3=requestAddressInfo(pid:Int64(sCategoryId ?? 0))
        }
    }
    func configureViews(){
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target:self, action:#selector(cancel))
        self.table = UITableView(frame:self.view.bounds)
        self.table!.delegate = self;
        self.table!.dataSource = self;
        self.table!.emptyDataSetSource=self
        self.table!.emptyDataSetDelegate=self
        self.setEmptyDataSetInfo(text:"还木有相关分类")
        self.table!.tableFooterView=UIView(frame:CGRect.zero)
        self.view.addSubview(self.table!)
    }
    @objc func cancel(){
        self.dismiss(animated: true, completion:nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.displayType == 0{
            return self.arr.count
        }else if self.displayType == 1{
            return self.arr2.count
        }else{
            return self.arr3.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellid="cityCell"
        var cell=tableView.dequeueReusableCell(withIdentifier: cellid)
        if cell == nil{
            cell=UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier:cellid)
            if self.displayType == 2{
                cell!.accessoryType=UITableViewCellAccessoryType.none
            }else{
                cell!.accessoryType=UITableViewCellAccessoryType.disclosureIndicator
            }
        }
        cell!.textLabel!.font=UIFont.systemFont(ofSize:14)
        if self.displayType == 0{
            if self.arr.count > 0{
                let entity=self.arr[indexPath.row]
                cell!.textLabel!.text=entity.goodsCategoryName
            }
            
        }else if self.displayType == 1{
            if self.arr2.count > 0{
                let entity=self.arr2[indexPath.row]
                cell!.textLabel!.text=entity.goodsCategoryName
            }
        }else{
            if self.arr3.count > 0{
                let entity=self.arr3[indexPath.row]
                cell!.textLabel!.text=entity.goodsCategoryName
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.displayType == 0{
            let entity=self.arr[indexPath.row]
            self.selected1Category=entity.goodsCategoryName
            //构建下一级视图控制器
            let cityVC=CategorySelectionViewController()
            cityVC.displayType=1//显示模式为2级分类
            cityVC.selected1Category=self.selected1Category
            cityVC.fCategoryId=entity.goodsCategoryId
            self.navigationController!.pushViewController(cityVC, animated:true)
        }else if self.displayType == 1{
            let entity=self.arr2[indexPath.row]
            self.selected2Category=entity.goodsCategoryName
            //构建下一级视图控制器
            let cityVC=CategorySelectionViewController()
            cityVC.displayType=2//显示模式为3级分类
            cityVC.selected1Category=self.selected1Category
            cityVC.selected2Category=self.selected2Category
            cityVC.fCategoryId=self.fCategoryId
            cityVC.sCategoryId=entity.goodsCategoryId
            self.navigationController!.pushViewController(cityVC, animated:true)
        }else{
            if self.selectedIndexPath != nil{
                //取消上一次选定状态
                let oldCell=table?.cellForRow(at: self.selectedIndexPath!)
                oldCell?.accessoryType = .none
            }
            //勾选当前选定状态
            let newCell=table?.cellForRow(at: indexPath)
            newCell!.accessoryType = .checkmark
            //保存
            self.selected3Category=self.arr3[indexPath.row].goodsCategoryName
            self.tCategoryId=self.arr3[indexPath.row].goodsCategoryId
            self.selectedIndexPath=indexPath
            let alert=UIAlertController(title:"分类选择",message:self.selected3Category, preferredStyle: UIAlertControllerStyle.alert)
            let ok=UIAlertAction(title:"确定", style: UIAlertActionStyle.default, handler:{ Void in
                NotificationCenter.default.post(name:NSNotificationNameCategorySelection, object:nil, userInfo:["str":self.selected3Category ?? "","tCategoryId":self.tCategoryId ?? 0,"sCategoryId":self.sCategoryId ?? 0,"fCategoryId":self.fCategoryId ?? 0])
                self.dismiss(animated: true, completion:nil)
                
            })
            let cancel=UIAlertAction(title:"取消", style: UIAlertActionStyle.cancel, handler:nil)
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated:true, completion:nil)
        }
        
        self.table?.deselectRow(at: self.table!.indexPathForSelectedRow!, animated:true)
    }
    
}
extension CategorySelectionViewController{
    /**
     请求分类信息
     - parameter
     */
    func requestAddressInfo(pid:Int64) -> [GoodscategoryEntity]{
        return GoodClassificationDB.shared.selectArr(pid:pid)
    }
}
