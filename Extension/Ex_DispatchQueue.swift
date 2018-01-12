//
//  Ex_DispatchQueue.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 2017/12/14.
//  Copyright © 2017年 myron. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    /** delay some time to execute */
    public static func delay(_ time: TimeInterval, in_queue: DispatchQueue = DispatchQueue.main, execute: @escaping () -> Void) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: time)
            in_queue.async {
                execute()
            }
        }
    }
    
}
