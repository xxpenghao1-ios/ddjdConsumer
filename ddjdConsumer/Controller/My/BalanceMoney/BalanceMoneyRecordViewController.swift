//
//  BalanceMoneyRecordViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2018/1/4.
//  Copyright © 2018年 zltx. All rights reserved.
//

import Foundation
///余额明细
class BalanceMoneyRecordViewController:BaseViewController{
    var partnerStatu:Int?  ///‘是否为店铺合伙人；默认1不是；2是’,
    @IBOutlet weak var table: UITableView!
    ///余额
    @IBOutlet weak var lblBlanceMoney: UILabel!
    //马上提现
    @IBOutlet weak var btnMSTX: UIButton!
    private var arr=[BalanceRecordEntity]()

    private var pageNumber=1

    private var flag=false
    ///筛选条件arr
    private var memberBalanceRecordTypeArr=["余额充值","余额返还","订单扣除","提现扣除","全部"]
    private var memberBalanceRecordType:Int?
    ///筛选table
    private var screeningTable:UITableView!
    private var screeningView:UIView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavColor()
        queryMemberBalanceMoney()
        if flag{
            self.pageNumber=1
            self.arr.removeAll()
            self.queryMemberBalanceRecord(pageNumber:self.pageNumber, pageSize:10, memberBalanceRecordType: memberBalanceRecordType)
        }
        flag=true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.reinstateNavColor()
        if self.screeningView.isHidden == false{
            hideScreeningTableView()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="余额明细"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        self.queryMemberBalanceRecord(pageNumber:self.pageNumber, pageSize:10, memberBalanceRecordType: memberBalanceRecordType)
        table.mj_footer=PHNormalFooter(refreshingBlock: {
            self.pageNumber+=1
            self.queryMemberBalanceRecord(pageNumber:self.pageNumber, pageSize:10, memberBalanceRecordType: self.memberBalanceRecordType)
        })
        table.mj_header=PHNormalHeader(refreshingBlock: {
            self.arr.removeAll()
            self.pageNumber=1
            self.queryMemberBalanceRecord(pageNumber:self.pageNumber, pageSize:10, memberBalanceRecordType: self.memberBalanceRecordType)
        })
        table.mj_footer.isHidden=true
        self.navigationItem.rightBarButtonItem=UIBarButtonItem.init(title:"筛选", style: UIBarButtonItemStyle.done, target:self,action:#selector(showScreeningTable))
    }
    //跳转到充值页面
    @IBAction func pushTopUp(_ sender: UIButton) {
        let vc=self.storyboardPushView(type:.my, storyboardId:"BalanceMoneyTopUpVC") as! BalanceMoneyTopUpViewController
        self.navigationController?.pushViewController(vc, animated:true)
    }
    //跳转到提现页面
    @IBAction func pushWithdrawal(_ sender: UIButton) {
        if partnerStatu == 2{
            self.showSVProgressHUD(status:"合伙人不能提现", type: HUD.info)
            return
        }
        let vc=self.storyboardPushView(type:.my, storyboardId:"BalanceMoneyWithdrawalVC") as! BalanceMoneyWithdrawalViewController
        self.navigationController?.pushViewController(vc,animated:true)
    }
}
///页面设置
extension BalanceMoneyRecordViewController{

