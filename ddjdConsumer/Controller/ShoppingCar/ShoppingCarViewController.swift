//
//  ShoppingCarViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/2.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///购物车
class ShoppingCarViewController:BaseViewController{
    //购物车列表
    @IBOutlet weak var table: UITableView!
    //底部结算view
    @IBOutlet weak var bottomView: UIView!
    //全选
    @IBOutlet weak var btnAllChecked: UIButton!
    //合计
    @IBOutlet weak var lblSumPrice: UILabel!
    //起送价格
    @IBOutlet weak var lblSendPrice: UILabel!
    //结算
    @IBOutlet weak var btnClearing: UIButton!
    ///起送价格
    var sendPrice:Int{
        get{
            return userDefaults.object(forKey:"lowestMoney") as? Int ?? 0
        }
    }
    //保存数据源
    private var arr=[GoodEntity]()
    ///保存总价格
    private var sumPrice:String = "0"{
        willSet{
            let str="合计:￥\(newValue)"
            lblSumPrice.attributedText=UILabel.setAttributedText(str:str, textColor:UIColor.applicationMainColor(), font:15, range: NSRange.init(location:3,length: str.count-3))
        }
    }
    private var pageNumber=1
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MEMBERID == -1{
            self.present(UINavigationController.init(rootViewController:app.returnLoginVC()), animated:true, completion:nil)
        }else{
            getStoreInfo()
            self.getCarGoodList(pageSize:5000, pageNumber:self.pageNumber)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
}

// MARK: - 设置页面
extension ShoppingCarViewController{
    private func setUpView(){
        //去掉底部多余cell
        table.tableFooterView=UIView(frame:CGRect.zero)
        table.backgroundColor=UIColor.viewBackgroundColor()
        table.estimatedRowHeight=0;
        table.estimatedSectionHeaderHeight=0;
        table.estimatedSectionFooterHeight=0;
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        self.setDisplay(isDisplay:false)
        self.setEmptyDataSetInfo(text:"购物车空空如也")
        //设置全选按钮2种状态图片
        btnAllChecked.setImage(UIImage(named:"uncheck"), for: UIControlState.normal)
        btnAllChecked.setImage(UIImage(named:"checked"), for: UIControlState.selected)
        btnAllChecked.addTarget(self, action:#selector(isArrSelected), for: UIControlEvents.touchUpInside)
        //默认隐藏结算view
        self.bottomView.isHidden=true
        self.btnClearing.addTarget(self, action:#selector(toClearing), for: UIControlEvents.touchUpInside)

    }
    private func showClearCarRightBarButtonItem(){
        self.navigationItem.rightBarButtonItem=UIBarButtonItem.init(title:"清空", style: UIBarButtonItemStyle.done, target:self, action: #selector(clearCar))
    }
    private func hideClearCarRightBarButtonItem(){
        self.navigationItem.rightBarButtonItem=nil
    }
}
// MARK: - table协议
extension ShoppingCarViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"CarTableViewCellId") as? CarTableViewCell
        if cell == nil{
            cell=Bundle.main.loadNibNamed("CarTableViewCell", owner:self, options: nil)?.last as? CarTableViewCell
        }
        if arr.count > 0{
            let entity=arr[indexPath.row]
            cell!.updateCell(entity:entity)
            //检查图片状态
            switch (entity.state){
            case .new, .downloaded:
                //只有停止拖动的时候才加载
                if (!tableView.isDragging && !tableView.isDecelerating) {
                    self.startOperationsForMovieRecord(entity, indexPath: indexPath, completion:{
                        self.table.reloadRows(at:[indexPath], with: UITableViewRowAnimation.fade)
                    })
                }
            case .failed:
                NSLog("do nothing")
            }
            //增加商品数量
            cell!.addGoodCountClosure={
                let goodsCount=entity.goodsCount!+1
                self.changeCarNumForGoods(shoppingCarId:entity.shoppingCarId!, goodsCount:goodsCount,indexPath:indexPath, flag:1)
            }
            //减少商品数量
            cell!.reduceGoodCountClosure={
                if entity.goodsCount! > 1{
                    let goodsCount=entity.goodsCount!-1
                    self.changeCarNumForGoods(shoppingCarId:entity.shoppingCarId!, goodsCount:goodsCount,indexPath:indexPath, flag:2)
                }
            }
            //商品是否选中
            cell!.isSelectedGoodClosure={ (checkOrCance) in
                self.chooseCarGoods(shoppingCarId:entity.shoppingCarId!, checkOrCance: checkOrCance,row:indexPath.row)
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    //删除操作
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            self.removeGood(shoppingCarId:arr[indexPath.row].shoppingCarId!, indexPath:indexPath)
        }
    }
    //把delete 该成中文
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "删除"
    }
}
///优化图片加载
extension ShoppingCarViewController{
    //视图开始滚动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //一旦用户开始滚动屏幕，你将挂起所有任务并留意用户想要看哪些行。
        suspendAllOperations()
    }

