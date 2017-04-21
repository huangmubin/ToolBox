//
//  AlertAction.swift
//  Alert
//
//  Created by Myron on 2017/4/15.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - Alert Tools

class Alert {
    
    let alert: UIAlertController
    
    deinit {
        print("Alert \(self) is deinit")
    }
    
    // MARK: Init
    
    init(title: String? = nil, message: String? = nil, style: UIAlertControllerStyle = UIAlertControllerStyle.alert) {
        alert = UIAlertController(title: title, message: message, preferredStyle: style)
    }
    
    func show(_ controller: UIViewController, time: TimeInterval = 0) {
        if let textFields = alert.textFields {
            for text in textFields {
                text.text = nil
            }
        }
        controller.present(alert, animated: true, completion: {
            if time > 0 {
                DispatchQueue.global().async {
                    Thread.sleep(forTimeInterval: time)
                    DispatchQueue.main.async {
                        self.alert.dismiss(animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    // MARK: Info
    
    func title(_ value: String) -> Alert {
        alert.title = value
        return self
    }
    
    func message(_ value: String) -> Alert {
        alert.message = value
        return self
    }
    
    // MARK: Action
    
    @discardableResult
    func action(title: String? = NSLocalizedString("Sure", comment: "Sure"), handler: ((UIAlertAction) -> Void)?) -> Alert {
        let action = UIAlertAction(title: title, style: .default, handler: handler)
        alert.addAction(action)
        return self
    }
    
    @discardableResult
    func cancel(title: String? = NSLocalizedString("Cancel", comment: "Cancel"), handler: ((UIAlertAction) -> Void)?) -> Alert {
        let action = UIAlertAction(title: title, style: .cancel, handler: handler)
        alert.addAction(action)
        return self
    }
    
    @discardableResult
    func destructive(title: String?, handler: ((UIAlertAction) -> Void)?) -> Alert {
        let action = UIAlertAction(title: title, style: .destructive, handler: handler)
        alert.addAction(action)
        return self
    }
    
    // MARK: Text Filed
    
    var textFiledBeginEditings: [UITextField: (UITextField) -> Void] = [:]
    var textFiledDidChanges: [UITextField: (UITextField) -> Void] = [:]
    var textFiledEndEditings: [UITextField: (UITextField) -> Void] = [:]
    
    @discardableResult
    func textField(placeholder: String?, hanlder: ((UITextField) -> Void)?) -> Alert {
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = placeholder
            hanlder?(textField)
            NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldTextDidEndEditing), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: textField)
            NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldTextDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
            NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldTextDidBeginEditing), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: textField)
        })
        return self
    }
    
    @discardableResult
    func beginEditing(_ hanlder: @escaping (UITextField) -> Void) -> Alert {
        if let text = alert.textFields?.last {
            textFiledBeginEditings[text] = hanlder
        }
        return self
    }
    
    @discardableResult
    func changed(_ hanlder: @escaping (UITextField) -> Void) -> Alert {
        if let text = alert.textFields?.last {
            textFiledDidChanges[text] = hanlder
        }
        return self
    }
    
    @discardableResult
    func endEditing(_ hanlder: @escaping (UITextField) -> Void) -> Alert {
        if let text = alert.textFields?.last {
            textFiledEndEditings[text] = hanlder
        }
        return self
    }
    
    @discardableResult
    func clear() {
        textFiledBeginEditings.removeAll()
        textFiledDidChanges.removeAll()
        textFiledEndEditings.removeAll()
    }
    
    // MARK: Notification
    
    @objc func textFieldTextDidBeginEditing(notification: Notification) {
        if let text = notification.object as? UITextField {
            if let hanlder = textFiledBeginEditings[text] {
                hanlder(text)
            }
        }
    }
    @objc func textFieldTextDidChange(notification: Notification) {
        if let text = notification.object as? UITextField {
            if let hanlder = textFiledDidChanges[text] {
                hanlder(text)
            }
        }
    }
    @objc func textFieldTextDidEndEditing(notification: Notification) {
        if let text = notification.object as? UITextField {
            if let hanlder = textFiledEndEditings[text] {
                hanlder(text)
            }
        }
    }
}

// MARK: - Alert Simple Tools

extension Alert {
    
    class func show(_ controller: UIViewController, title: String?, message: String?, time: TimeInterval) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        controller.present(alert, animated: true, completion: nil)
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: time)
            DispatchQueue.main.async {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    class func show(_ controller: UIViewController, title: String?, message: String?, button: String?, action: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let info = UIAlertAction(title: button, style: .default, handler: action)
        alert.addAction(info)
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func show(_ controller: UIViewController, title: String?, message: String?, sure: String?, sureAction: ((UIAlertAction) -> Void)?, cancel: String?, cancelAction: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let sInfo = UIAlertAction(title: sure, style: .default, handler: sureAction)
        alert.addAction(sInfo)
        
        let cInfo = UIAlertAction(title: cancel, style: .cancel, handler: cancelAction)
        alert.addAction(cInfo)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func push(_ controller: UIViewController, item: UIView?, title: String?, message: String?, actions: [(String, UIAlertActionStyle, ((UIAlertAction) -> Void)?)]) {
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
