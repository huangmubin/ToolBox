//
//  Button.swift
//  SwiftiOS
//
//  Created by Myron on 2017/12/15.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

protocol ButtonTouchDelegate: class {
    func button_touch(state: UIGestureRecognizerState, touches: Set<UITouch>, with event: UIEvent?)
}

class Button: UIButton {

    /** note value */
    @IBInspectable var note: String = ""
    
    // MARK: - Layer
    
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
    
    // MARK: - State
    
    
    enum State: Int {
        case normal = 0
        case selected
        case invalid
    }
    
    /** Button state */
    public var button_state: State = .normal {
        didSet {
            color_update()
        }
    }
    
    /** Button state, only 0, 1, 2 */
    @IBInspectable var button_state_value: Int = 0 {
        didSet {
            button_state = State(rawValue: button_state_value)!
        }
    }
    
    // MARK: - Color
    
    /** Normal state color */
    @IBInspectable var normal_color: UIColor = UIColor.blue {
        didSet {
            color_update()
        }
    }
    
    /** Selected state color */
    @IBInspectable var selected_color: UIColor = UIColor.white {
        didSet {
            color_update()
        }
    }
    
    /** Invalid state color */
    @IBInspectable var invalid_color: UIColor = UIColor.lightGray {
        didSet {
            color_update()
        }
    }
    
    /** Background color */
    @IBInspectable var background_color: UIColor = UIColor.clear {
        didSet {
            color_update()
        }
    }
    
    /** Update the label and background color. */
    public func color_update() {
        switch self.button_state {
        case .normal:
            if self.isSelected { self.isSelected = false }
            if !self.isEnabled { self.isEnabled = true }
            self.setTitleColor(self.normal_color, for: .normal)
            self.layer.backgroundColor = self.background_color.cgColor
        case .selected:
            if !self.isSelected { self.isSelected = true }
            if !self.isEnabled { self.isEnabled = true }
            self.setTitleColor(self.selected_color, for: .normal)
            self.setTitleColor(self.selected_color, for: .selected)
            self.layer.backgroundColor = self.normal_color.cgColor
        case .invalid:
            if self.isSelected { self.isSelected = false }
            if self.isEnabled { self.isEnabled = false }
            self.setTitleColor(self.invalid_color, for: .normal)
            self.layer.backgroundColor = self.background_color.withAlphaComponent(0.5).cgColor
        }
        self.tintColor = self.backgroundColor
    }
    
    // MARK: - Override
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1, animations: {
                self.alpha = self.isHighlighted ? 0.8 : 1
            })
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                if button_state.rawValue != 1 {
                    button_state = .selected
                }
            } else {
                if button_state.rawValue == 1 {
                    button_state = .normal
                }
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                if button_state.rawValue == 2 {
                    button_state = .normal
                }
            } else {
                if button_state.rawValue != 2 {
                    button_state = .invalid
                }
            }
        }
    }
    
    // MARK: - Touch
    
    /** ButtonTouchDelegate */
    weak var touch_delegate: ButtonTouchDelegate?
    @IBOutlet weak var touch_delegate_link: NSObject? = nil {
        didSet {
            if let delegate = touch_delegate_link as? ButtonTouchDelegate {
                self.touch_delegate = delegate
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touch_delegate?.button_touch(state: .began, touches: touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touch_delegate?.button_touch(state: .changed, touches: touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touch_delegate?.button_touch(state: .ended, touches: touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touch_delegate?.button_touch(state: .cancelled, touches: touches, with: event)
    }
    
}
