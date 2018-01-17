//
//  Ex_UIScrollView.swift
//  MyReader
//
//  Created by 黄穆斌 on 2018/1/17.
//  Copyright © 2018年 myron. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    /** scroll view's visible rect */
    public func visible_rect() -> CGRect {
        return CGRect(
            x: contentOffset.x, y: contentOffset.y,
            width: contentOffset.x + bounds.width,
            height: contentOffset.y + bounds.height
        )
    }
    
}
