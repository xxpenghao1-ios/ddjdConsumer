//
//  GoodsClassificationViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/12.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
//商品分类
class GoodsClassificationViewController:BaseViewController{
    //一级分类
    @IBOutlet weak var table: UITableView!
    //23级分类
    @IBOutlet weak var collection: UICollectionView!
    //数据源
    private var arr=[GoodscategoryEntity]()
    //23级数据源
    private var collectionArr=[GoodscategoryEntity]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if arr.count == 0{//如果没有数据加载数据
            getGoodsCateGoryList()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.white
        setUpView()
    }
}

// MARK: - 设置页面
extension GoodsClassificationViewController{
    private func setUpView(){
        setUpNav()
        setUpTableView()
        setUpCollectionView()
    }
    //设置导航栏
    private func setUpNav(){
        //直接创建一个文本框
        let txt=UITextField(frame:CGRect(x:0,y:0, width:boundsWidth-70, height:30))
        txt.backgroundColor=UIColor.RGBFromHexColor(hexString:"f0f2f5")
        txt.delegate=self
        txt.placeholder="请输入您要搜索的商品"
        txt.font=UIFont.systemFont(ofSize: 14)
        txt.tintColor=UIColor.clear
        txt.resignFirstResponder()
        txt.layer.cornerRadius=15
        let leftView=UIView(frame:CGRect(x:0,y:0, width:30, height:30))
        let leftImageView=UIImageView(frame:CGRect(x:10,y:8.5,width:13.5,height:13))
        leftImageView.image=UIImage(named:"search")
        leftView.addSubview(leftImageView)
        txt.leftView=leftView
        txt.leftViewMode=UITextFieldViewMode.always
        self.navigationItem.titleView=txt
    }
    //设置table
    private func setUpTableView(){
        table.tableFooterView=UIView(frame:CGRect.zero)
        table.dataSource=self
        table.delegate=self
        table.backgroundColor=UIColor.viewBackgroundColor()
        table.separatorInset=UIEdgeInsets.zero
//        self.table.separatorStyle = .none
    }
    //设置collection
    private func setUpCollectionView(){
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize=CGSize(width:(boundsWidth-100)/3, height:(boundsWidth-100)/3)
        flowLayout.minimumLineSpacing = 5;//每个相邻layout的上下
        flowLayout.minimumInteritemSpacing = 0;//每个相邻layout的左右
        collection.collectionViewLayout = flowLayout
        collection.dataSource=self
        collection.delegate=self
        collection.emptyDataSetSource=self
        collection.emptyDataSetDelegate=self
        collection.register(UINib(nibName: "GoodClassifyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"GoodClassifyCollectionViewCellId")
        collection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier:"HeaderView")
        //设置空视图提示文字
        self.setLoadingState(isLoading:true)
        self.setEmptyDataSetInfo(text:"还木有相关分类")
    }
}
//网络请求
extension GoodsClassificationViewController{
    func getGoodsCateGoryList(){
        self.arr.removeAll()
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:GoodsClassifiationApi.queryGoodsCateGoryList(), successClosure: { (json) in
            for(_,value) in json{
                var arr2=[GoodscategoryEntity]()
                let entity=self.jsonMappingEntity(entity:GoodscategoryEntity.init(), object: value.object)
                for(_,value2) in value["list"]{
                    var arr3=[GoodscategoryEntity]()
                    let entity2=self.jsonMappingEntity(entity:GoodscategoryEntity.init(), object: value2.object)
                    for(_,value3) in value2["list"]{
                        let entity3=self.jsonMappingEntity(entity:GoodscategoryEntity.init(), object: value3.object)
                        arr3.append(entity3!)
                    }
                    entity2!.arr2=arr3
                    arr2.append(entity2!)
                }
                entity!.arr2=arr2
                self.arr.append(entity!)
            }
            self.table.reloadData()
            if self.arr.count > 0{//默认展示第一行数据
                self.collectionArr=self.arr[0].arr2 ?? [GoodscategoryEntity]()
                //默认选中第一行
                self.table.selectRow(at:IndexPath(row:0, section:0), animated:true, scrollPosition: UITableViewScrollPosition.none)
                
            }
            self.setLoadingState(isLoading:false)
            self.collection.reloadData()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
            self.setLoadingState(isLoading:false)
            self.collection.reloadData()
        }
    }
}
// MARK: - 跳转到搜索页面
extension GoodsClassificationViewController:UITextFieldDelegate{
    //实现导航控制器文本框的协议
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //点击文本框不让键盘弹出来
        textField.resignFirstResponder()
        let vc=SearchViewController()
        vc.hidesBottomBarWhenPushed=true;
        self.navigationController?.pushViewController(vc, animated:true);
    }
}
// MARK: - table协议
extension GoodsClassificationViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=table.dequeueReusableCell(withIdentifier:"GoodClassifyTableViewCellId") as? GoodClassifyTableViewCell
        if cell == nil{
            cell=Bundle.main.loadNibNamed("GoodClassifyTableViewCell", owner:self, options: nil)?.last as? GoodClassifyTableViewCell
        }
