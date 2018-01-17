//
//  FeedbackViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/2.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import TZImagePickerController
///意见反馈
class FeedbackViewController:BaseViewController{
    //意见输入框
    @IBOutlet weak var txtStr: UITextView!
    //图片集合
    @IBOutlet weak var imgCollection: UICollectionView!
    //滑动容器
    @IBOutlet weak var scrollView: UIScrollView!
    ///4个按钮view
    @IBOutlet weak var btnSumsView: UIView!
    //图片集合高度
    @IBOutlet weak var imgCollectionHeight: NSLayoutConstraint!
    //提交按钮
    @IBOutlet weak var btnSubmit: UIButton!
    //功能建议
    @IBOutlet weak var btnGNjy: UIButton!
    //购买问题
    @IBOutlet weak var btnGMwt: UIButton!
    //商品问题
    @IBOutlet weak var btnGoodWt: UIButton!
    //其他
    @IBOutlet weak var btnOthers: UIButton!
    //图片数组
    private var imgArr=[UIImage]()
    //问题类型
    private var questionsOrSuggestionsType:Int?
    
    private var selectedAssets=NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="意见反馈"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        setUpView()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
///设置页面
extension FeedbackViewController{
    private func setUpView(){
        txtStr.placeholder="请在此描述您遇到的问题或建议（必填）"
        txtStr.layer.borderColor=UIColor.borderColor().cgColor
        txtStr.layer.borderWidth=1
        
        btnGNjy.layer.borderWidth=1
        btnGNjy.layer.borderColor=UIColor.applicationMainColor().cgColor
        btnGNjy.addTarget(self, action:#selector(selectedBtn),for: UIControlEvents.touchUpInside)
        btnGNjy.tag=1
        
        btnGMwt.layer.borderWidth=1
        btnGMwt.layer.borderColor=UIColor.applicationMainColor().cgColor
        btnGMwt.addTarget(self, action:#selector(selectedBtn),for: UIControlEvents.touchUpInside)
        btnGMwt.tag=2
        
        btnGoodWt.layer.borderWidth=1
        btnGoodWt.layer.borderColor=UIColor.applicationMainColor().cgColor
        btnGoodWt.addTarget(self, action:#selector(selectedBtn),for: UIControlEvents.touchUpInside)
        btnGoodWt.tag=3
        
        btnOthers.layer.borderWidth=1
        btnOthers.layer.borderColor=UIColor.applicationMainColor().cgColor
        btnOthers.addTarget(self, action:#selector(selectedBtn),for: UIControlEvents.touchUpInside)
        btnOthers.tag=4
        
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize=CGSize(width:(boundsWidth-70)/4, height:(boundsWidth-70)/4)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset=UIEdgeInsets.init(top:0,left:0,bottom:0,right:10)
        imgCollection.collectionViewLayout = flowLayout
        imgCollection.delegate=self
        imgCollection.dataSource=self
        imgCollection.isScrollEnabled=false
        imgCollection.register(UINib(nibName:"FeedbackCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"FeedbackCollectionViewCellId")
        imgCollectionHeight.constant=(boundsWidth-60)/4
        
        btnSubmit.addTarget(self, action:#selector(submit), for: UIControlEvents.touchUpInside)
    }
    @objc private func selectedBtn(sender:UIButton){
        for(view) in self.btnSumsView.subviews{
            if view is UIButton{
                let btn=view as! UIButton
                btn.backgroundColor=UIColor.white
                btn.setTitleColor(UIColor.applicationMainColor(), for: UIControlState.normal)
            }
        }
        sender.backgroundColor=UIColor.applicationMainColor()
        sender.setTitleColor(UIColor.white,for:UIControlState.normal)
        questionsOrSuggestionsType=sender.tag
    }
    @objc private func submit(){
        
        let str=txtStr.text
        if str == nil || str!.count == 0{
            self.showSVProgressHUD(status:"问题与描述不能为空", type: HUD.info)
            return
        }
        if questionsOrSuggestionsType == nil {
            self.showSVProgressHUD(status:"请选择问题类别", type: HUD.info)
            return
        }
        self.showSVProgressHUD(status:"正在提交...", type: HUD.textClear)
        var questionsOrSuggestionsPic=""
        if imgArr.count > 0{//如果有值
            let group=DispatchGroup()
            /// 创建一个并行队列(传入 DISPATCH_QUEUE_SERIAL 或 NIL 表示创建串行队列。传入 DISPATCH_QUEUE_CONCURRENT 表示创建并行队列.)
            let queue = DispatchQueue(label: "com.gcd-group.www",attributes: DispatchQueue.Attributes.concurrent);
            for i in 0..<imgArr.count{
                ///进入组
                group.enter()
                queue.async(group:group,execute:{
                    // 保存图片至本地
                    let filePath=UIImage.saveImage(self.imgArr[i], newSize: CGSize(width:boundsWidth, height:boundsHeight), percent:1)
                    PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.start(filePath:filePath, pathName:"returnMsg"), successClosure: { (json) in
                        let success=json["success"].stringValue
                        if success == "success"{
                            let path=json["path"].stringValue
                            questionsOrSuggestionsPic+=path+","
                        }
                        //离开组
                        group.leave()
                    }, failClosure: { (error) in
                        self.showSVProgressHUD(status:error!, type: HUD.error)
                        //离开组
                        group.leave()
                        return
                    })
                })
            }
            ///执行完毕
            group.notify(queue:queue, execute: {
                let index=questionsOrSuggestionsPic.index(questionsOrSuggestionsPic.endIndex, offsetBy: -1)
                questionsOrSuggestionsPic=String(questionsOrSuggestionsPic[..<index])
                self.save(questionsOrSuggestionsPic:questionsOrSuggestionsPic, str: str!)
            })
        }else{
            self.save(questionsOrSuggestionsPic:questionsOrSuggestionsPic, str: str!)
        }
    }
    private func save(questionsOrSuggestionsPic:String,str:String){
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:MyApi.saveQuestionsorsuggestions(memberId:MEMBERID, questionsOrSuggestionsType:self.questionsOrSuggestionsType ?? 0, questionsOrSuggestionsText:str,questionsOrSuggestionsPic:questionsOrSuggestionsPic), successClosure: { (json) in
            let success=json["success"].stringValue
            if success == "success"{
                self.showSVProgressHUD(status:"提交成功,我们会尽快核实", type: HUD.success)
                self.navigationController?.popViewController(animated:true)
            }else{
                self.showSVProgressHUD(status:"提交失败", type: HUD.error)
            }
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
        //删除本地图片
        deleteUploadImgFile()
    }
}
extension FeedbackViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"FeedbackCollectionViewCellId", for: indexPath) as! FeedbackCollectionViewCell
        if indexPath.item == imgArr.count{
            cell.delImg.isHidden=true
            cell.img.image=UIImage.init(named:"AlbumAddBtn")
        }else{
            cell.img.image=imgArr[indexPath.item]
            cell.delImg.isHidden=false
            cell.delImg.tag=indexPath.item
            cell.delImg.addTarget(self, action:#selector(delImage), for: UIControlEvents.touchUpInside)
        }
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr.count+1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == imgArr.count{//选择照片
            selectImg()
        }else{//预览照片
            previewImg(index:indexPath.item)
        }
    }
}
extension FeedbackViewController:TZImagePickerControllerDelegate{
    @objc private func delImage(sender:UIButton){
        self.imgArr.remove(at:sender.tag)
        self.selectedAssets.removeObject(at:sender.tag)
        imgCollection.performBatchUpdates({
            imgCollection.deleteItems(at:[IndexPath.init(row:sender.tag, section:0)])
        }) { (b) in
            self.imgCollection.reloadData()
        }
    }
    ///选择照片
    func selectImg(){
        let vc=TZImagePickerController.init(maxImagesCount:4, columnNumber:4, delegate:self,pushPhotoPickerVc:true)
        //隐藏原图按钮
        vc?.allowPickingOriginalPhoto=false
        //用户不能选择视频
        vc?.allowPickingVideo=false
        //设置目前已经选中的图片数组
        if self.selectedAssets.count > 0{
            vc?.selectedAssets=self.selectedAssets
        }
    }
    //预览照片
    func previewImg(index:Int){
       let vc=TZImagePickerController.init(selectedAssets:NSMutableArray.init(array:self.selectedAssets), selectedPhotos: NSMutableArray.init(array:self.imgArr),index: index)
        vc!.maxImagesCount=4
        //隐藏原图按钮
        vc?.allowPickingOriginalPhoto=false
        //用户不能选择视频
        vc?.allowPickingVideo=false
        vc?.didFinishPickingPhotosHandle={ (photos,assets,isSelectOriginalPhoto) in
            self.imgArr=photos!
            self.selectedAssets=NSMutableArray.init(array:assets!)
            self.imgCollection.reloadData()
        }
        self.present(vc!, animated:true, completion:nil)
    }
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        self.imgArr=photos
        self.selectedAssets=NSMutableArray.init(array:assets!)
        self.imgCollection.reloadData()
    }
    //显示相册
    func isAlbumCanSelect(_ albumName: String!, result: Any!) -> Bool {
        return true
    }
}

