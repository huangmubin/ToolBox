//
//  LogProtocol.swift
//  Eyeglass
//
//  Created by Myron on 2018/1/22.
//  Copyright © 2018年 Myron. All rights reserved.
//

import Foundation

public protocol LogProtocol {
    var open_logs: Bool { get set }
}

extension LogProtocol {
    
    func log(file: String = #file, function: String = #function, line: Int = #line, _ text: Any?) {
        if open_logs {
            //print("\(file) - \(function) - \(line): \(String(describing: text))")
            print("\(String(describing: text))")
            
        }
    }
    
}
