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
    
    /** String big size in rect */
    func size(largest_font font: UIFont, limit: CGRect) -> UIFont {
        var size = font.pointSize
        while self.size(limit.width, font: font.withSize(size)).height > limit.height {
            size -= 0.1
        }
        return font.withSize(size)
    }
    
    /** String big size in line, line default 1, must bigger 1 */
    func size(largest_font font: UIFont, limit_width width: CGFloat, line: Int = 1) -> UIFont {
        if line < 1 { return font }
        var limit = "0"
        for _ in 1 ..< line {
            limit += "\n0"
        }
        
        var size = font.pointSize
        while self.size(width, font: font.withSize(size)) <= limit.size(width, font: font.withSize(size)) {
            size -= 0.1
        }
        return font.withSize(size)
    }
    
}
