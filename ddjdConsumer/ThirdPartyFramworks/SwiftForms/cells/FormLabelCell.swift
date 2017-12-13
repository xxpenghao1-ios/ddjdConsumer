//
//  FormTextFieldCell.swift
//  SwiftForms
//
//  Created by Miguel Ángel Ortuño Ortuño on 20/08/14.
//  Copyright (c) 2016 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

open class FormLabelCell: FormValueCell {
    
    /// MARK: FormBaseCell
    
    override open func configure() {
        super.configure()
        accessoryType = .none
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.systemFont(ofSize:14)
        titleLabel.textColor=UIColor.color333()
        valueLabel.font = UIFont.systemFont(ofSize:14)
        valueLabel.textAlignment = .left
        valueLabel.textColor = UIColor.lightGray
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        // apply constant constraints
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    override open func update() {
        super.update()
        titleLabel.text = rowDescriptor?.title
        if rowDescriptor?.value as? String != nil{
            valueLabel.text=rowDescriptor?.value as? String
            valueLabel.textColor=UIColor.color666()
        }else{
            valueLabel.text = rowDescriptor?.configuration.cell.placeholder
        }
        if rowDescriptor?.tag == "category"{
            accessoryType = .disclosureIndicator
            valueLabel.textColor=UIColor.color333()
        }
    }
}
