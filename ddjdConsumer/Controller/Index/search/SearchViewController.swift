//
//  SearchViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/10/31.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
/// 搜索页面
class SearchViewController:BaseViewController{
    //如果有值 表示从商品列表跳转过来的
    var flag:Int?
    ///搜索结果
    var searchNameClosure:((_ searchName:String) -> Void)?
    
    private var collectionView:UICollectionView!
    //搜索框
    private var txtSearch:UITextField!
    //历史搜索
    private var arr=[String]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //取出缓存中的搜索记录
        arr=userDefaults.object(forKey: "searchStrArr") as? [String] ?? [String]()
        if collectionView != nil{
            updateCollectionView()
        }
        self.reinstateNavColor()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
        setUpNav()
    }
    ///刷新视图
    private func updateCollectionView(){
        //一定要显式在主线程调用刷新 不然会有cell不显示情况stackoverflow上很多人说这是UICollectionView的一个bug  目前没有好的解决方案
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
    }
}

// MARK: - 页面设置
extension SearchViewController{
    ///设置页面
    private func setUpView(){
        let flowLayout = UICollectionViewFlowLayout()
        //给默认宽高 基于自动布局有效
        flowLayout.estimatedItemSize=CGSize(width:60, height:35)
//        flowLayout.itemSize=CGSize(width:60, height:35)
        flowLayout.minimumLineSpacing = 5;//每个相邻layout的上下
        flowLayout.minimumInteritemSpacing = 5;//每个相邻layout的左右
        flowLayout.sectionInset=UIEdgeInsets(top:0,left:5,bottom:15, right:5)
        collectionView=UICollectionView(frame:self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.emptyDataSetSource=self
        collectionView.emptyDataSetDelegate=self
        collectionView.delegate=self
        collectionView.dataSource=self
        collectionView.backgroundColor=UIColor.clear
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier:"SearchCollectionViewCellId")
        self.view.addSubview(collectionView)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier:"HeaderView")
        self.setEmptyDataSetInfo(text:"还木有搜索记录")
        updateCollectionView()
    }
    ///设置导航栏
    private func setUpNav(){
        //直接创建一个文本框
        txtSearch=UITextField(frame:CGRect(x:0,y:0, width:boundsWidth-100, height:30))
        txtSearch.backgroundColor=UIColor.RGBFromHexColor(hexString:"f0f2f5")
        txtSearch.placeholder="请输入您要搜索的商品"
        txtSearch.font=UIFont.systemFont(ofSize: 14)
        txtSearch.tintColor=UIColor.color666()
        txtSearch.delegate=self
        txtSearch.returnKeyType = .search
        txtSearch.clearButtonMode = .whileEditing
        txtSearch.resignFirstResponder()
        txtSearch.layer.cornerRadius=15
        //左边搜索图片
        let leftView=UIView(frame:CGRect(x:0,y:0, width:30, height:30))
        let leftImageView=UIImageView(frame:CGRect(x:10,y:8.5,width:13.5,height:13))
        leftImageView.image=UIImage(named:"search")
        leftView.addSubview(leftImageView)
        txtSearch.leftView=leftView
        txtSearch.leftViewMode=UITextFieldViewMode.always
        //右边扫码图片
        let rightView=UIView(frame:CGRect(x:0,y:0, width:35, height:30))
        let rightImgView=UIImageView(frame:CGRect(x:0,y:2.5, width:25, height:25))
        rightImgView.isUserInteractionEnabled=true
        rightImgView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(pushSweepCodeVC)))
        rightImgView.image=UIImage(named:"sweep_code")
        rightView.addSubview(rightImgView)
        txtSearch.rightView=rightView
        txtSearch.rightViewMode=UITextFieldViewMode.always
        let searchTxtItem=UIBarButtonItem(customView:txtSearch)
        //搜索按钮
        let searchBtn=UIButton.button(type: .button, text:"搜索", textColor: UIColor.color666(), font:15, backgroundColor:UIColor.clear, cornerRadius:nil)
        searchBtn.frame=CGRect(x:0, y:0, width:40, height:30)
        searchBtn.addTarget(self, action:#selector(searchGood), for: UIControlEvents.touchUpInside)
        let searchBtnItem=UIBarButtonItem(customView:searchBtn)
        self.navigationItem.rightBarButtonItems=[searchBtnItem,searchTxtItem]
        if flag != nil{
            self.navigationItem.leftBarButtonItem=UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target:self, action:#selector(cancel))
        }
    }
}

