//
//  Ex_View.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 2017/12/14.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

extension UIView {
    
    /** get this view's viewController */
    public func controller() -> UIViewController? {
        var next: UIView? = superview
        while next != nil {
            if next?.next?.isKind(of: UIViewController.self) == true {
                return next?.next as? UIViewController
            }
            next = next?.superview
        }
        return nil
    }
    
}
