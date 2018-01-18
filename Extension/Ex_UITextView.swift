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
    public func visible_text_range() -> Range<Int> {
        let start = closestPosition(to: contentOffset) ?? beginningOfDocument
        let end = closestPosition(to: visible_rect().max_point()) ?? endOfDocument
        return offset(from: beginningOfDocument, to: start) ..< offset(from: beginningOfDocument, to: end)
    }
    
    /** Get the string index range in visible */
    public func visible_range() -> Range<String.Index>? {
        guard let text = text else { return nil }
        
        let start = closestPosition(to: contentOffset) ?? beginningOfDocument
        let ended = closestPosition(to: visible_rect().max_point()) ?? endOfDocument
        return text.index(text.startIndex, offsetBy: offset(from: beginningOfDocument, to: start)) ..< text.index(text.startIndex, offsetBy: offset(from: beginningOfDocument, to: ended))
    }
    
}
