//
//  Ex_UITextView.swift
//  MyReader
//
//  Created by 黄穆斌 on 2018/1/17.
//  Copyright © 2018年 myron. All rights reserved.
//

import UIKit

extension UITextView {
    
    /** Get the range in visible text */
    public func visible_text_range() -> NSRange {
        let start = closestPosition(to: contentOffset) ?? beginningOfDocument
        let end = closestPosition(to: visible_rect().max_point()) ?? endOfDocument
        return NSRange(
            location: offset(from: beginningOfDocument, to: start),
            length: offset(from: start, to: end)
        )
    }
    
}
