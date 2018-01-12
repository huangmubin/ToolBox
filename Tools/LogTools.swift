//
//  LogTools.swift
//  Eyeglass
//
//  Created by Myron on 2017/10/25.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

var log_tools = LogTools()
class LogTools {
    
    var flag_level: Int = 5
    var flag_only: Int?
    var flag_default: Int = 5
    
    func print_log(flag: Int, message: Any?) {
        if let only = flag_only {
            if only == flag {
                Swift.print(String(describing: message))
            }
        }
        else {
            if flag >= flag_level {
                Swift.print(String(describing: message))
            }
        }
    }
    
}
func print(_ items: Any..., separator: String = "", terminator: String = "\n") {
    log_tools.print_log(flag: log_tools.flag_default, message: items)
}

func print(_ items: Any?) {
    log_tools.print_log(flag: log_tools.flag_default, message: items)
}

func print(flag: Int, items: Any?) {
    log_tools.print_log(flag: flag, message: items)
}

/**
 A auto print function.
 */
func MyLog(file: String = #file, function: String = #function, line: Int = #line, _ text: Any?) {
    print("MyLog: \(file) - \(function) - \(line): \(String(describing: text))")
}
