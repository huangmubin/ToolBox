//
//  Ex_Double.swift
//  SwiftiOSTests
//
//  Created by 黄穆斌 on 2017/12/14.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

extension Double {
    
    /** count a random in 0 ..< 1 */
    public static func random() -> Double {
        let value = arc4random_uniform(UInt32.max)
        return Double(value) / Double(UInt32.max - 1)
    }
    
    /** Get the upload integer: 1.22 = 2 */
    public func ceil() -> Double {
        return Foundation.ceil(self)
    }
    
    /** Get the download integer: 1.22 = 1 */
    public func floor() -> Double {
        return Foundation.floor(self)
    }
    
    /** Remove the mantissa: 1.22 = 1 */
    public func round() -> Double {
        return Foundation.round(self)
    }
    
    /** Remove the mantissa: 1.22 size 1 = 1.2 */
    public func round(size: Int) -> Double {
        let format = "%.\(size)f"
        return Double(String(format: format, self))!
    }
    
    /** Remove the interger number: 1234.555 size 1 = 4.555 */
    public func mod(size: Int) -> Double {
        return fmod(self, pow(10, Double(size)))
    }
    
}

extension CGFloat {
    
    /** count a random in 0 ..< 1 */
    public static func random() -> CGFloat {
        let value = arc4random_uniform(UInt32.max)
        return CGFloat(value) / CGFloat(UInt32.max - 1)
    }
    
}
