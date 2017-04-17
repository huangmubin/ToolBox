//
//  AlertAction.swift
//  Alert
//
//  Created by Myron on 2017/4/15.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class Alert {
    
    class func show(_ controller: UIViewController, title: String?, message: String, time: TimeInterval) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.present(alert, animated: true, completion: nil)
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: time)
            DispatchQueue.main.async {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    class func show(_ controller: UIViewController, title: String?, message: String, button: String?, action: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let info = UIAlertAction(title: button, style: .default, handler: action)
        alert.addAction(info)
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func show(_ controller: UIViewController, title: String?, message: String, sure: String?, sureAction: ((UIAlertAction) -> Void)?, cancel: String?, cancelAction: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let sInfo = UIAlertAction(title: sure, style: .default, handler: sureAction)
        alert.addAction(sInfo)
        
        let cInfo = UIAlertAction(title: cancel, style: .cancel, handler: cancelAction)
        alert.addAction(cInfo)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func push(_ controller: UIViewController, item: UIView?, title: String?, message: String, actions: [(String, UIAlertActionStyle, ((UIAlertAction) -> Void)?)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.modalPresentationStyle = .popover
        for action in actions {
            let info = UIAlertAction(title: action.0, style: action.1, handler: action.2)
            alert.addAction(info)
        }
        if let view = item {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        controller.present(alert, animated: true, completion: nil)
    }
    
}