// MARK: - UICollectionView协议
extension SearchViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"SearchCollectionViewCellId", for:indexPath) as! SearchCollectionViewCell
        if indexPath.section == 0{
            if arr.count > 0{
                if indexPath.row == arr.count{
                    cell.updateCell(str: "清除历史")
                }else{
                    cell.updateCell(str:arr[indexPath.row])
                }
                cell.contentView.isHidden=false
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arr.count > 0{//如果有历史搜索记录 数组加1 方便加一个清除全部按钮
            return arr.count+1
        }else{
            return 0
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == arr.count{
                removeSearchRecords()
            }else{
                //跳转到商品列表
                self.pushGoodListVC(str:arr[indexPath.row])
            }
        }
    }
    //设置头部底部视图
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView:UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader{
            reusableView=collectionView.dequeueReusableSupplementaryView(ofKind:kind, withReuseIdentifier:"HeaderView", for: indexPath)
            //设置tag防止重复添加
            var lblTitle=reusableView.viewWithTag(11) as? UILabel
            if lblTitle == nil{
                lblTitle=UILabel.buildLabel(textColor: UIColor.black, font:15, textAlignment: NSTextAlignment.left)
                lblTitle?.tag=11
                lblTitle?.frame=CGRect(x:15, y:15, width:200, height:20)
                reusableView.addSubview(lblTitle!)
            }
            lblTitle?.text="热门搜索"
            
        }
        return reusableView
    }
    //返回每组头部高度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
            if arr.count > 0{
                return CGSize(width:boundsWidth,height:50)
            }
        }
        return CGSize(width:0,height:0)
    }
}
// MARK: - 页面点击事件
extension SearchViewController:UITextFieldDelegate{
    ///跳转到扫码页面
    @objc private func pushSweepCodeVC(){
        let camera: PrivateResource = .camera
        let propose: Propose = {
            proposeToAccess(camera, agreed: {
                let vc=ScanCodeGetBarcodeViewController()
                vc.codeInfoClosure={ (str) in
                    self.queryGoodsByGoodsCode(goodsCode:str ?? "")
                }
                self.navigationController?.pushViewController(vc, animated:true)
            }, rejected: {
                self.alertNoPermissionToAccess(camera)
            })
        }
        showProposeMessageIfNeedFor(camera, andTryPropose: propose)
    }
    //搜索商品
    @objc private func searchGood() {
        //保存搜索记录arr
        var searchArr:[String]?;
        if  txtSearch.text != nil && txtSearch.text!.count > 0{//判断搜索条件是否为空
            if txtSearch.text!.check().count == 0{
                self.showSVProgressHUD(status:"亲不能输入表情等特殊字符", type: HUD.info)
                return
            }else{
                //先从缓存取出arr
                searchArr=userDefaults.object(forKey: "searchStrArr") as? [String];
                if searchArr == nil{//如果为空 直接实例化个空的数组
                    searchArr=[String]();
                }
                //把搜索条件添加到可变数组里面
                searchArr!.append(txtSearch.text!.check())
                //数组去重
                searchArr=searchArr?.filterDuplicates({$0})
                //保存进缓存
                userDefaults.set(searchArr, forKey:"searchStrArr")
                //写入磁盘
                userDefaults.synchronize();
                //跳转到商品列表
                self.pushGoodListVC(str:txtSearch.text!.check())
                txtSearch.text=nil
            }
        }else{
            self.showSVProgressHUD(status: "搜索条件不能为空", type: HUD.info)
            return
        }
    }
    //点击键盘搜索按钮
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchGood()
        return true
    }
    /**
     清除历史记录
     */
    @objc private func removeSearchRecords(){
        
        //先清除缓存中的数据
        userDefaults.removeObject(forKey: "searchStrArr");
        
        //写入磁盘
        userDefaults.synchronize();
        
        //直接赋空
        arr=[String]();
        
        updateCollectionView()
        
    }
    //跳转到商品列表页面
    private func pushGoodListVC(str:String){
        txtSearch.resignFirstResponder()
        //跳转到商品列表
        let vc=GoodListViewController()
        vc.name=str
        if flag == nil{
            self.navigationController?.pushViewController(vc, animated:true);
        }else{//关闭页面
            self.searchNameClosure?(str)
            cancel()
        }
    }
    //关闭页面
    @objc private func cancel(){
        self.dismiss(animated: true, completion:nil)
    }
    //点击view隐藏键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - 网络请求
extension SearchViewController{

    /// 通过商品条码查询商品id
    ///
    /// - Parameter goodsCode: 条形码
    private func queryGoodsByGoodsCode(goodsCode:String){
        self.showSVProgressHUD(status:"正在加载...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:GoodApi.queryStoreAndGoodsByGoodsCode(goodsCode:goodsCode,bindstoreId:BINDSTOREID), successClosure: { (json) in
            let success=json["success"].stringValue
            
            if success == "success"{
                let storeAndGoodsId=json["storeAndGoodsId"].intValue
                let vc=self.storyboardPushView(type: .index, storyboardId:"GoodDetailsVC") as! GoodDetailsViewController
                vc.storeAndGoodsId=storeAndGoodsId
                self.navigationController?.pushViewController(vc, animated:true)
            }else{
                self.showSVProgressHUD(status:"没有找到该条码", type: HUD.error)
            }
            self.dismissHUD()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
}
