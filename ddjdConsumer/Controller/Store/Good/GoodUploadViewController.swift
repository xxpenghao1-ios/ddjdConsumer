//
//  GoodUploadViewController.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/20.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
///商品上传
class GoodUploadViewController:FormViewController{
    struct Static {
        static let goodsCodeTag = "goodsCode"
        static let goodsNameTag = "goodsName"
        static let goodsUnitTag = "goodsUnit"
        static let goodUcodeTag = "goodUcode"
        static let goodsPriceTag = "goodsPrice"
        static let goodsLiftTag = "goodsLift"
        static let brandTag = "brand"
        static let goodsMixedTag = "goodsMixed"
        static let stockTag = "stock"
        static let goodsFlagTag = "goodsFlag"
        static let categoryTag = "category"
        static let picker = "picker"
        static let birthday = "birthday"
        static let categories = "categories"
        static let button = "button"
        static let stepper = "stepper"
        static let slider = "slider"
        static let textView = "textview"
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadForm()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
extension GoodUploadViewController{
    private func loadForm(){
        let form = FormDescriptor(title:"商品上传")
        let section1 = FormSectionDescriptor(headerTitle:"商品基本信息", footerTitle: nil)
        var row = FormRowDescriptor(tag: Static.goodsCodeTag, type: .text, title: "商品条形码")
        row.configuration.cell.appearance = ["textField.placeholder" : "请输入商品条形码" as AnyObject, "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.goodsNameTag, type: .text, title: "商品名称")
        row.configuration.cell.appearance = ["textField.placeholder" : "请输入商品名称" as AnyObject, "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.goodsUnitTag, type: .text, title: "商品单位")
        row.configuration.cell.appearance = ["textField.placeholder" : "例如:包,瓶,厅,把,千克等" as AnyObject, "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.goodUcodeTag, type: .text, title: "商品规格")
        row.configuration.cell.appearance = ["textField.placeholder" : "例如:1*500g,1*200ml等" as AnyObject, "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.goodsPriceTag, type: .decimal, title: "商品价格")
        row.configuration.cell.appearance = ["textField.placeholder" : "请输入商品价格" as AnyObject, "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section1.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.categoryTag, type: .label, title:"商品分类")
        row.configuration.cell.placeholder="请选择商品分类"
        row.configuration.button.didSelectClosure={ _ in
            
        }
        section1.rows.append(row)
        
        let section2 = FormSectionDescriptor(headerTitle:"商品其他信息", footerTitle: nil)
        
        row=FormRowDescriptor(tag: Static.goodsLiftTag, type: .number, title: "商品保质期")
        row.configuration.cell.appearance = ["textField.placeholder" : "请输入商品保质期(天)" as AnyObject, "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section2.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.stockTag, type: .number, title: "商品库存")
        row.configuration.cell.appearance = ["textField.placeholder" :"请输入商品库存" as AnyObject, "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section2.rows.append(row)
        
        row = FormRowDescriptor(tag: Static.goodsFlagTag, type: .segmentedControl, title: "商品状态")
        row.configuration.selection.options = ([1, 2] as [Int]) as [AnyObject]
        row.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? Int else { return "" }
            switch option {
            case 1:
                return "上架"
            case 2:
                return "下架"
            default:
                return ""
            }
        }
        row.configuration.cell.appearance = ["titleLabel.font" : UIFont.systemFont(ofSize: 14),"segmentedControl.tintColor":UIColor.applicationMainColor()]
        section2.rows.append(row)
        
        let section3 = FormSectionDescriptor(headerTitle:"商品选填信息", footerTitle: nil)
        
        row=FormRowDescriptor(tag:Static.brandTag, type: .text, title: "商品品牌")
        row.configuration.cell.appearance = ["textField.placeholder" :"请输入商品的品牌(选填)" as AnyObject, "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section3.rows.append(row)
        
        row=FormRowDescriptor(tag: Static.goodsMixedTag, type: .text, title: "商品配料")
        row.configuration.cell.appearance = ["textField.placeholder" :"请输入商品配料(选填)" as AnyObject, "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section3.rows.append(row)
        
        let section4 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        row = FormRowDescriptor(tag: Static.button, type: .button, title:"确定上传")
        row.configuration.button.didSelectClosure = { _ in
            let message = self.form.formValues().description
            
            let alertController = UIAlertController(title: "Form output", message: message, preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "OK", style: .cancel) { (action) in
            }
            
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)
        }
        section4.rows.append(row)
        form.sections = [section1,section2,section3,section4]
        self.form=form
    }
}
//// MARK: - 上传
//extension GoodUploadViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
//    @objc func choosePicture(){
//        //图片选择控制器
//        let imagePickerController=UIImagePickerController()
//        imagePickerController.delegate=self
//        // 设置是否可以管理已经存在的图片
//        imagePickerController.allowsEditing = true
//        // 判断是否支持相机
//        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
//            let alert:UIAlertController=UIAlertController(title:"修改个人图像", message:"您可以自己拍照或者从相册中选择", preferredStyle: UIAlertControllerStyle.actionSheet)
//            let photograph=UIAlertAction(title:"拍照", style: UIAlertActionStyle.default, handler:{
//                Void in
//                // 设置类型
//                imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
//                self.present(imagePickerController, animated: true, completion: nil)
//
//
//            })
//            let photoAlbum=UIAlertAction(title:"从相册选择", style: UIAlertActionStyle.default, handler:{
//                Void in
//                // 设置类型
//                imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
//                //改navigationBar背景色
//                imagePickerController.navigationBar.barTintColor = UIColor.applicationMainColor()
//                //改navigationBar标题色
//                imagePickerController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
//                //改navigationBar的button字体色
//                imagePickerController.navigationBar.tintColor = UIColor.white
//                self.present(imagePickerController, animated: true, completion: nil)
//            })
//            let cancel=UIAlertAction(title:"取消", style: UIAlertActionStyle.cancel, handler: nil)
//            alert.addAction(photograph)
//            alert.addAction(photoAlbum)
//            alert.addAction(cancel)
//            self.present(alert, animated:true, completion:nil)
//
//        }
//
//
//    }
//    //保存图片至沙盒
//    func saveImage(_ currentImage: UIImage, newSize: CGSize, percent: CGFloat, imageName: String){
//        //压缩图片尺寸
//        UIGraphicsBeginImageContext(newSize)
//        currentImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
//        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        //高保真压缩图片质量
//        //UIImageJPEGRepresentation此方法可将图片压缩，但是图片质量基本不变，第二个参数即图片质量参数。
//        let imageData: Data = UIImageJPEGRepresentation(newImage, percent)!
//        // 获取沙盒目录,这里将图片放在沙盒的documents文件夹中
//        let home=NSHomeDirectory() as NSString
//        let docPath=home.appendingPathComponent("Documents") as NSString
//        /// 3、获取文本文件路径
//        let filePath = docPath.appendingPathComponent(imageName)
//        // 将图片写入文件
//        try? imageData.write(to: Foundation.URL(fileURLWithPath: filePath), options: [])
//    }
//    //实现ImagePicker delegate 事件
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        picker.dismiss(animated: true, completion: nil)
//        var image: UIImage!
//        // 判断，图片是否允许修改
//        if(picker.allowsEditing){
//            //裁剪后图片
//            image = info[UIImagePickerControllerEditedImage] as! UIImage
//        }else{
//            //原始图片
//            image = info[UIImagePickerControllerOriginalImage] as! UIImage
//        }
//        // 保存图片至本地，方法见下文
//        self.saveImage(image, newSize: CGSize(width:boundsWidth, height:boundsWidth), percent:1, imageName: "currentImage.png")
//        // 获取沙盒目录,这里将图片放在沙盒的documents文件夹中
//        let home=NSHomeDirectory() as NSString
//        let docPath=home.appendingPathComponent("Documents") as NSString
//        /// 3、获取文本文件路径
//        let filePath = docPath.appendingPathComponent("currentImage.png")
//        //        let imageData = UIImagePNGRepresentation(savedImage);
//        self.showSVProgressHUD(status:"正在上传中...", type: HUD.textClear)
//        PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(target:StoreGoodApi.start(filePath:filePath), successClosure: { (json) in
//            print(json)
//            self.dismissHUD()
//        }) { (error) in
//            self.showSVProgressHUD(status:error!, type: HUD.error)
//        }
//    }
//    // 当用户取消时，调用该方法
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        self.dismiss(animated: true, completion: nil)
//    }
//}

