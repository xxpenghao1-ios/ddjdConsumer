//
//  ToExamineGoodListViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/17.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///审核商品列表
class ToExamineGoodListViewController:BaseViewController{
    var examineGoodsFlag:Int? //1. 审核中 2. 审核失败 3 审核成功
    ///table
    @IBOutlet weak var table: UITableView!
    ///返回顶部
    @IBOutlet weak var returnImg: UIImageView!
    ///数据源
    private var arr=[GoodEntity]()

    private var pageNumber=1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="审核"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        self.queryExamineGoodsByStoreId(pageNumber:self.pageNumber, pageSize:10,isRefresh:true)
        table.mj_header=PHNormalHeader(refreshingBlock: {
            self.pageNumber=1
            self.queryExamineGoodsByStoreId(pageNumber:self.pageNumber, pageSize:10,isRefresh:true)
        })
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.queryExamineGoodsByStoreId(pageNumber:self.pageNumber, pageSize:10,isRefresh:false)
        })
        table.mj_footer.isHidden=true
        ///接收通知刷新页面
        NotificationCenter.default.addObserver(self,selector:#selector(updateList), name:notificationNameUpdateStoreGoodList, object:nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    ///刷新数据
    @objc private func updateList(not:Notification){
        self.table.mj_header.beginRefreshing()
    }
}
// MARK: - 滑动协议
extension ToExamineGoodListViewController{
    //监听滑动事件
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 600{//滑动600距离显示返回顶部按钮
            returnImg.isHidden=false
        }else{
            returnImg.isHidden=true
        }
    }
}

// MARK: - 设置页面
extension ToExamineGoodListViewController{
    private func setUpView(){
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        table.dataSource=self
        table.delegate=self
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        table.estimatedRowHeight=0;
        table.estimatedSectionHeaderHeight=0;
        table.estimatedSectionFooterHeight=0;
        self.setEmptyDataSetInfo(text:"暂无审核信息")
        self.setLoadingState(isLoading:true)

        returnImg.isUserInteractionEnabled=true
        returnImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(returnTop)))
        returnImg.isHidden=true
    }
    ///返回顶部
    @objc private func returnTop(){
        let at=IndexPath(item:0, section:0)
        self.table.scrollToRow(at:at, at: UITableViewScrollPosition.bottom, animated:true)
    }
    ///刷新table
    private func reloadTable(){
        self.setLoadingState(isLoading:false)
        self.table.reloadData()
        self.table.mj_footer.endRefreshing()
        self.table.mj_header.endRefreshing()
    }
}
///网络请求
extension ToExamineGoodListViewController{
    private func queryExamineGoodsByStoreId(pageNumber:Int,pageSize:Int,isRefresh:Bool){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.queryExamineGoodsByStoreId(parameters:["examineGoodsFlag":examineGoodsFlag ?? 0,"storeId":STOREID,"pageNumber":pageNumber,"pageSize":pageSize]), successClosure: { (json) in
            
            if isRefresh{
                self.arr.removeAll()
            }
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:GoodEntity.init(), object:value.object)
                self.arr.append(entity!)
            }
            if self.arr.count < json["totalRow"].intValue{
                self.table.mj_footer.isHidden=false
            }else{
                self.table.mj_footer.isHidden=true
            }
            self.showBaseVCGoodCountPromptView(currentCount:self.arr.count, totalCount:json["totalRow"].intValue)
            self.reloadTable()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.reloadTable()
        }
    }
}
///table协议
extension ToExamineGoodListViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=tableView.dequeueReusableCell(withIdentifier:"storeToExamineGoodListId") as? ToExamineGoodTableViewCell
        if cell == nil{
            cell=getXibClass(name:"ToExamineGoodTableViewCell", owner:self) as? ToExamineGoodTableViewCell
        }
        if arr.count > 0{
            let entity=arr[indexPath.row]
            cell!.updateCell(entity:entity)
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
        let entity=arr[indexPath.row]
        if entity.examineGoodsFlag == 2{
            let vc=self.storyboardPushView(type:.storeGood, storyboardId:"UpdateToExamineGoodDetailsVC") as! UpdateToExamineGoodDetailsViewController
            vc.goodEntity=entity
            self.navigationController?.pushViewController(vc, animated:true)
        }
        
    }
}
///优化图片加载
extension ToExamineGoodListViewController{
    
}
