//
//  Extension_UIColor.swift
//  NetworkProject
//
//  Created by 黄穆斌 on 2017/3/17.
//  Copyright © 2017年 MuBinHuang. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
     Init with CGFloat.
     */
    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) {
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
}
