//
//  Image.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/11/18.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
extension UIImage{
    /**
     *  重设图片大小
     */
    func reSizeImage(reSize:CGSize)->UIImage {
        
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    // 通过"UIColor"返回一张“UIImage”
    class func imageFromColor(_ color: UIColor) -> UIImage {
        //创建1像素区域并开始图片绘图
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        
        //创建画板并填充颜色和区域
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        //从画板上获取图片并关闭图片绘图
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    //保存图片至沙盒
    class func saveImage(_ currentImage: UIImage, newSize: CGSize, percent: CGFloat) -> String{
        //压缩图片尺寸
        UIGraphicsBeginImageContext(newSize)
        currentImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //高保真压缩图片质量
        //UIImageJPEGRepresentation此方法可将图片压缩，但是图片质量基本不变，第二个参数即图片质量参数。
        let imageData: Data = UIImageJPEGRepresentation(newImage, percent)!
        // 获取沙盒目录
        let myDirectory = NSHomeDirectory() + "/Documents/myImgages"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath:myDirectory){//如果不存在创建
            try? fileManager.createDirectory(atPath:myDirectory, withIntermediateDirectories: true, attributes:nil)
        }
        /// 3、获取文本文件路径
        let docPath=myDirectory as NSString
        let filePath = docPath.appendingPathComponent("\(Int(arc4random()))\(Int(arc4random())).png")
        // 将图片写入文件
        try? imageData.write(to: Foundation.URL(fileURLWithPath: filePath), options: [])
        let enumeratorAtPath = fileManager.enumerator(atPath:myDirectory)
        print("enumeratorAtPath: \(enumeratorAtPath?.allObjects)")
        return filePath
    }
}
