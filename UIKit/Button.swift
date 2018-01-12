//
//  Button.swift
//  ToolBoxUIKit
//
//  Created by Myron on 2017/3/30.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

enum ButtonTouchState {
    case began
    case moved
    case ended
    case canceled
    case estimated
}

protocol ButtonTouchDelegate: class {
    func button_touch(state: ButtonTouchState, touches: Set<UITouch>, with event: UIEvent?)
}

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
    
    // MARK: - Border
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? = nil {
        didSet {
            layer.borderColor = borderColor?.cgColor
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
    
    // MARK: - Touches
    
    var current_touch: UITouch?
    @IBOutlet weak var touch_delegate_link: NSObject? {
        didSet {
            if let delegate = touch_delegate_link as? ButtonTouchDelegate {
                touch_delegate = delegate
            }
        }
    }
    weak var touch_delegate: ButtonTouchDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touch_delegate?.button_touch(
            state: ButtonTouchState.began,
            touches: touches,
            with: event
        )
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touch_delegate?.button_touch(
            state: ButtonTouchState.moved,
            touches: touches,
            with: event
        )
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touch_delegate?.button_touch(
            state: ButtonTouchState.ended,
            touches: touches,
            with: event
        )
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touch_delegate?.button_touch(
            state: ButtonTouchState.canceled,
            touches: touches,
            with: event
        )
    }
    
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        super.touchesEstimatedPropertiesUpdated(touches)
        touch_delegate?.button_touch(
            state: ButtonTouchState.estimated,
            touches: touches,
            with: nil
        )
    }
}
