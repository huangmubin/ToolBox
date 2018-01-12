//
//  Ex_CGRect.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 2017/12/14.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

extension CGRect {
    
    /** zoom the rect with center */
    public func zoom(_ size: CGFloat) -> CGRect {
        return CGRect(
            x: origin.x + size,
            y: origin.y + size,
            width: width - size * 2,
            height: height - size * 2
        )
    }
    
}