    //视图停止拖动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        //如果减速（decelerate）是 false ，表示用户停止拖拽tableview。
        //此时你要继续执行之前挂起的任务，撤销不在屏幕中的cell的任务并开始在屏幕中的cell的任务。
        if !decelerate {
            resumeAllOperationsAndloadImagesForOnscreenCells(type:.tableView, scrollView: self.table, arr:arr)
        }
    }
    //视图停止减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //这个代理方法告诉你tableview停止滚动，执行操作同上
        resumeAllOperationsAndloadImagesForOnscreenCells(type:.tableView, scrollView: self.table, arr:arr)
    }
}
//点击事件
extension ShoppingCarViewController{
    //清空购物车
    @objc private func clearCar(){
        UIAlertController.showAlertYesNo(self, title:"", message:"确认清空所有商品吗?", cancelButtonTitle:"取消", okButtonTitle:"确认") { (action) in
            self.clearAllCar()
        }
    }
    //是否全选
    @objc private func isArrSelected(sender:UIButton){
        if sender.isSelected{//如果等于选中
            sender.isSelected=false
            self.checkOrCanceAllShoppingCarGoods(checkOrCance:2)
        }else{
            sender.isSelected=true
            self.checkOrCanceAllShoppingCarGoods(checkOrCance:1)
        }
    }
    //去结算
    @objc private func toClearing(){
        var goodArr=[GoodEntity]()
        var sumCount=0
        for (_,entity) in self.arr.enumerated().filter({ (_,entity) -> Bool in
             //查询选中商品
             return entity.checkOrCance == 1
        }){
            goodArr.append(entity)
            sumCount+=entity.goodsCount!
        }
        if goodArr.count == 0{
            self.showSVProgressHUD(status:"请选择下单商品", type: HUD.info)
            return
        }
        let vc=self.storyboardPushView(type:.shoppingCar, storyboardId:"OrderConfirmVC") as! OrderConfirmViewController
        vc.sumCount=sumCount
        vc.sumPrice=self.sumPrice
        vc.goodArr=goodArr
        vc.hidesBottomBarWhenPushed=true
        self.navigationController?.pushViewController(vc, animated:true)
    }
}
///网络请求
extension ShoppingCarViewController{
    ///清空购物车
    private func clearAllCar(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.clearCar(memberId:MEMBERID), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"清空成功", type: HUD.success)
                self.arr.removeAll()
                self.bottomView.isHidden=true
                self.hideClearCarRightBarButtonItem()
                self.table.reloadData()
                self.queryCarSumMoney()
            }else{
                self.showSVProgressHUD(status:"清空失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    //查询购物车商品
    private func getCarGoodList(pageSize:Int,pageNumber:Int){
        self.showSVProgressHUD(status:"正在加载中...", type:HUD.textClear)
        self.arr.removeAll()
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.getAllCarGood(memberId:MEMBERID,pageSize:pageSize,pageNumber:pageNumber), successClosure: { (json) in
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object: value.object)
                self.arr.append(entity!)
            }
            if self.arr.count == 0{
                self.bottomView.isHidden=true
                self.hideClearCarRightBarButtonItem()
            }else{
                self.bottomView.isHidden=false
                self.showClearCarRightBarButtonItem()
                if self.isAllSelected(){//判断是否全选
                    self.btnAllChecked.isSelected=true
                }else{
                    self.btnAllChecked.isSelected=false
                }
            }
            self.queryCarSumMoney()
            //显示空购物车提示信息
            self.setDisplay(isDisplay:true)
            self.table.reloadData()
            self.dismissHUD()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            //显示空购物车提示信息
            self.setDisplay(isDisplay:true)
        }
    }
    ///查询购物车总价格
    private func queryCarSumMoney(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.queryCarSumMoney(memberId:MEMBERID), successClosure: { (json) in
            self.sumPrice=json["sumPrice"].stringValue
            if Double(self.sumPrice)! >= Double(self.sendPrice){//判断是否大于起送金额
                self.btnClearing.enable() //可以点击
            }else{
                self.btnClearing.disable() //不可点击
            }
            self.lblSendPrice.text="\(self.sendPrice)元起送"
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
        //通知tab页面更新购物车角标
        NotificationCenter.default.post(name:updateCarBadgeValue,object:nil)
    }
    ///购物车是否全选 1. 全选，2 全不选
    private func checkOrCanceAllShoppingCarGoods(checkOrCance:Int){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target: CarApi.checkOrCanceAllShoppingCarGoods(memberId:MEMBERID, checkOrCance:checkOrCance), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{//成功
                for i in 0..<self.arr.count{
                    self.arr[i].checkOrCance=checkOrCance
                }
                self.table.reloadData()
                //重新计算价格
                self.queryCarSumMoney()
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    //选中或者取消某个商品 checkOrCance 1选中 2未选中
    private func chooseCarGoods(shoppingCarId:Int,checkOrCance:Int,row:Int){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target: CarApi.chooseCarGoods(shoppingCarId:shoppingCarId, checkOrCance: checkOrCance), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                //更新对应的数据源
                self.arr[row].checkOrCance=checkOrCance
                if self.isAllSelected(){//判断是否全选
                    self.btnAllChecked.isSelected=true
                }else{
                    self.btnAllChecked.isSelected=false
                }
                //重新计算价格
                self.queryCarSumMoney()
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    //修改商品数量  1增长 2减少
    private func changeCarNumForGoods(shoppingCarId:Int,goodsCount:Int,indexPath:IndexPath,flag:Int){
        self.showSVProgressHUD(status:"正在加载...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.changeCarNumForGoods(shoppingCarId:shoppingCarId, goodsCount:goodsCount), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.arr[indexPath.row].goodsCount=goodsCount
                self.table.reloadRows(at:[indexPath], with: UITableViewRowAnimation.fade)
                self.dismissHUD()
                //重新计算价格
                self.queryCarSumMoney()
            }else if success == "underStock"{
                self.showSVProgressHUD(status:"库存不足", type: HUD.error)
            }else{
                self.dismissHUD()
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    //删除购物车单个商品
    private func removeGood(shoppingCarId:Int,indexPath:IndexPath){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:CarApi.removeCar(shoppingCarId:shoppingCarId, memberId:MEMBERID), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                //获取对应cell
                let cell = self.table.cellForRow(at: indexPath) as? CarTableViewCell
                if cell != nil{
                    self.arr.remove(at:indexPath.row)
                    self.table!.deleteRows(at:[indexPath], with: UITableViewRowAnimation.fade)
                    if self.isAllSelected(){//判断是否全选
                        self.btnAllChecked.isSelected=true
                    }else{
                        self.btnAllChecked.isSelected=false
                    }
                    //重新计算价格
                    self.queryCarSumMoney()
                    if self.arr.count == 0{//删除完毕后刷新下table
                        self.bottomView.isHidden=true
                        self.hideClearCarRightBarButtonItem()
                        self.table.reloadData()
                    }
                }
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    //获取店铺信息
    private func getStoreInfo(){
        self.showSVProgressHUD(status:"正在加载...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreInfoApi.queryStoreById(bindstoreId:BINDSTOREID), successClosure: { (json) in
            let success=json["success"].stringValue
            self.dismissHUD()
            if success == "success"{
                let entity=self.jsonMappingEntity(entity:StoreEntity.init(), object:json["store"].object)
                if entity!.distributionStartTime != nil && entity!.distributionEndTime != nil{
                    let dateFormatter=DateFormatter()
                    dateFormatter.dateFormat="HH:mm:ss"
                    ///营业开始时间Date
                    let startTimeDate=dateFormatter.date(from:entity!.distributionStartTime!)

                    ///营业结束时间Date
                    let endTimeDate=dateFormatter.date(from:entity!.distributionEndTime!)

                    if startTimeDate != nil && endTimeDate != nil{//如果转换的开始结束时间都不为空
                        let calendar=Calendar.current

                        let components:Set<Calendar.Component>=[.year,.month, .day, .hour,.minute,.second]

                        var componentsCurrent=calendar.dateComponents(components, from:Date())
                        componentsCurrent.timeZone = TimeZone(abbreviation: "GMT")

                        var componentsStartTime = calendar.dateComponents(components, from:startTimeDate!)
                        componentsStartTime.timeZone = TimeZone(abbreviation: "GMT")
                        componentsStartTime.year=componentsCurrent.year
                        componentsStartTime.month=componentsCurrent.month
                        componentsStartTime.day=componentsCurrent.day


                        var componentsEndTime = calendar.dateComponents(components, from:endTimeDate!)
                        componentsEndTime.timeZone = TimeZone(abbreviation: "GMT")
                        componentsEndTime.year=componentsCurrent.year
                        componentsEndTime.month=componentsCurrent.month
                        componentsEndTime.day=componentsCurrent.day

                        let currentDate=calendar.date(from:componentsCurrent)
                        let startDate=calendar.date(from:componentsStartTime)
                        let endDate=calendar.date(from:componentsEndTime)

                        if startDate != nil && endDate != nil && currentDate != nil{
                            if currentDate!.compare(startDate!) == .orderedAscending || currentDate!.compare(endDate!) == .orderedDescending{ //当前时间小于店铺营业起始时间 大于店铺营业结束时间
                                UIAlertController.showAlertYes(self, title:"亲,已过营业时间", message:"本店营业时间为\(entity!.distributionStartTime!)-\(entity!.distributionEndTime!)", okButtonTitle:"知道了", okHandler: { (action) in
                                    self.navigationController?.popViewController(animated:true)
                                    app.tab.selectedIndex=0
                                })

                            }
                        }
                    }
                }
                ///把最低起送额保存
                userDefaults.set(entity?.lowestMoney, forKey:"lowestMoney")
                userDefaults.set(entity?.deliveryFee, forKey:"deliveryFee")
                userDefaults.set(entity?.storeName, forKey:"storeName")
                userDefaults.synchronize()
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    //是否全选 true是 false不是
    private func isAllSelected() -> Bool{
        if arr.count > 0{
            for i in 0..<arr.count{
                let entity=arr[i]
                if entity.checkOrCance == 2{//只要有一个商品没有选中 返回false
                    return false
                }
            }
        }
        return true
    }
}