    private func setUpView(){
        table.dataSource=self
        table.delegate=self
        table.emptyDataSetSource=self
        table.emptyDataSetDelegate=self
        table.tableFooterView=UIView.init(frame: CGRect.zero)
        self.setEmptyDataSetInfo(text:"您暂时还没有相关余额明细哦")
        self.setLoadingState(isLoading:true)
        setUpScreeningTableView()
    }
    private func reloadData(){
        self.setLoadingState(isLoading:false)
        self.table.mj_footer.endRefreshing()
        self.table.mj_header.endRefreshing()
        self.table.reloadData()
    }
    ///设置筛选table
    private func setUpScreeningTableView(){
        screeningView=UIView(frame:CGRect.init(x:0,y:0,width:boundsWidth, height:boundsHeight))
        screeningView.backgroundColor = UIColor.init(white:0, alpha:0.5)
        screeningView.isUserInteractionEnabled=true
        let gesture=UITapGestureRecognizer(target:self, action:#selector(hideScreeningTableView))
        gesture.delegate=self
        screeningView.addGestureRecognizer(gesture)
        self.view.addSubview(screeningView)
        screeningTable=UITableView(frame:CGRect.init(x:0,y:-(self.memberBalanceRecordTypeArr.count*50),width:Int(boundsWidth), height:self.memberBalanceRecordTypeArr.count*50),style:UITableViewStyle.plain)
        screeningTable.delegate=self
        screeningTable.dataSource=self
        screeningTable.tag=100
        screeningTable.isScrollEnabled=false
        screeningView.addSubview(screeningTable)
        screeningView.isHidden=true
    }
    @objc private func showScreeningTable(){
        if self.screeningView.isHidden == true{
            showScreeningTableView()
        }else{
            hideScreeningTableView()
        }
    }
    ///显示筛选view
    private func showScreeningTableView(){
        self.screeningView.isHidden=false
        UIView.animate(withDuration:0.3, delay:0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.screeningTable.frame=CGRect.init(x:0,y:0, width:Int(boundsWidth),height:self.memberBalanceRecordTypeArr.count*50)
        })
    }
    ///隐藏筛选view
    @objc private func hideScreeningTableView(){
        UIView.animate(withDuration:0.3, delay:0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.screeningTable.frame=CGRect.init(x:0, y:-self.memberBalanceRecordTypeArr.count*50,width:Int(boundsWidth),height:self.memberBalanceRecordTypeArr.count*50)
            
        }, completion:{ (b) in
                self.screeningView.isHidden=true
            })
    }
}
///监听view点击事件
extension BalanceMoneyRecordViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if NSStringFromClass((touch.view?.classForCoder)!) == "UITableViewCellContentView"{
            return false
        }
        if touch.view != screeningView{
            return false
        }
        return true
    }
}
// MARK: - table协议
extension BalanceMoneyRecordViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 100{
            var cell=tableView.dequeueReusableCell(withIdentifier:"id")
            if cell == nil{
                cell=UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier:"id")
            }
            cell!.accessoryType = .disclosureIndicator
            cell!.textLabel!.font=UIFont.systemFont(ofSize:14)
            cell!.textLabel!.text=memberBalanceRecordTypeArr[indexPath.row]
            return cell!
        }
        var cell=table.dequeueReusableCell(withIdentifier:"bmId") as? BalanceMoneyRecordTableViewCell
        if cell == nil{
            cell=getXibClass(name:"BalanceMoneyRecordTableViewCell", owner:self) as? BalanceMoneyRecordTableViewCell
        }
        if arr.count > 0{
            cell!.updateCell(entity:arr[indexPath.row])
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 100{
            return 50
        }
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 100{
            return memberBalanceRecordTypeArr.count
        }
        return arr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中效果颜色
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.tag == 100{
            if indexPath.row == 4{//全部
                self.memberBalanceRecordType=nil
            }else{
                self.memberBalanceRecordType=indexPath.row+1
            }
            self.table.mj_header.beginRefreshing()
            self.hideScreeningTableView()
        }
    }
}
// MARK: - 网络请求
extension BalanceMoneyRecordViewController{
    ///获取余额记录
    private func queryMemberBalanceRecord(pageNumber:Int,pageSize:Int,memberBalanceRecordType:Int?){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryMemberBalanceRecord(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description, dicAny:["pageNumber":pageNumber,"pageSize":pageSize,"memberBalanceRecordType":memberBalanceRecordType ?? ""])), successClosure: { (json) in
            print(json)
            for(_,value) in json["list"]{
                let entity=self.jsonMappingEntity(entity:BalanceRecordEntity.init(), object:value.object)
                self.arr.append(entity!)
            }
            if self.arr.count < json["totalRow"].intValue{
                self.table.mj_footer.isHidden=false
            }else{
                self.table.mj_footer.isHidden=true
            }
            self.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.reloadData()
        }
    }
    ///获取用户余额
    private func queryMemberBalanceMoney(){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.queryMemberBalanceMoney(parameters:DDJDCSign.shared.getRequestParameters(timestamp:Int(Date().timeIntervalSince1970*1000).description)), successClosure: { (json) in
            print(json)
            let success=json["success"].stringValue
            if success == "success"{
                self.lblBlanceMoney.text=json["memberBalanceMoney"].doubleValue.description
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
