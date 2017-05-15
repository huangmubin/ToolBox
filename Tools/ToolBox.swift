//
//  ToolBox.swift
//  AutoLayoutProject
//
//  Created by 黄穆斌 on 2017/3/18.
//  Copyright © 2017年 MuBinHuang. All rights reserved.
//

import UIKit

/**
 A auto print function.
 */
func MyLog(file: String = #file, function: String = #function, line: Int = #line, _ text: Any?) {
    print("MyLog: \(file) - \(function) - \(line): \(String(describing: text))")
}


// MARK: - ToolBox

public class ToolBox {
    
    // MARK: - Random Number
    
    /**
     count a random number in range
     */
    public class func random(range: Range<Int>) -> Int {
        return  Int(arc4random_uniform(UInt32(range.count))) + range.lowerBound
    }
    
    /**
     count a random number in 0 ..< 1
     */
    public class func random() -> Double {
        return Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)
    }
    
    // MARK: - Device Model
    
    /**
     check the current device is't iPhone.
     */
    public class func isiPhone() -> Bool {
        return UIDevice.current.model.hasPrefix("iPhone")
    }
    
    /**
     check the current device is't iPad.
     */
    public class func isiPad() -> Bool {
        return UIDevice.current.model.hasPrefix("iPad")
    }
    
    
}
