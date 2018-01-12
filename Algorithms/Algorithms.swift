//
//  Algorithms.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 2017/12/20.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

public class Algorithms {
    
    // 是否是素数
    public class func is_prime(_ v: Int) -> Bool {
        if v < 2 {
            return false
        } else {
            var i = 2
            while i * i <= v {
                if v % i == 0 {
                    return false
                }
                i += 1
            }
            return true
        }
    }

}
