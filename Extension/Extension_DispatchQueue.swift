//
//  Extension_DispatchQueue.swift
//  Eyeglass
//
//  Created by Myron on 2017/10/31.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

extension DispatchQueue {
    
    /** 延时后执行 */
    public class func delay(time: TimeInterval, in_queue: DispatchQueue = DispatchQueue.main, run: @escaping () -> Void) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: time)
            in_queue.async {
                run()
            }
        }
    }
    
}
