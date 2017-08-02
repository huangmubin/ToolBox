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
    
    // MARK: - interface orientation
    
    /** Check the device is protrait? */
    public class func isProtrait() -> Bool {
        return UIScreen.main.bounds.width < UIScreen.main.bounds.height
    }
    
    /** Change the orientation to new. */
    public class func orientation_changed(to: UIInterfaceOrientation) {
        UIDevice.current.setValue(to.rawValue, forKey: "orientation")
        UIApplication.shared.statusBarOrientation = to
    }
    
    // MARK: - Capture Screen
    
    /** Capture view */
    public class func screen(view: UIView) -> UIImage? {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
    
    /** Capture controller */
    public class func screen(controller: UIViewController) -> UIImage? {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            controller.navigationController?.view.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Other
    
    public class func minute(time: TimeInterval) -> String {
        var str = ""
        let min = Int(time) / 60
        if min >= 10 {
            str += "\(min)"
        } else {
            str += "0\(min)"
        }
        
        let sec = Int(time) % 60
        if sec >= 10 {
            str += ":\(sec)"
        } else {
            str += ":0\(sec)"
        }
        return str
    }
    
}
