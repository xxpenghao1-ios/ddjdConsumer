//
//  FormTextFieldCell.swift
//  SwiftForms
//
//  Created by Miguel Ángel Ortuño Ortuño on 20/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

open class FormTextFieldCell: FormBaseCell {
    
    // MARK: Cell views
    
    public  let titleLabel = UILabel()
    @objc public  let textField  = UITextField()
    
    // MARK: Properties
    
    fileprivate var customConstraints: [AnyObject] = []
    
    // MARK: FormBaseCell
    
    open override func configure() {
        super.configure()
        
        selectionStyle = .none
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.systemFont(ofSize:14)
        titleLabel.textColor=UIColor.color333()
        textField.font = UIFont.systemFont(ofSize:14)
        textField.delegate=self
        textField.textAlignment = .left
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        
        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        textField.addTarget(self, action: #selector(FormTextFieldCell.editingChanged(_:)), for: .editingChanged)
    }
    
    open override func update() {
        super.update()
        
        if let showsInputToolbar = rowDescriptor?.configuration.cell.showsInputToolbar , showsInputToolbar && textField.inputAccessoryView == nil {
            textField.inputAccessoryView = inputAccesoryView()
        }
        
        titleLabel.text = rowDescriptor?.title
        textField.text = rowDescriptor?.value as? String
        textField.placeholder = rowDescriptor?.configuration.cell.placeholder
        textField.isSecureTextEntry = false
        textField.clearButtonMode = .whileEditing
        
        if let type = rowDescriptor?.type {
            switch type {
            case .text:
                textField.autocorrectionType = .default
                textField.autocapitalizationType = .sentences
                textField.keyboardType = .default
            case .number:
                textField.keyboardType = .numberPad
            case .numbersAndPunctuation:
                textField.keyboardType = .numbersAndPunctuation
            case .decimal:
                textField.keyboardType = .decimalPad
            case .name:
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .words
                textField.keyboardType = .default
            case .phone:
                textField.keyboardType = .phonePad
            case .namePhone:
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .words
                textField.keyboardType = .namePhonePad
            case .url:
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
                textField.keyboardType = .URL
            case .twitter:
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
                textField.keyboardType = .twitter
            case .email:
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
                textField.keyboardType = .emailAddress
            case .asciiCapable:
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
                textField.keyboardType = .asciiCapable
            case .password:
                textField.isSecureTextEntry = true
                textField.clearsOnBeginEditing = false
            default:
                break
        }
        }
    }
    
    open override func constraintsViews() -> [String : UIView] {
        var views = ["titleLabel" : titleLabel, "textField" : textField]
        if self.imageView!.image != nil {
            views["imageView"] = imageView
        }
        return views
    }
    
    open override func defaultVisualConstraints() -> [String] {
        if self.imageView!.image != nil {
            if titleLabel.text != nil && (titleLabel.text!).count > 0 {
                return ["H:[imageView]-[titleLabel]-[textField]-16-|"]
            } else {
                return ["H:[imageView]-[textField]-16-|"]
            }
        } else {
            if titleLabel.text != nil && (titleLabel.text!).count > 0 {
                return ["H:|-16-[titleLabel]-[textField]-16-|"]
            } else {
                return ["H:|-16-[textField]-16-|"]
            }
        }
    }
    
    open override func firstResponderElement() -> UIResponder? {
        return textField
    }
    
    open override class func formRowCanBecomeFirstResponder() -> Bool {
        return true
    }
    
    // MARK: Actions
    
    @objc func editingChanged(_ sender: UITextField) {
        guard let text = sender.text, text.count > 0 else { rowDescriptor?.value = nil; update(); return }
        rowDescriptor?.value = text as AnyObject
    }
}
extension FormTextFieldCell:UITextFieldDelegate{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if rowDescriptor?.type == .decimal{
            if range.length == 1{//按键是x执行
                return true
            }
            if textField.text != nil && textField.text!.count > 0{//如果不为空
                let strs=textField.text!.components(separatedBy:".")
                if strs.count > 1{//如果分割的字符串数组大于1表示有.
                    if string.contains("."){ //如果小数点后面还包含小数返回false
                        return false
                    }
                    if strs[1].count >= 2{//如果小数点超过2位
                        if range.location == textField.text!.count{//光标位置在最后
                            return false
                        }
                    }
                }else{//如果没有点
                    if range.location < textField.text!.count{//光标位值小于字符长度
                        if string.contains("."){//如果是点
                            if textField.text!.count > 2{//如果输入框的字符串大于2位
                                return false
                            }else{//如果小于等于2位
                                if range.location == 0{//如果光标位置是第一为
                                    textField.text="0."+textField.text!
                                    return false
                                }
                            }
                        }
                    }
                }
            }else{//如果输入框为空
                if string.count == 1{//如果第一位是小数点 默认给0.
                    if string.contains("."){
                        textField.text="0"
                    }
                }
            }
        }
        return true
    }
}
