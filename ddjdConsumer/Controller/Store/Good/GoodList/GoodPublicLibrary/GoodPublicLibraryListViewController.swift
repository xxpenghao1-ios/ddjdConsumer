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
    ///搜索
    private var searchController:UISearchController!
    ///搜索商品名称
    private var goodsName:String?
    ///队列管理类，追踪每个操作的状态
    let movieOperations = MovieOperations()
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
        table.estimatedRowHeight=0;
        table.estimatedSectionHeaderHeight=0;
        table.estimatedSectionFooterHeight=0;
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        self.setLoadingState(isLoading:true)
        self.setEmptyDataSetInfo(text:"商品库中没有商品可以加入了")
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        
        returnImg.isUserInteractionEnabled=true
        returnImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(returnTop)))
        returnImg.isHidden=true
        
        btnAddStore.disable()
        btnAddStore.addTarget(self, action:#selector(allAddStore), for: UIControlEvents.touchUpInside)
        setUpPickerView()
        setUpTableheaderView()
    }
    ///设置table头部
    private func setUpTableheaderView(){
        //配置搜索控制器
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            //设置searchBar的代理
            controller.searchBar.delegate = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = true
            controller.searchBar.placeholder="按商品名称搜索"
            controller.searchBar.sizeToFit()
            controller.searchBar.searchBarStyle = .minimal
            controller.searchBar.autocorrectionType = .no
            self.table.tableHeaderView = controller.searchBar
            return controller
        })()
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
        self.table.scrollToRow(at:at, at: UITableViewScrollPosition.top, animated:true)
    }
    ///筛选分类
    @objc private func screening(sender:UIButton){
        sender.isSelected=true
        if sender.tag == 1{
            btnScreening.isSelected=false
            tCategoryId=nil
            goodsName=nil
            searchController.searchBar.text=nil
            btnScreening.setTitle("筛选", for: UIControlState.normal)
            table.mj_header.beginRefreshing()
        }else{
            goodsName=nil
            searchController.searchBar.text=nil
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
///搜索协议
extension GoodPublicLibraryListViewController:UISearchBarDelegate{
    //点击Cancel按钮
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text=nil
    }
    //点击搜索按钮
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil || searchBar.text!.count == 0{
            goodsName=searchBar.text!.check()
            if goodsName!.count == 0{
                self.showSVProgressHUD(status:"不能输入特殊字符", type: HUD.info)
                return
            }else{
                tCategoryId=nil
                btnScreening.setTitle("筛选", for: UIControlState.normal)
                self.table.mj_header.beginRefreshing()
            }
        }
        searchController.isActive=false
        searchBar.resignFirstResponder()
        searchBar.text=goodsName
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
        pickerMaskView=UIView(frame:self.view.bounds)
        pickerMaskView.backgroundColor = UIColor.init(white:0, alpha:0.5)
        pickerMaskView.isUserInteractionEnabled=true
        let gesture=UITapGestureRecognizer(target:self, action:#selector(hidePickerView))
        gesture.delegate=self
        pickerMaskView.addGestureRecognizer(gesture)
        self.view.addSubview(pickerMaskView)
        ///默认隐藏
        pickerMaskView.isHidden=true
        
        contentPickerView=UIView(frame: CGRect.init(x:0,y:pickerMaskView.frame.height-bottomSafetyDistanceHeight,width:boundsWidth, height:340))
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
            self.contentPickerView.frame=CGRect.init(x:0, y:self.pickerMaskView.frame.height-340-bottomSafetyDistanceHeight, width:boundsWidth,height:340)
        })
    }
    ///隐藏
    @objc private func hidePickerView(){
        UIView.animate(withDuration:0.5, delay:0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.contentPickerView.frame=CGRect.init(x:0, y:self.pickerMaskView.frame.height-bottomSafetyDistanceHeight,width:boundsWidth,height:340)
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
            //检查图片状态。设置适当的activity indicator 和文本，然后开始执行任务
            switch (entity.state){
            case .new, .downloaded:
                //只有停止拖动的时候才加载
                if (!tableView.isDragging && !tableView.isDecelerating) {
                    self.startOperationsForMovieRecord(entity, indexPath: indexPath)
                }
            case .failed:
                 NSLog("do nothing")
            }
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
    //图片任务
    func startOperationsForMovieRecord(_ entity: GoodEntity, indexPath: IndexPath){
        switch (entity.state) {
        case .new:
            startDownloadForRecord(entity, indexPath: indexPath)
        default:break
        }
    }
    //执行图片下载任务
    func startDownloadForRecord(_ entity:GoodEntity, indexPath: IndexPath){
        //判断队列中是否已有该图片任务
        if let _ = movieOperations.downloadsInProgress[indexPath] {
            return
        }

        //创建一个下载任务
        let downloader = ImageDownloader.init(entity:entity)
        //任务完成后重新加载对应的单元格
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async(execute: {
                self.movieOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.table.reloadRows(at: [indexPath], with:.none)
            })
        }
        //记录当前下载任务
        movieOperations.downloadsInProgress[indexPath] = downloader
        //将任务添加到队列中
        movieOperations.downloadQueue.addOperation(downloader)
    }
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
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    //视图停止减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //这个代理方法告诉你tableview停止滚动，执行操作同上
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }

    //暂停所有队列
    func suspendAllOperations () {
        movieOperations.downloadQueue.isSuspended = true
        movieOperations.filtrationQueue.isSuspended = true
    }

    //恢复运行所有队列
    func resumeAllOperations () {
        movieOperations.downloadQueue.isSuspended = false
        movieOperations.filtrationQueue.isSuspended = false
    }

    //加载可见区域的单元格图片
    func loadImagesForOnscreenCells () {
        //开始将tableview可见行的index path放入数组中。
        if let pathsArray = self.table.indexPathsForVisibleRows {
            //通过组合所有下载队列来创建一个包含所有等待任务的集合
            let allMovieOperations = NSMutableSet()
            for key in movieOperations.downloadsInProgress.keys{
                allMovieOperations.add(key)
            }

            //构建一个需要撤销的任务的集合。从所有任务中除掉可见行的index path，
            //剩下的就是屏幕外的行所代表的任务。
            let toBeCancelled = allMovieOperations.mutableCopy() as! NSMutableSet
            let visiblePaths = NSSet(array: pathsArray)
            toBeCancelled.minus(visiblePaths as Set<NSObject>)

            //创建一个需要执行的任务的集合。从所有可见index path的集合中除去那些已经在等待队列中的。
            let toBeStarted = visiblePaths.mutableCopy() as! NSMutableSet
            toBeStarted.minus(allMovieOperations as Set<NSObject>)

            // 遍历需要撤销的任务，撤消它们，然后从 movieOperations 中去掉它们
            for indexPath in toBeCancelled {
                let indexPath = indexPath as! IndexPath
                if let movieDownload = movieOperations.downloadsInProgress[indexPath] {
                    movieDownload.cancel()
                }
                movieOperations.downloadsInProgress.removeValue(forKey: indexPath)
            }

            // 遍历需要开始的任务，调用 startOperationsForPhotoRecord
            for indexPath in toBeStarted {
                let indexPath = indexPath as! IndexPath
                let entity = self.arr[indexPath.row]
                startOperationsForMovieRecord(entity, indexPath: indexPath)
            }
        }
    }
}
extension GoodPublicLibraryListViewController{
    //查询公共商品库
    private func queryStoreAndGoodsList(pageNumber:Int,pageSize:Int,isRefresh:Bool){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.queryGoodsInfoList_store(storeId:STOREID, pageNumber: pageNumber, pageSize: pageSize,goodsName:goodsName,tCategoryId:tCategoryId), successClosure: { (json) in
            
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
