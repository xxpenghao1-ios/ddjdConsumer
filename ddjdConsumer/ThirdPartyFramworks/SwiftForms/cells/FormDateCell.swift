//
//  FormDateCell.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 22/08/14.
//  Copyright (c) 2016 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

open class FormDateCell: FormValueCell {
    
    // MARK: Properties
    
    private let datePicker = UIDatePicker()
    private let hiddenTextField = UITextField(frame: CGRect.zero)
    
    private let defaultDateFormatter = DateFormatter()

    ///是否返回Date数据 //默认不
    private var isRetunrDate=false
    // MARK: FormBaseCell
    
    open override func configure() {
        super.configure()
        contentView.addSubview(hiddenTextField)
        hiddenTextField.inputView = datePicker
        hiddenTextField.isAccessibilityElement = false
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(FormDateCell.valueChanged(_:)), for: .valueChanged)
        titleLabel.font=UIFont.systemFont(ofSize:14)
        valueLabel.font=UIFont.systemFont(ofSize:14)
    }
    
    open override func update() {
        super.update()
        
        if let showsInputToolbar = rowDescriptor?.configuration.cell.showsInputToolbar , showsInputToolbar && hiddenTextField.inputAccessoryView == nil {
            hiddenTextField.inputAccessoryView = inputAccesoryView()
        }
        
        titleLabel.text = rowDescriptor?.title
        
        if let rowType = rowDescriptor?.type {
            switch rowType {
            case .date:
                datePicker.datePickerMode = .date
                defaultDateFormatter.dateStyle = .long
                defaultDateFormatter.timeStyle = .none
            case .time:
                datePicker.datePickerMode = .time
                defaultDateFormatter.dateStyle = .none
                defaultDateFormatter.timeStyle = .short
            default:
                datePicker.datePickerMode = .dateAndTime
                defaultDateFormatter.dateStyle = .long
                defaultDateFormatter.timeStyle = .short
                isRetunrDate=true
            }
        }
        
        if let date = rowDescriptor?.value as? Date {
            datePicker.date=date
            valueLabel.text = getDateFormatter().string(from: date)
            if titleLabel.text == "开始营业时间" || titleLabel.text == "结束营业时间"{
                rowDescriptor?.value=valueLabel.text as AnyObject
            }
        }
    }
    
    open override class func formViewController(_ formViewController: FormViewController, didSelectRow selectedRow: FormBaseCell) {
        guard let row = selectedRow as? FormDateCell else { return }
        
        if row.rowDescriptor?.value == nil {
            let date = Date()
            row.rowDescriptor?.value = date as AnyObject
            row.valueLabel.text = row.getDateFormatter().string(from: date)
            row.update()
        }
        
        row.hiddenTextField.becomeFirstResponder()
    }
    
    open override func firstResponderElement() -> UIResponder? {
        return hiddenTextField
    }
    
    open override class func formRowCanBecomeFirstResponder() -> Bool {
        return true
    }
    
    // MARK: Actions
    
    @objc internal func valueChanged(_ sender: UIDatePicker) {
        if isRetunrDate{
            rowDescriptor?.value = sender.date as AnyObject
        }else{
            rowDescriptor?.value = getDateFormatter().string(from: sender.date) as AnyObject
        }
        valueLabel.text = getDateFormatter().string(from: sender.date)
        update()
    }
    
    // MARK: Private interface
    
    fileprivate func getDateFormatter() -> DateFormatter {
        guard let dateFormatter = rowDescriptor?.configuration.date.dateFormatter else { return defaultDateFormatter }
        return dateFormatter
    }
}
