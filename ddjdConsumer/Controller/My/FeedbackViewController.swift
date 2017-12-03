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
        
        btnGMwt.layer.borderWidth=1
        btnGMwt.layer.borderColor=UIColor.applicationMainColor().cgColor
        
        btnGoodWt.layer.borderWidth=1
        btnGoodWt.layer.borderColor=UIColor.applicationMainColor().cgColor
        
        btnOthers.layer.borderWidth=1
        btnOthers.layer.borderColor=UIColor.applicationMainColor().cgColor
        
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
        //        vc?.showSelectBtn = false;
        //        //允许图片剪裁
        //        vc?.allowCrop = true;
        //        //允许圆形剪裁
        ////        vc?.needCircleCrop = true
        //        // 设置竖屏下的裁剪尺寸
        //        let widthHeight = self.view.tz_width - 2 * 30;
        //        let top = (self.view.tz_height - widthHeight) / 2;
        //        vc!.cropRect = CGRect.init(x:30, y:top, width: widthHeight, height: widthHeight)
        self.present(vc!, animated:true, completion:nil)
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

