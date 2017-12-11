//
//  StoreGoodListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/8.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import SnapKit
import JNDropDownMenu
///商品列表
class StoreGoodListViewController:BaseViewController{
    ///1上架 2下架
    var goodsFlag:Int?
    ///数据集合
    private var arr=[GoodEntity]()
    //分类集合  (全部分类)
    private var categoryArr=[GoodscategoryEntity]()
    //2级分类
    private var categoryArr2=[GoodscategoryEntity]()
    //3级分类
    private var categoryArr3=[GoodscategoryEntity]()
    //分类行索引
    private var index1=0
    private var index2=0
    private var index3=0
    //分类名称
    private var goodsCategoryName:String?
    private var pageNumber=1
    //全部
    @IBOutlet weak var btnAll: UIButton!
    //筛选
    @IBOutlet weak var btnScreening: UIButton!
    //table
    @IBOutlet weak var table: UITableView!
    
    ///3级分类id  如果为空查全部
    private var tCategoryId:Int?
    ///分类选择
    private var pickerView:UIPickerView!
    ///遮罩层
    private var pickerMaskView:UIView!
    ///分类选择view
    private var contentPickerView:UIView!
    
    ///商品操作 遮罩层
    private var operatingGoodMaskView:UIView!
    ///商品操作table
    private var operatingTable:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpData()
        setUpView()
        self.queryStoreAndGoodsList(pageNumber:self.pageNumber, pageSize:10,isRefresh:true)
        table.mj_header=PHNormalHeader(refreshingBlock: {
            self.pageNumber=1
            self.queryStoreAndGoodsList(pageNumber:self.pageNumber, pageSize:10,isRefresh:true)
        })
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.queryStoreAndGoodsList(pageNumber:self.pageNumber, pageSize:10,isRefresh:false)
        })
        table.mj_footer.isHidden=true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if pickerMaskView.isHidden == false{//页面退出 隐藏分类选择
            self.hidePickerView()
        }
    }
}
extension StoreGoodListViewController{
    private func setUpView(){
        self.title=goodsFlag!==1 ? "已上架" : "已下架"
        btnAll.addTarget(self, action:#selector(screening), for: UIControlEvents.touchUpInside)
        btnAll.tag=1
        ///默认选中全部
        btnAll.isSelected=true
        btnScreening.tag=2
        btnScreening.addTarget(self, action: #selector(screening), for: UIControlEvents.touchUpInside)
        
        table.dataSource=self
        table.delegate=self
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        self.setLoadingState(isLoading:true)
        self.setEmptyDataSetInfo(text:"还没有\(self.title!)商品")
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        
        setUpPickerView()
        setUpOperatingTableView()
    }
    @objc private func screening(sender:UIButton){
        sender.isSelected=true
        if sender.tag == 1{
            btnScreening.isSelected=false
            tCategoryId=nil
            btnScreening.setTitle("筛选", for: UIControlState.normal)
            table.mj_header.beginRefreshing()
        }else{
            btnAll.isSelected=false
            showPickerView()
        }
    }
    private func reloadTable(){
        self.setLoadingState(isLoading:false)
        self.table.reloadData()
        self.table.mj_footer.endRefreshing()
        self.table.mj_header.endRefreshing()
    }
}
///设置商品操作 (上下架,查看商品信息,加入促销)
extension StoreGoodListViewController{
    ///设置商品操作table
    private func setUpOperatingTableView(){
        operatingGoodMaskView=UIView(frame:table.bounds)
        operatingGoodMaskView.backgroundColor = UIColor.init(white:0, alpha:0.5)
        operatingGoodMaskView.isUserInteractionEnabled=true
        operatingGoodMaskView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(hideOperatingView)))
        self.view.addSubview(operatingGoodMaskView)
        ///默认隐藏
        operatingGoodMaskView.isHidden=true
        
        operatingTable=UITableView(frame: CGRect.init(x:0, y:-150,width: boundsWidth, height:150), style: UITableViewStyle.plain)
        operatingTable.delegate=self
        operatingTable.dataSource=self
        operatingTable.tag=100
        operatingTable.isScrollEnabled=false
        operatingGoodMaskView.addSubview(operatingTable)
    }
    ///显示
    private func showOperatingView(){
        operatingGoodMaskView.isHidden=false
        UIView.animate(withDuration:0.5, delay:0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.operatingTable.frame=CGRect.init(x:0,y:0, width:boundsWidth,height:150)
        })
    }
    ///隐藏
    @objc private func hideOperatingView(){
        UIView.animate(withDuration:0.5, delay:0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.operatingTable.frame=CGRect.init(x:0, y:-150,width:boundsWidth,height:150)
        }, completion: { (b) in
            UIView.animate(withDuration:0.1, delay:0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.operatingGoodMaskView.isHidden=true
            }, completion: nil)
        })
    }
}
///设置分类相关
extension StoreGoodListViewController{
    ///设置分类数据
    private func setUpData(){
        categoryArr=GoodClassificationDB.shared.selectArr(pid:9999)
        for i in 0..<categoryArr.count{
            let entity=categoryArr[i]
            categoryArr[i].arr2=GoodClassificationDB.shared.selectArr(pid:Int64(entity.goodsCategoryId!))
            for j in 0 ..< categoryArr[i].arr2!.count{
                let entity1=categoryArr[i].arr2![j]
                categoryArr[i].arr2![j].arr2=GoodClassificationDB.shared.selectArr(pid:Int64(entity1.goodsCategoryId!))
            }
        }
    }
    ///设置分类选择
    private func setUpPickerView(){
        index1=categoryArr.count/2
        calculateFirstData()
        
        pickerMaskView=UIView(frame:table.bounds)
        pickerMaskView.backgroundColor = UIColor.init(white:0, alpha:0.5)
        pickerMaskView.isUserInteractionEnabled=true
        pickerMaskView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(hidePickerView)))
        self.view.addSubview(pickerMaskView)
        ///默认隐藏
        pickerMaskView.isHidden=true
        
        contentPickerView=UIView(frame: CGRect.init(x:0,y:pickerMaskView.frame.height,width:boundsWidth, height:340))
        contentPickerView.backgroundColor=UIColor.white
        pickerMaskView.addSubview(contentPickerView)
        
        let lightGrayView=UIView(frame:CGRect.init(x:0, y:39.5, width:boundsWidth, height: 0.5))
        lightGrayView.backgroundColor=UIColor.lightGray
        contentPickerView.addSubview(lightGrayView)
        
        let btnCancel=UIButton.button(type: ButtonType.button, text:"取消", textColor:UIColor.applicationMainColor(), font:15, backgroundColor: UIColor.clear,cornerRadius:nil)
        btnCancel.frame=CGRect.init(x:15, y:0, width:45, height:39.5)
        btnCancel.addTarget(self, action:#selector(hidePickerView), for: UIControlEvents.touchUpInside)
        contentPickerView.addSubview(btnCancel)
        
        let btnConfirm=UIButton.button(type: ButtonType.button, text:"确认", textColor:UIColor.applicationMainColor(), font:15, backgroundColor: UIColor.clear,cornerRadius:nil)
        btnConfirm.frame=CGRect.init(x:boundsWidth-55, y:0, width:45, height:39.5)
        btnConfirm.addTarget(self, action:#selector(confirmSelected), for: UIControlEvents.touchUpInside)
        contentPickerView.addSubview(btnConfirm)
        
        let lblTitle=UILabel.buildLabel(textColor:UIColor.black, font:15, textAlignment: NSTextAlignment.center)
        lblTitle.frame=CGRect.init(x:60, y:0, width:boundsWidth-115, height:39.5)
        lblTitle.text="分类选择"
        lblTitle.font=UIFont.boldSystemFont(ofSize:15)
        contentPickerView.addSubview(lblTitle)
        
        pickerView=UIPickerView(frame: CGRect.init(x:0,y:40,width:boundsWidth, height:300))
        pickerView.delegate=self
        pickerView.dataSource=self
        pickerView.backgroundColor=UIColor.white
        //设置选择框的默认值
        pickerView.selectRow(index1,inComponent:0,animated:true)
        pickerView.selectRow(index2,inComponent:1,animated:true)
        pickerView.selectRow(index3,inComponent:2,animated:true)
        contentPickerView.addSubview(pickerView)
    }
    ///显示
    private func showPickerView(){
        pickerMaskView.isHidden=false
        UIView.animate(withDuration:0.5, delay:0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.contentPickerView.frame=CGRect.init(x:0, y:self.pickerMaskView.frame.height-340, width:boundsWidth,height:340)
        })
    }
    ///隐藏
    @objc private func hidePickerView(){
        UIView.animate(withDuration:0.5, delay:0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.contentPickerView.frame=CGRect.init(x:0, y:self.pickerMaskView.frame.height,width:boundsWidth,height:340)
        }, completion: { (b) in
            UIView.animate(withDuration:0.1, delay:0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.pickerMaskView.isHidden=true
            }, completion: nil)
        })
    }
    ///确认选择
    @objc private func confirmSelected(){
        if categoryArr3.count > 0{//如果有数据刷新数据
            tCategoryId=categoryArr3[index3].goodsCategoryId
            goodsCategoryName=categoryArr3[index3].goodsCategoryName
            btnScreening.setTitle(goodsCategoryName, for: UIControlState.normal)
            hidePickerView()
            table.mj_header.beginRefreshing()
        }else{
            hidePickerView()
        }
    }
    ///根据传进来的下标数组计算对应的三个数组
    private func calculateFirstData(){
        categoryArr2=categoryArr[index1].arr2 ?? [GoodscategoryEntity]()
        if categoryArr2.count > 0{
            categoryArr3=categoryArr2[index2].arr2 ?? [GoodscategoryEntity]()
        }else{
            categoryArr3=[GoodscategoryEntity]()
        }
    }
}
/// 分类UIPickerView 相关协议
extension StoreGoodListViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return categoryArr.count
        }else if component == 1{
            return categoryArr2.count
        }else if component == 2{
            return categoryArr3.count
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return categoryArr[row].goodsCategoryName
        }else if component == 1{
            if  categoryArr2.count > 0{
                return categoryArr2[row].goodsCategoryName
            }
        }else if component == 2{
            if categoryArr3.count > 0{
                return categoryArr3[row].goodsCategoryName
            }
        }
        return nil
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return boundsWidth/3
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var lbl=view as? UILabel
        if lbl == nil{
            lbl=UILabel()
            lbl?.font=UIFont.systemFont(ofSize: 14)
        }
        if component == 0{
            lbl?.text=categoryArr[row].goodsCategoryName
        }else if component == 1{
            if categoryArr2.count > 0{
                lbl?.text=categoryArr2[row].goodsCategoryName
            }
        }else if component == 2{
            if categoryArr3.count > 0{
                lbl?.text=categoryArr3[row].goodsCategoryName
            }
        }
        lbl?.textAlignment = .center
        return lbl!
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            self.index1 = row;
            self.index2 = 0;
            self.index3 = 0;
            // 滚动的时候都要进行一次数组的刷新
            self.calculateFirstData()
            pickerView.reloadComponent(1)
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent:1, animated: true)
            pickerView.selectRow(0, inComponent:2, animated: true)
        }else if component == 1{
            self.index2 = row;
            self.index3 = 0;
            // 滚动的时候都要进行一次数组的刷新
            self.calculateFirstData()
            pickerView.selectRow(0, inComponent:2, animated: true)
            pickerView.reloadComponent(2)
        }else if component == 2{
            self.index3 = row;
            if categoryArr3.count > 0{
                goodsCategoryName=categoryArr3[index3].goodsCategoryName
                tCategoryId=categoryArr3[index3].goodsCategoryId
            }
        }
    }
}
///table协议
extension StoreGoodListViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 100{
            var cell=tableView.dequeueReusableCell(withIdentifier:"id")
            if cell == nil{
                cell=UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier:"id")
            }
            cell!.accessoryType = .disclosureIndicator
            cell!.textLabel!.font=UIFont.systemFont(ofSize:14)
            if indexPath.row == 0{
                if goodsFlag! == 1{//如是上架
                    cell!.textLabel!.text="下架"
                }else{
                    cell!.textLabel!.text="上架"
                }
            }else if indexPath.row == 1{
                cell!.textLabel!.text="修改商品信息"
            }else if indexPath.row == 2{
                cell!.textLabel!.text="加入促销"
            }
            return cell!
        }else{
            var cell=tableView.dequeueReusableCell(withIdentifier:"storeGoodListId") as? StoreGoodListTableViewCell
            if cell == nil{
                cell=getXibClass(name:"StoreGoodListTableViewCell", owner:self) as? StoreGoodListTableViewCell
            }
            if arr.count > 0{
                let entity=arr[indexPath.row]
                cell!.updateCell(entity:entity)
            }
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 100{
            return 50
        }
        return 120
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 100{
            return 3
        }
        return arr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中效果颜色
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.tag == 100{
        }else{
            showOperatingView()
        }
    }
    
}
extension StoreGoodListViewController{
    private func queryStoreAndGoodsList(pageNumber:Int,pageSize:Int,isRefresh:Bool){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.queryStoreAndGoodsList(storeId:STOREID, goodsFlag:goodsFlag!, pageNumber: pageNumber, pageSize: pageSize,tCategoryId:tCategoryId), successClosure: { (json) in
            if isRefresh{
                self.arr.removeAll()
            }
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object:value.object)
                entity!.goodsFlag=self.goodsFlag
                self.arr.append(entity!)
            }
            if self.arr.count < json["totalRow"].intValue{
                self.table.mj_footer.isHidden=false
            }else{
                self.table.mj_footer.isHidden=true
            }
            self.reloadTable()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.reloadTable()
        }
    }
}