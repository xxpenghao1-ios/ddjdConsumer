//
//  OrderStatisticsTextViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/15.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///订单文字统计
class OrderStatisticsTextViewController:BaseViewController{
    ///历史订单总金额
    var orderSumPrice:String?
    ///table topview
    @IBOutlet weak var orderTopView: UIView!
    ///本月订单笔数
    @IBOutlet weak var lblOrderCount: UILabel!
    ///本月订单总金额
    @IBOutlet weak var lblMonthOrderPrice: UILabel!
    ///历史总营业额
    @IBOutlet weak var lblOrderSumPrice: UILabel!
    
    @IBOutlet weak var table: UITableView!
    ///遮罩层
    private var pickerMaskView:UIView!
    ///日期选选择
    private var pickerDateView:HooDatePicker!
    
    private var arr=[OrderStatisticsEntity]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        queryStoreOrderCountForMonth(date:self.title!)
    }
}
extension OrderStatisticsTextViewController{
    private func setUpView(){
        setUpNavTitle(date:Date())
        ///历史订单总额
        lblOrderSumPrice.text=orderSumPrice
        table.dataSource=self
        table.delegate=self
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        self.setEmptyDataSetInfo(text:"当月还没有订单")
        table.tableFooterView=UIView(frame: CGRect.zero)
        table.separatorInset=UIEdgeInsets.zero
        
        ///时间选择
        pickerDateView=HooDatePicker.init(datePickerMode: HooDatePickerMode.yearAndMonth, andAddToSuperView:self.view)
        pickerDateView.setHighlight(UIColor.applicationMainColor())
        pickerDateView.locale = Locale.init(identifier:"zh_CN")
        // 设置样式，当前设为显示日期
        pickerDateView.setDate(Date(), animated:true)
        pickerDateView.delegate=self
        let filterItem=UIBarButtonItem.init(title:"筛选", style: UIBarButtonItemStyle.done, target:self, action:#selector(filterDate))
        self.navigationItem.rightBarButtonItems=[filterItem]
    }
    ///设置导航title
    private func setUpNavTitle(date:Date){
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM"
        let strNowTime = timeFormatter.string(from:date)
        self.title=strNowTime
    }
    ///筛选时间
    @objc private func filterDate(){
        showPickerDateView()
    }
    ///显示时间选择
    private func showPickerDateView(){
        pickerDateView.show()
    }
    ///隐藏
    @objc private func hidePickerDateView(){
        pickerDateView.dismiss()
    }
}
///
extension OrderStatisticsTextViewController:HooDatePickerDelegate{
    func datePicker(_ dataPicker: HooDatePicker!, didSelectedDate date: Date!) {
        setUpNavTitle(date:date)
        queryStoreOrderCountForMonth(date:self.title!)
    }
}
// MARK: - table
extension OrderStatisticsTextViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"orderid") as? OrderStatisticsTableViewCell
        if cell == nil{
            cell=getXibClass(name:"OrderStatisticsTableViewCell", owner:self) as? OrderStatisticsTableViewCell
        }
        if arr.count > 0{
            cell!.updateCell(entity:arr[indexPath.row])
        }
        return cell!
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

///网络请求
extension OrderStatisticsTextViewController{
    private func queryStoreOrderCountForMonth(date:String){
        self.arr.removeAll()
        self.showSVProgressHUD(status:"正在加载中...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreOrderApi.queryStoreOrderCountForMonth(storeId:STOREID,date:date), successClosure: { (json) in
            self.lblOrderCount.text=json["monthOrderCount"].int?.description
            self.lblMonthOrderPrice.text=json["monthOrderSumPrice"].double?.description
            for(_,value) in json["monthOrderList"]{
                let entity=self.jsonMappingEntity(entity:OrderStatisticsEntity(), object: value.object)
                self.arr.append(entity!)
            }
            self.dismissHUD()
            self.table.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
