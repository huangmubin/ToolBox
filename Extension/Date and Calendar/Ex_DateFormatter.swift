//
//  Ex_DateFormatter.swift
//  SwiftiOSTests
//
//  Created by 黄穆斌 on 2017/12/14.
//  Copyright © 2017年 myron. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    /** init with format */
    public convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
    
    /** get date string for time */
    public func string(time: TimeInterval) -> String {
        return self.string(from: Date(timeIntervalSince1970: time))
    }
    
    /** "yyyy-MM-dd HH:mm" */
    public static let default0 = DateFormatter(format: "yyyy-MM-dd HH:mm:ss")
    /** "yyyy-MM-dd" */
    public static let default1 = DateFormatter(format: "yyyy-MM-dd")
    /** "HH:mm" */
    public static let default2 = DateFormatter(format: "HH:mm:ss")
    
}
