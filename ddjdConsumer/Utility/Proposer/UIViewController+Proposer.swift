//
//  UIViewController+Proposer.swift
//  Lady
//
//  Created by NIX on 15/7/11.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import UIKit
extension PrivateResource {
    var proposeMessage: String {
        switch self {
        case .photos:
            return NSLocalizedString("申请人需要访问您的照片来选择照片。", comment: "")
        case .camera:
            return NSLocalizedString("申请人需要进入你的相机拍照。", comment: "")
        case .microphone:
            return NSLocalizedString("申请人需要使用你的麦克风录音。", comment: "")
        case .contacts:
            return NSLocalizedString("申请人需要访问你的联系人以匹配朋友。", comment: "")
        case .reminders:
            return NSLocalizedString("申请人需要访问你的提醒来创建提醒。", comment: "")
        case .calendar:
            return NSLocalizedString("申请人需要访问你的日程表来创建事件。", comment: "")
        case .location:
            return NSLocalizedString("申请人需要使用你的位置", comment: "")
        case .notifications:
            return NSLocalizedString("申请人想要发送通知", comment: "")
        case .cameraCode:
            return NSLocalizedString("申请人需要进入你的相机进行条形码扫描", comment: "")
        }
    }

    var noPermissionMessage: String {
        switch self {
        case .photos:
            return NSLocalizedString("请在设置中开启访问照片权限", comment: "")
        case .camera,.cameraCode:
            return NSLocalizedString("请在设置中开启使用相机权限", comment: "")
        case .microphone:
            return NSLocalizedString("请在设置中开启使用麦克风权限", comment: "")
        case .contacts:
            return NSLocalizedString("请在设置中开启使用麦克风权限", comment: "")
        case .reminders:
            return NSLocalizedString("请在设置中开启使用你的提醒权限", comment: "")
        case .calendar:
            return NSLocalizedString("请在设置中开启访问你的日历权限", comment: "")
        case .location:
            return NSLocalizedString("请在设置中开启定位权限", comment: "")
        case .notifications:
            return NSLocalizedString("请在设置中开启通知权限", comment: "")
        }
    }
}

extension UIViewController {

    private func showDialogWithTitle(_ title: String, message: String, cancelTitle: String, confirmTitle: String, withCancelAction cancelAction : (() -> Void)?, confirmAction: (() -> Void)?) {

        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                cancelAction?()
            }
            alertController.addAction(cancelAction)

            let confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
                confirmAction?()
            }
            alertController.addAction(confirmAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }

    func showProposeMessageIfNeedFor(_ resource: PrivateResource, andTryPropose propose: @escaping Propose) {

        if resource.isNotDeterminedAuthorization {
            showDialogWithTitle(NSLocalizedString("请注意", comment: ""), message: resource.proposeMessage, cancelTitle: NSLocalizedString("取消", comment: ""), confirmTitle: NSLocalizedString("确定", comment: ""), withCancelAction: nil, confirmAction: {
                propose()
            })

        } else {
            propose()
        }
    }

    func alertNoPermissionToAccess(_ resource: PrivateResource) {

        showDialogWithTitle(NSLocalizedString("对不起", comment: ""), message: resource.noPermissionMessage, cancelTitle: NSLocalizedString("关闭", comment: ""), confirmTitle: NSLocalizedString("去设置", comment: ""), withCancelAction: nil, confirmAction: {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
    }
}
