//
//  GoodUploadViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/20.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///商品上传
class GoodUploadViewController:BaseViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="商品上传"
        self.view.backgroundColor=UIColor.viewBackgroundColor()
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target:self, action: #selector(choosePicture))
    }
}
// MARK: - 上传
extension GoodUploadViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @objc func choosePicture(){
        //图片选择控制器
        let imagePickerController=UIImagePickerController()
        imagePickerController.delegate=self
        // 设置是否可以管理已经存在的图片
        imagePickerController.allowsEditing = true
        // 判断是否支持相机
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            let alert:UIAlertController=UIAlertController(title:"修改个人图像", message:"您可以自己拍照或者从相册中选择", preferredStyle: UIAlertControllerStyle.actionSheet)
            let photograph=UIAlertAction(title:"拍照", style: UIAlertActionStyle.default, handler:{
                Void in
                // 设置类型
                imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
                self.present(imagePickerController, animated: true, completion: nil)
                
                
            })
            let photoAlbum=UIAlertAction(title:"从相册选择", style: UIAlertActionStyle.default, handler:{
                Void in
                // 设置类型
                imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
                //改navigationBar背景色
                imagePickerController.navigationBar.barTintColor = UIColor.applicationMainColor()
                //改navigationBar标题色
                imagePickerController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
                //改navigationBar的button字体色
                imagePickerController.navigationBar.tintColor = UIColor.white
                self.present(imagePickerController, animated: true, completion: nil)
            })
            let cancel=UIAlertAction(title:"取消", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(photograph)
            alert.addAction(photoAlbum)
            alert.addAction(cancel)
            self.present(alert, animated:true, completion:nil)
            
        }
        
        
    }
    //保存图片至沙盒
    func saveImage(_ currentImage: UIImage, newSize: CGSize, percent: CGFloat, imageName: String){
        //压缩图片尺寸
        UIGraphicsBeginImageContext(newSize)
        currentImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //高保真压缩图片质量
        //UIImageJPEGRepresentation此方法可将图片压缩，但是图片质量基本不变，第二个参数即图片质量参数。
        let imageData: Data = UIImageJPEGRepresentation(newImage, percent)!
        // 获取沙盒目录,这里将图片放在沙盒的documents文件夹中
        let home=NSHomeDirectory() as NSString
        let docPath=home.appendingPathComponent("Documents") as NSString
        /// 3、获取文本文件路径
        let filePath = docPath.appendingPathComponent(imageName)
        // 将图片写入文件
        try? imageData.write(to: Foundation.URL(fileURLWithPath: filePath), options: [])
    }
    //实现ImagePicker delegate 事件
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        var image: UIImage!
        // 判断，图片是否允许修改
        if(picker.allowsEditing){
            //裁剪后图片
            image = info[UIImagePickerControllerEditedImage] as! UIImage
        }else{
            //原始图片
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        // 保存图片至本地，方法见下文
        self.saveImage(image, newSize: CGSize(width:boundsWidth, height:boundsWidth), percent:1, imageName: "currentImage.png")
        // 获取沙盒目录,这里将图片放在沙盒的documents文件夹中
        let home=NSHomeDirectory() as NSString
        let docPath=home.appendingPathComponent("Documents") as NSString
        /// 3、获取文本文件路径
        let filePath = docPath.appendingPathComponent("currentImage.png")
        //        let imageData = UIImagePNGRepresentation(savedImage);
        self.showSVProgressHUD(status:"正在上传中...", type: HUD.textClear)
        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.start(filePath:filePath), successClosure: { (json) in
            print(json)
            self.dismissHUD()
        }) { (error) in
            self.showSVProgressHUD(status:error!, type: HUD.error)
        }
    }
    // 当用户取消时，调用该方法
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
