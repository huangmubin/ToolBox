//
//  Extension_Int.swift
//  TestProject
//
//  Created by Myron on 2017/10/17.
//  Copyright © 2017年 Myron. All rights reserved.
//

import Foundation

extension Int {
    
    /** 保留特定数量整数 */
    public func format(integer_number: UInt) -> Int {
        var v = 1
        for _ in 0 ..< integer_number {
            v *= 10
        }
        return self - self / v * v
    }
    
}
