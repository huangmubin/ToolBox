//
//  Button.swift
//  ToolBoxUIKit
//
//  Created by Myron on 2017/3/30.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class Button: UIButton {

    @IBInspectable
    var note: String = ""
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    
    private var tempSelect: Bool?
    private func deploy() {
        isSelected = true
        tempSelect = false
        DispatchQueue.main.async {
            for view in self.subviews {
                if view is UIImageView && view !== self.imageView {
                    view.removeFromSuperview()
                    self.isSelected = self.tempSelect!
                    self.tempSelect = nil
                }
            }
        }
    }

    // MARK: - Shadow
    
    @IBInspectable
    var corner: CGFloat = 0 {
        didSet {
            layer.cornerRadius = corner
        }
    }
    
    @IBInspectable
    var opacity: Float = 0 {
        didSet {
            layer.shadowOpacity = opacity
        }
    }
    
    @IBInspectable
    var offset: CGPoint = CGPoint.zero {
        didSet {
            layer.shadowOffset = CGSize(width: offset.x, height: offset.y)
        }
    }
    
    @IBInspectable
    var radius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = radius
        }
    }
    
    // MARK: - Color
    
    override var backgroundColor: UIColor? {
        didSet {
            layer.backgroundColor = isSelected ? tintColor.cgColor : color.cgColor
        }
    }
    
    @IBInspectable
    var color: UIColor = UIColor.blue {
        didSet {
            layer.backgroundColor = isSelected ? tintColor.cgColor : color.cgColor
        }
    }
    
    // MARK: - Override
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.1, animations: {
                    self.alpha = 0.8
                })
            }
            else {
                UIView.animate(withDuration: 0.1, animations: {
                    self.alpha = 1
                })
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if tempSelect != nil {
                tempSelect = isSelected
            }
            if isSelected {
                self.layer.backgroundColor = self.tintColor.cgColor
            }
            else {
                self.layer.backgroundColor = self.color.cgColor
            }
        }
    }
}
