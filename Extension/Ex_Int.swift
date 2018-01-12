//
//  Ex_Int.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 2017/12/14.
//  Copyright © 2017年 myron. All rights reserved.
//

import Foundation

extension Int {
    
    /** count a random in range, default is 0 ..< 101 */
    public static func random(range: Range<Int> = 0 ..< 101) -> Int {
        return Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound))) + range.lowerBound
    }
    
    /**  */
    func string(_ size: Int) -> String {
        let format = "%.\(size)d"
        return String(format: format, self)
    }
}
