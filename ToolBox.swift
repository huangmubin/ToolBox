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
    print("MyLog: \(file) - \(function) - \(line): \(text)")
}
