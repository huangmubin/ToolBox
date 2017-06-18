//
//  Extension_View.swift
//  ToolBoxProject
//
//  Created by 黄穆斌 on 2017/6/18.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

extension UIView {
    
    /** 
     获取 View 所在 UIViewController 
     */
    func controller() -> UIViewController? {
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