//        if indexPath.row % 2 == 0{
//            cell!.backgroundColor=UIColor.white
//        }else{
//            cell!.backgroundColor=UIColor.viewBackgroundColor()
//        }
        if arr.count > 0{
            cell!.updateCell(entity: arr[indexPath.row])
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity=arr[indexPath.row]
        //获取对应2级分类 如果没有给空数组
        collectionArr=entity.arr2 ?? [GoodscategoryEntity]()
        self.collection.reloadData()
    }
}
// MARK: - UICollectionView实现
extension GoodsClassificationViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"GoodClassifyCollectionViewCellId", for: indexPath) as! GoodClassifyCollectionViewCell
        if collectionArr.count > 0{
            if collectionArr[indexPath.section].arr2 != nil{
              let entity=collectionArr[indexPath.section].arr2![indexPath.item]
                cell.updateCell(entity:entity)
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionArr.count > 0{
            if collectionArr[section].arr2 != nil{
                return collectionArr[section].arr2!.count
            }
        }
        return 0
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionArr.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let entity=collectionArr[indexPath.section].arr2![indexPath.item]
        let vc=GoodListViewController()
        vc.hidesBottomBarWhenPushed=true
        vc.tCategoryId=entity.goodsCategoryId
        vc.name=entity.goodsCategoryName
        self.navigationController?.pushViewController(vc, animated:true)
    }
    //设置头部底部视图
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView:UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader{
            reusableView=collectionView.dequeueReusableSupplementaryView(ofKind:kind, withReuseIdentifier:"HeaderView",for: indexPath)
            var borderView=reusableView.viewWithTag(11)
            if borderView == nil{
                borderView=UIView()
                borderView!.backgroundColor=UIColor.RGBFromHexColor(hexString:"e6e7e8")
                borderView!.tag=11
                reusableView.addSubview(borderView!)
            }
            var lblTitle=reusableView.viewWithTag(22) as? UILabel
            if lblTitle == nil{
                lblTitle=UILabel.buildLabel(textColor: UIColor.RGBFromHexColor(hexString: "3f3c3c"), font:15, textAlignment: NSTextAlignment.center)
                lblTitle!.backgroundColor=UIColor.white
                lblTitle!.tag=22
                reusableView.addSubview(lblTitle!)
            }
            if collectionArr.count > 0{
                lblTitle!.text=collectionArr[indexPath.section].goodsCategoryName
                let size=lblTitle!.text!.textSizeWithFont(font:lblTitle!.font, constrainedToSize: CGSize(width:200, height:20))
                lblTitle!.frame=CGRect(x:(collection.frame.width-size.width-20)/2, y:15, width:size.width+20, height:20)
                borderView!.frame=CGRect(x:(collection.frame.width-(size.width+80))/2, y:24.5,width:size.width+80,height:1)
            }
        }
        return reusableView
    }
    //返回每组头部高度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width:boundsWidth,height:50)
    }
}
