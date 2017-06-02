//
//  Extension_String.swift
//  NetworkTestProject
//
//  Created by 黄穆斌 on 2017/3/17.
//  Copyright © 2017年 MuBinHuang. All rights reserved.
//

import Foundation
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
    subscript(range: Range<Int>) -> String {
        return self[self.index(self.startIndex, offsetBy: range.lowerBound) ..< self.index(self.startIndex, offsetBy: range.upperBound)]
    }
    
    // MARK: - Size
    
    static let string_size_label: UILabel = {
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
}
