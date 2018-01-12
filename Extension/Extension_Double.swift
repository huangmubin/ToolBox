//
//  Extension_Double.swift
//  TestProject
//
//  Created by Myron on 2017/10/17.
//  Copyright © 2017年 Myron. All rights reserved.
//

import Foundation


extension Double {
    
    /** 向上取整，取离他最近但是比他大的整数 */
    public func ceil() -> Double {
        return Foundation.ceil(self)
    }
    /** 向下取整，取离他最近但是比他小的整数 */
    public func floor() -> Double {
        return Foundation.floor(self)
    }
    /** 去除尾数，向下取整 */
    public func round() -> Double {
        return Foundation.round(self)
    }
    
    
    /** 保留特定数量尾数 */
    public func format(decimal_number: Int) -> Double {
        let format = "%.\(decimal_number)f"
        return Double(String(format: format, self))!
    }
    
    
    /** 保留特定数量整数 */
    public func format(integer_number: UInt) -> Double {
        var v = 1
        for _ in 0 ..< integer_number {
            v *= 10
        }
        return self - Double(Int(self / Double(v)) * v)
    }
    
}
