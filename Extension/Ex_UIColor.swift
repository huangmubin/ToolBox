//
//  Ex_UIColor.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 2017/12/14.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

extension UIColor {
    
    /** Init with CGFloat. */
    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) {
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    /** Random Color, alpha default is 1, if is 0 ~ 1 then set the alpha, if nil will be random. */
    public static func random(alpha: CGFloat? = 1) -> UIColor {
        return self.init(
            red: CGFloat(arc4random_uniform(256)) / 255.0,
            green: CGFloat(arc4random_uniform(256)) / 255.0,
            blue: CGFloat(arc4random_uniform(256)) / 255.0,
            alpha: alpha ?? (CGFloat(arc4random_uniform(100)) / 100.0)
        )
    }
    
}
