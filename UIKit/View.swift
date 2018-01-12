//
//  View.swift
//  SwiftiOS
//
//  Created by Myron on 2017/12/15.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class View: UIView {
    
    /** layer cornerRedius */
    @IBInspectable var corner: CGFloat = 0 {
        didSet {
            layer.cornerRadius = corner
        }
    }
    
    /** layer shadowOpacity */
    @IBInspectable var opacity: Float = 0 {
        didSet {
            layer.shadowOpacity = opacity
        }
    }
    
    /** layer shadowRadius */
    @IBInspectable var radius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = radius
        }
    }
    
    /** layer shadowOffset */
    @IBInspectable var offset: CGPoint = CGPoint.zero {
        didSet {
            layer.shadowOffset = CGSize(width: offset.x, height: offset.y)
        }
    }
    
    /** layer shadowColor */
    @IBInspectable var shadowColor: UIColor? = nil {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    /** layer borderWidth */
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    /** layer borderColor */
    @IBInspectable var borderColor: UIColor? = nil {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
}
