//
//  GoodUploadImgTableViewCell.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/12/6.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation

///商品上传图片
class GoodUploadImgTableViewCell:FormBaseCell{
    public let scanCodeImg = UIImageView()
    override func configure() {
        super.configure()
        selectionStyle = .none
    
        scanCodeImg.image=UIImage.init(named:"AlbumAddBtn")
        scanCodeImg.isUserInteractionEnabled=true
        scanCodeImg.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(showImageSelected)))
        contentView.addSubview(scanCodeImg)
        
        scanCodeImg.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.width.height.equalTo(70)
            make.top.equalTo(15)
        }
    }
    //每次需要更新单元格是都会调用
    override func update() {
        super.update()
        if rowDescriptor?.value as? UIImage != nil{
            scanCodeImg.image=rowDescriptor!.value as? UIImage
        }
        if rowDescriptor?.value as? String != nil{
            let imgPic=rowDescriptor?.value as! String;
            scanCodeImg.kf.setImage(with:URL(string:urlImg+imgPic), placeholder:UIImage(named:goodDefaultImg))
            rowDescriptor?.value=scanCodeImg.image
        }
    }
    @objc private func showImageSelected(){
        let _ = rowDescriptor?.configuration.selection.optionTitleClosure?("img" as AnyObject)
    }
}
