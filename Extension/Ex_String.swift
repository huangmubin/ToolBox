//
//  Ex_String.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 2017/12/14.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

extension String {
    
    // MARK: - localisation
    
    /** Return the localisation string. */
    public var localisation: String {
        return NSLocalizedString(self, comment: self)
    }
    
    /**
     Return the localisation string.
     - parameter comment: the predicate to which data.
     - parameter bundls: default Bundle.main
     - returns: a localized string
     */
    public func localisation(_ comment: String, bundls: Bundle = Bundle.main) -> String {
        return NSLocalizedString(self, bundle: bundls, comment: comment)
    }
    
    // MARK: - Range
    
    /**
     Return sub string with range
     - parameter range: s ..< e
     - returns: a sub string
     */
    public subscript(range: CountableRange<Int>) -> String {
        return String(self[self.index(self.startIndex, offsetBy: range.lowerBound) ..< self.index(self.startIndex, offsetBy: range.upperBound)])
    }
    
    /**
     Range
     */
    public subscript(range: NSRange) -> String {
        return self[range.lowerBound ..< range.upperBound]
    }
    
    // MARK: - Size
    
    public static let string_size_label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    /**
     Return string size with font
     - parameter width: string width
     - parameter font: the font or nil is default
     - returns: size
     */
    public func size(_ width: CGFloat, font: UIFont? = nil) -> CGSize {
        let default_font = String.string_size_label.font
        if let font = font {
            String.string_size_label.font = font
        }
        String.string_size_label.frame = CGRect(
            x: 0, y: 0,
            width: width,
            height: 100000
        )
        String.string_size_label.text = self
        String.string_size_label.sizeToFit()
        let size = String.string_size_label.frame.size
        String.string_size_label.font = default_font
        return size
    }
    
    // MARK: - Font
    
    /** String big size in rect */
    public func font(largest_font font: UIFont, limit: CGRect) -> UIFont {
        var size = font.pointSize
        let offsets: [CGFloat] = [10, 1, 0.1]
        for offset in offsets {
            while self.size(limit.width, font: font.withSize(size)).height > limit.height {
                size -= offset
            }
            size = size + (offset > 0.1 ? offset : 0)
        }
        return font.withSize(size)
    }
    
    /** String big size in line, line default 1, must bigger 1 */
    public func font(largest_font font: UIFont, limit rect: CGRect, line: Int) -> UIFont {
        if line < 1 { return font }
        var limit = "0"
        for _ in 1 ..< line {
            limit += "\n0"
        }
        
        var size = font.pointSize
        let offsets: [CGFloat] = [10, 1, 0.1]
        for offset in offsets {
            var text_size = self.size(rect.width, font: font.withSize(size))
            var limit_size = limit.size(rect.width, font: font.withSize(size))
            while text_size.height > rect.height || text_size.height > limit_size.height {
                size -= offset
                text_size = self.size(rect.width, font: font.withSize(size))
                limit_size = limit.size(rect.width, font: font.withSize(size))
            }
            size = size + (offset > 0.1 ? offset : 0)
        }
        return font.withSize(size)
    }
    
    // MARK: - Index
    
    /** Get the index use the int value */
    public func index(_ value: Int) -> String.Index {
        return self.index(startIndex, offsetBy: String.IndexDistance(bitPattern: UInt(value)))
    }
}
