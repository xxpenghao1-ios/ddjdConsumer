//
//  StoreGoodListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/8.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///商品列表
class StoreGoodListViewController:BaseViewController{
    ///1上架 2下架
    var goodsFlag:Int?
    ///数据集合
    private var arr=[GoodEntity]()
    ///数据总条数默认等于0
    private var totalRow=0
    ///选中商品
    private var selectedGoodEntity:GoodEntity?
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
    //返回图片
    @IBOutlet weak var returnImg: UIImageView!
    
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
    ///商品操作table高度
    private var operatingTableHeight:CGFloat{
        get{
            return goodsFlag==1 ? 200:100
        }
    }
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
        ///接收通知刷新页面
        NotificationCenter.default.addObserver(self,selector:#selector(updateList), name:notificationNameUpdateStoreGoodList, object:nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if pickerMaskView.isHidden == false{//页面退出 隐藏分类选择
            self.hidePickerView()
        }
        if operatingGoodMaskView != nil{
            if operatingGoodMaskView.isHidden == false{ //页面退出 隐藏商品操作view
                self.hideOperatingView()
            }
        }
    }
    ///刷新数据
    @objc private func updateList(not:Notification){
        let userInfo=not.userInfo
        if userInfo != nil{
            let index=userInfo!["index"] as? IndexPath
            let goodsFlag=userInfo!["goodsFlag"] as? Int
            if index != nil{
                if self.goodsFlag == goodsFlag{//当前页面状态等于当前刷新状态
                    self.queryStoreAndGoodsDetail(index:index!)
                }else{
                    self.table.mj_header.beginRefreshing()
                }
            }
        }else{
            self.table.mj_header.beginRefreshing()
        }
    }
}
// MARK: - 滑动协议
extension StoreGoodListViewController{
    //监听滑动事件
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 600{//滑动600距离显示返回顶部按钮
            returnImg.isHidden=false
        }else{
            returnImg.isHidden=true
        }
    }
}
extension StoreGoodListViewController{
    ///加载页面设置
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
        table.tag=100
        table.backgroundColor=UIColor.clear
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        table.estimatedRowHeight=0;
        table.estimatedSectionHeaderHeight=0;
        table.estimatedSectionFooterHeight=0;
        self.setLoadingState(isLoading:true)
        self.setEmptyDataSetInfo(text:"还没有\(self.title!)商品")
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        
        returnImg.isUserInteractionEnabled=true
        returnImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(returnTop)))
        returnImg.isHidden=true
        
        setUpPickerView()
    }
    ///返回顶部
    @objc private func returnTop(){
        let at=IndexPath(item:0, section:0)
        self.table.scrollToRow(at:at, at: UITableViewScrollPosition.bottom, animated:true)
    }
    ///筛选分类
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
    ///刷新table
    private func reloadTable(){
        self.setLoadingState(isLoading:false)
        self.table.reloadData()
        self.table.mj_footer.endRefreshing()
        self.table.mj_header.endRefreshing()
    }
}
///设置商品操作 (上下架,查看商品信息,加入促销,加入首页推荐)
extension StoreGoodListViewController{
    ///显示
    private func showOperatingView(tag:Int){
        operatingGoodMaskView=UIView(frame:CGRect.init(x:0,y:0, width:boundsWidth, height:boundsHeight-navHeight-bottomSafetyDistanceHeight))
        operatingGoodMaskView.backgroundColor = UIColor.init(white:0, alpha:0.5)
        operatingGoodMaskView.isUserInteractionEnabled=true
        let gesture=UITapGestureRecognizer(target:self, action:#selector(hideOperatingView))
        gesture.delegate=self
        operatingGoodMaskView.addGestureRecognizer(gesture)
        self.view.addSubview(operatingGoodMaskView)

        operatingTable=UITableView(frame: CGRect.init(x:0, y:-operatingTableHeight,width: boundsWidth, height:operatingTableHeight), style: UITableViewStyle.plain)
        operatingTable.delegate=self
        operatingTable.dataSource=self
        operatingTable.tag=tag
        operatingTable.isScrollEnabled=false
        operatingGoodMaskView.addSubview(operatingTable)
        UIView.animate(withDuration:0.3, delay:0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.operatingTable.frame=CGRect.init(x:0,y:0, width:boundsWidth,height:self.operatingTableHeight)
        })
    }
    ///隐藏
    @objc private func hideOperatingView(){
        UIView.animate(withDuration:0.3, delay:0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.operatingTable.frame=CGRect.init(x:0, y:-self.operatingTableHeight,width:boundsWidth,height:self.operatingTableHeight)
        }, completion: { (b) in
            UIView.animate(withDuration:0.1, delay:0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.operatingGoodMaskView.isHidden=true
            }, completion:{ (b) in
                self.operatingTable.removeFromSuperview()
                self.operatingGoodMaskView.removeFromSuperview()
            })
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
        let gesture=UITapGestureRecognizer(target:self, action:#selector(hidePickerView))
        gesture.delegate=self
        pickerMaskView.addGestureRecognizer(gesture)
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
        lblTitle.text="分类筛选"
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
        self.view.bringSubview(toFront:pickerMaskView)
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
        if categoryArr.count > 0{
            categoryArr2=categoryArr[index1].arr2 ?? [GoodscategoryEntity]()
        }
        if categoryArr2.count > 0{
            categoryArr3=categoryArr2[index2].arr2 ?? [GoodscategoryEntity]()
        }else{
            categoryArr3=[GoodscategoryEntity]()
        }
    }
}
///监听view点击事件
extension StoreGoodListViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if NSStringFromClass((touch.view?.classForCoder)!) == "UITableViewCellContentView"{
            return false
        }
        if touch.view != pickerMaskView && touch.view != operatingGoodMaskView{
            return false
        }
        return true
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
            if categoryArr.count > 0{
                return categoryArr[row].goodsCategoryName
            }
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
            if categoryArr.count > 0{
                lbl?.text=categoryArr[row].goodsCategoryName
            }
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
        if tableView.tag != 100{
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
                if arr.count > 0{
                    if arr[tableView.tag].goodsStutas == 1{
                        cell!.textLabel!.text="加入促销"
                    }else if arr[tableView.tag].goodsStutas == 3{
                        cell!.textLabel!.text="从促销区移除"
                    }
                }
            }else if indexPath.row == 3{
                if arr.count > 0{
                    if arr[tableView.tag].indexGoodsId == nil{
                        cell!.textLabel!.text="加入首页推荐"
                    }else{
                        cell!.textLabel!.text="从首页推荐区移除"
                    }
                }
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
        if tableView.tag != 100{
            return 50
        }
        return 120
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag != 100{
            if goodsFlag == 1{//如果是上架
                return 4
            }else{
                return 2
            }
        }
        return arr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中效果颜色
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.tag != 100{
            switch indexPath.row{
            case 0: //商品上下架
               var message=""
               if goodsFlag == 1{
                    message="下架"
               }else{
                    message="上架"
               }
                UIAlertController.showAlertYesNo(self, title:"", message:"确定\(message)吗?", cancelButtonTitle:"取消", okButtonTitle:"确定", okHandler: { (action) in
                    self.updateGoodsFlagByStoreAndGoodsId(storeAndGoodsId: self.selectedGoodEntity?.storeAndGoodsId ?? 0, goodsFlag:self.goodsFlag!==1 ? 2 : 1,row: tableView.tag)
                })
                break
            case 1:
                let vc=storyboardPushView(type:.storeGood, storyboardId:"UpdateStoreGoodDetailVC") as! UpdateStoreGoodDetailViewController
                vc.index=IndexPath.init(row:tableView.tag, section:0)
                vc.goodEntity=selectedGoodEntity
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case 2:
                let entity=self.arr[tableView.tag]
                if entity.goodsStutas == 3{//如果已经加入促销
                    UIAlertController.showAlertYesNo(self, title:"温馨提示", message:"您确定从促销区移除吗?", cancelButtonTitle:"取消", okButtonTitle:"确定", okHandler: { (action) in
                        self.removePromotiongoods(storeAndGoodsId:entity.storeAndGoodsId ?? 0,row:tableView.tag)
                    })
                }else{//加入促销
                    self.addPromotiongoods(storeAndGoodsId:entity.storeAndGoodsId ?? 0, row: tableView.tag)
                }
                break
            case 3:
                if self.arr[tableView.tag].indexGoodsId == nil{
                    let alert=UIAlertController(title:"提示", message:"确定加入首页推荐区吗?", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addTextField(configurationHandler: { (txt) in
                        txt.keyboardType = .numberPad
                        txt.placeholder="排序值(值越小显示位置越靠前)"
                        NotificationCenter.default.addObserver(self, selector: #selector(self.alertTextFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange,object:txt)
                    })
                    let ok=UIAlertAction(title:"确定", style: UIAlertActionStyle.default, handler: { (action) in
                        let text=(alert.textFields?.first)! as UITextField
                        self.addIndexGoods(storeAndGoodsId:self.arr[tableView.tag].storeAndGoodsId ?? 0, sort:Int(text.text!) ?? 0,row:tableView.tag)
                    })
                    let cancel=UIAlertAction(title:"取消", style: UIAlertActionStyle.cancel, handler:nil)
                    alert.addAction(cancel)
                    alert.addAction(ok)
                    self.present(alert, animated:true, completion:nil)
                }else{
                    UIAlertController.showAlertYesNo(self, title:"温馨提示", message:"您确定从首页推荐区移除吗?", cancelButtonTitle:"取消", okButtonTitle:"确定", okHandler: { (action) in
                        self.deleteIndexGoods(storeAndGoodsId:self.arr[tableView.tag].storeAndGoodsId ?? 0, row:tableView.tag)
                    })
                }
                break
            default:break
            }
        }else{
            selectedGoodEntity=arr[indexPath.row]
            showOperatingView(tag:indexPath.row)
        }
    }
    
}
extension StoreGoodListViewController{
    //检测输入框
    @objc func alertTextFieldDidChange(_ notification: Notification){
        let alertController = self.presentedViewController as! UIAlertController?
        if (alertController != nil) {
            let text = (alertController!.textFields?.first)! as UITextField
            let okAction = alertController!.actions.last! as UIAlertAction
            if text.text != nil && text.text!.count > 0 {
                okAction.isEnabled = true
            }else{
                okAction.isEnabled=false
            }
        }
    }
    //查询商品
    private func queryStoreAndGoodsList(pageNumber:Int,pageSize:Int,isRefresh:Bool){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.queryStoreAndGoodsList(storeId:STOREID, goodsFlag:goodsFlag!, pageNumber: pageNumber, pageSize: pageSize,tCategoryId:tCategoryId), successClosure: { (json) in
            print(json)
            if isRefresh{
                self.arr.removeAll()
            }
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object:value.object)
                entity!.goodsFlag=self.goodsFlag
                self.arr.append(entity!)
            }
            self.totalRow=json["totalRow"].intValue
            if self.arr.count < self.totalRow{
                self.table.mj_footer.isHidden=false
            }else{
                self.table.mj_footer.isHidden=true
            }
            self.showBaseVCGoodCountPromptView(currentCount:self.arr.count, totalCount:self.totalRow)
            self.reloadTable()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.reloadTable()
        }
    }
    ///查询店铺商品详情
    private func queryStoreAndGoodsDetail(index:IndexPath){
        let goodEntity=self.arr[index.row]
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.queryStoreAndGoodsDetail(storeAndGoodsId:goodEntity.storeAndGoodsId ?? 0, storeId:STOREID), successClosure: { (json) in
            let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object:json.object)
            entity?.indexGoodsId=goodEntity.indexGoodsId
            entity?.goodsStutas=goodEntity.goodsStutas
            if self.goodsFlag != entity?.goodsFlag{//如果上下架状态不匹配  表示已经在修改中更改 删除当前行数据
                ///删除原有数据
                self.arr.remove(at:index.row)
                self.table.deleteRows(at:[index], with: UITableViewRowAnimation.fade)
                self.totalRow=self.totalRow-1
                self.showBaseVCGoodCountPromptView(currentCount:self.arr.count, totalCount:self.totalRow)
                return
            }
            if entity != nil{
                ///删除原有数据
                self.arr.remove(at:index.row)
                //重新插入新数据
                self.arr.insert(entity!, at:index.row)
                self.table.reloadRows(at:[index], with: UITableViewRowAnimation.fade)
            }
        }) { (error) in
            self.showSVProgressHUD(status:"获取\(goodEntity.goodsName ?? "")修改信息失败", type: HUD.error)
        }
    }
    ///商品上下架
    private func updateGoodsFlagByStoreAndGoodsId(storeAndGoodsId:Int,goodsFlag:Int,row:Int){
        self.showSVProgressHUD(status:"正在加载...",type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.updateGoodsFlagByStoreAndGoodsId(storeAndGoodsId:storeAndGoodsId, goodsFlag: goodsFlag), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"操作成功", type: HUD.success)
                self.arr.remove(at:row)
                self.table.deleteRows(at:[IndexPath.init(row:row, section:0)], with: UITableViewRowAnimation.fade)
                self.totalRow=self.totalRow-1
                self.showBaseVCGoodCountPromptView(currentCount:self.arr.count, totalCount:self.totalRow)
            }else if success == "incomplete"{
                self.showSVProgressHUD(status:"部分参数没有填写或填写的值小于等于0,（零售价，进货价，库存),不能上架",type: HUD.error)
            }else{
                self.showSVProgressHUD(status:"操作失败", type: HUD.error)
            }
            self.hideOperatingView()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///店铺添加首页商品
    private func addIndexGoods(storeAndGoodsId:Int,sort:Int,row:Int){
        self.showSVProgressHUD(status:"正在加入...",type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.addIndexGoods(storeAndGoodsId:storeAndGoodsId , storeId:STOREID, sort:sort), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"加入成功", type: HUD.success)
                self.arr[row].indexGoodsId=1
                self.table.reloadRows(at:[IndexPath.init(row:row, section:0)], with: UITableViewRowAnimation.none)
                self.hideOperatingView()
            }else if success == "exist" {
                self.showSVProgressHUD(status:"该商品已经在首页推荐区了", type: HUD.info)
            }else{
                self.showSVProgressHUD(status:"加入失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    private func deleteIndexGoods(storeAndGoodsId:Int,row:Int){
        self.showSVProgressHUD(status:"正在移除...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.removeIndexGoods(storeAndGoodsId:storeAndGoodsId, storeId:STOREID), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"移除成功", type: HUD.success)
                self.arr[row].indexGoodsId=nil
                self.table.reloadRows(at:[IndexPath.init(row:row, section:0)], with: UITableViewRowAnimation.none)
                self.hideOperatingView()
            }else if success == "notExist" {
                self.showSVProgressHUD(status:"不存在，不是首页热门推荐商品", type: HUD.info)
            }else{
                self.showSVProgressHUD(status:"移除失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///移除促销商品
    private func removePromotiongoods(storeAndGoodsId:Int,row:Int){
        self.showSVProgressHUD(status:"正在移除...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.removePromotiongoods(storeAndGoodsId:storeAndGoodsId, storeId:STOREID), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.arr[row].goodsStutas=1
                self.table.reloadRows(at:[IndexPath.init(row:row, section:0)], with: UITableViewRowAnimation.none)
                self.hideOperatingView()
                self.showSVProgressHUD(status:"移除成功", type: HUD.success)
            }else if success == "notExist"{
                self.showSVProgressHUD(status:"商品不存在", type: HUD.error)
            }else if success == "storeDifferent"{
                self.showSVProgressHUD(status:"商品不是这个店铺的，不能移除", type: HUD.error)
            }else{
                self.showSVProgressHUD(status:"移除失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///添加促销商品
    private func addPromotiongoods(storeAndGoodsId:Int,row:Int){
        let vc=self.storyboardPushView(type:.storeGood, storyboardId:"AddPromotionGoodVC") as! AddPromotionGoodViewController
        vc.storeAndGoodsId=storeAndGoodsId
        vc.reloadListClosure={
            self.arr[row].goodsStutas=3
            self.table.reloadRows(at:[IndexPath.init(row:row, section:0)], with: UITableViewRowAnimation.none)
        }
        self.navigationController?.pushViewController(vc, animated:true)
        self.hideOperatingView()
    }
}
