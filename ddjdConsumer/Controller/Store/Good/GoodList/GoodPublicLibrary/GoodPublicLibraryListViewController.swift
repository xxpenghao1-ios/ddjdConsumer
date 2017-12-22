//
//  GoodPublicLibraryListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/20.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///公共商品库list
class GoodPublicLibraryListViewController:BaseViewController{
    ///数据集合
    private var arr=[GoodEntity]()
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
    ///加入门店
    @IBOutlet weak var btnAddStore: UIButton!
    ///选择了多少商品
    @IBOutlet weak var lblSeclectedGoodCount: UILabel!
    ///商品总数量
    @IBOutlet weak var lblGoodSumCount: UILabel!
    ///加入门店view
    @IBOutlet weak var addStoreView: UIView!
    ///3级分类id  如果为空查全部
    private var tCategoryId:Int?
    ///分类选择
    private var pickerView:UIPickerView!
    ///遮罩层
    private var pickerMaskView:UIView!
    ///分类选择view
    private var contentPickerView:UIView!
    
    ///返回上一页 刷新数据
    override func navigationShouldPopOnBackButton() -> Bool {
        NotificationCenter.default.removeObserver(self)
        ///通知门店商品列表刷新页面
        NotificationCenter.default.post(name:notificationNameUpdateStoreGoodList, object:nil)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        self.title="公共商品库"
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
    ///刷新数据
    @objc private func updateList(not:Notification){
        self.table.mj_header.beginRefreshing()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if pickerMaskView.isHidden == false{//页面退出 隐藏分类选择
            self.hidePickerView()
        }
    }
}
// MARK: - 滑动协议
extension GoodPublicLibraryListViewController{
    //监听滑动事件
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 600{//滑动600距离显示返回顶部按钮
            returnImg.isHidden=false
        }else{
            returnImg.isHidden=true
        }
    }
}
extension GoodPublicLibraryListViewController{
    ///加载页面设置
    private func setUpView(){
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
        self.setEmptyDataSetInfo(text:"平台商品库中已经没有商品可以加入了")
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        
        returnImg.isUserInteractionEnabled=true
        returnImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(returnTop)))
        returnImg.isHidden=true
        
        btnAddStore.disable()
        btnAddStore.addTarget(self, action:#selector(allAddStore), for: UIControlEvents.touchUpInside)
        setUpPickerView()
    }
    ///商品多选加入门店
    @objc private func allAddStore(){
        var goodsId:String=""
        for entity in self.arr{
            if entity.checkOrCance == 1{
                goodsId+="\(entity.goodsId!)"+","
            }
        }
        self.addGoodsInfoGoToStoreAndGoods(goodsId:goodsId)
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
        statisticsSelectedGoodCount()
    }
}
///设置分类相关
extension GoodPublicLibraryListViewController{
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
extension GoodPublicLibraryListViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if NSStringFromClass((touch.view?.classForCoder)!) == "UITableViewCellContentView"{
            return false
        }
        return true
    }
}
/// 分类UIPickerView 相关协议
extension GoodPublicLibraryListViewController:UIPickerViewDelegate,UIPickerViewDataSource{
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
extension GoodPublicLibraryListViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell=tableView.dequeueReusableCell(withIdentifier:"id") as? GoodPublicLibraryListTableViewCell
        if cell == nil{
            cell=getXibClass(name:"GoodPublicLibraryListTableViewCell", owner:self) as? GoodPublicLibraryListTableViewCell
        }
        if arr.count > 0{
            let entity=arr[indexPath.row]
            cell!.updateCell(entity:entity)
            cell!.addClosure={
                UIAlertController.showAlertYesNo(self, title:"温馨提示", message:"加入您商品库后,商品为下架状态", cancelButtonTitle:"取消", okButtonTitle:"确定", okHandler: { (action) in
                    self.addGoodsInfoGoToStoreAndGoods(goodsId:"\(entity.goodsId!),")
                })
            }
            cell!.isSelectedGoodClosure={ (checkOrCance) in
                self.arr[indexPath.row].checkOrCance=checkOrCance
                self.statisticsSelectedGoodCount()
            }
        }
        return cell!
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中效果颜色
        tableView.deselectRow(at: indexPath, animated: true)
        let entity=arr[indexPath.row]
        let vc=self.storyboardPushView(type:.storeGood, storyboardId:"UpdateStoreGoodDetailVC") as! UpdateStoreGoodDetailViewController
        ///默认上架状态
        entity.goodsFlag=1
        vc.goodEntity=entity
        vc.flag=1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension GoodPublicLibraryListViewController{
    //查询公共商品库
    private func queryStoreAndGoodsList(pageNumber:Int,pageSize:Int,isRefresh:Bool){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.queryGoodsInfoList_store(storeId:STOREID, pageNumber: pageNumber, pageSize: pageSize,goodsName:nil,tCategoryId:tCategoryId), successClosure: { (json) in
            print(json)
            if isRefresh{
                self.arr.removeAll()
            }
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object:value.object)
                entity!.checkOrCance=2
                self.arr.append(entity!)
            }
            if self.arr.count < json["totalRow"].intValue{
                self.table.mj_footer.isHidden=false
            }else{
                self.table.mj_footer.isHidden=true
            }
            self.lblGoodSumCount.text="\(self.arr.count)/\(json["totalRow"].intValue)"
            if self.arr.count > 0{
                self.addStoreView.isHidden=false
            }else{
                self.addStoreView.isHidden=true
            }
            self.reloadTable()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.reloadTable()
        }
    }
    ///单选or多选添加到店铺商品库
    private func addGoodsInfoGoToStoreAndGoods(goodsId:String){
        self.showSVProgressHUD(status:"正在添加...",type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.addGoodsInfoGoToStoreAndGoods(storeId:STOREID, goodsId:goodsId), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"添加成功", type: HUD.success)
                self.table.mj_header.beginRefreshing()
            }else{
                self.showSVProgressHUD(status:"添加失败", type: HUD.success)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    ///统计选择商品数量
    private func statisticsSelectedGoodCount(){
        var count=0
        for entity in arr{
            if entity.checkOrCance == 1{
                count+=1
            }
        }
        if count > 0{
            self.btnAddStore.enable()
        }else{
            self.btnAddStore.disable()
        }
        self.lblSeclectedGoodCount.text="共选择\(count)种商品"
    }
}
