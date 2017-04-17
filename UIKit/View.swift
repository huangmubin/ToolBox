//
//  View.swift
//  ToolBoxUIKit
//
//  Created by Myron on 2017/3/30.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - View

class View: UIView {

    // MARK: Shadow
    
    @IBInspectable
    var opacity: Float = 0 {
        didSet {
            layer.shadowOpacity = opacity
        }
    }
    
    @IBInspectable
    var radius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = radius
        }
    }
    
    @IBInspectable
    var offset: CGPoint = CGPoint.zero {
        didSet {
            layer.shadowOffset = CGSize(width: offset.x, height: offset.y)
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? = nil {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
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
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

// MARK: - Asymmetry View

class AsymmetryView: UIView {
    
    
    // MARK: - Corners
    
    /// x = a, y = b, w = c, h = d
    @IBInspectable
    var corners: CGRect = CGRect.zero {
        didSet {
            transformShowLayer()
        }
    }
    
    // MARK: - Shadow
    
    @IBInspectable
    var opacity: Float = 0 {
        didSet {
            showLayer.shadowOpacity = opacity
        }
    }
    
    @IBInspectable
    var radius: CGFloat = 0 {
        didSet {
            showLayer.shadowRadius = radius
        }
    }
    
    @IBInspectable
    var offset: CGPoint = CGPoint.zero {
        didSet {
            showLayer.shadowOffset = CGSize(width: offset.x, height: offset.y)
        }
    }
    
    @IBInspectable
    var shadow: UIColor? = nil {
        didSet {
            showLayer.shadowColor = shadow?.cgColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            showLayer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? = nil {
        didSet {
            showLayer.borderColor = borderColor?.cgColor
        }
    }
    
    // MARK: Colors
    
    @IBInspectable
    var fillColor: UIColor = UIColor.white {
        didSet {
            showLayer.fillColor = fillColor.cgColor
        }
    }
    @IBInspectable
    var strokeColor: UIColor = UIColor.white {
        didSet {
            showLayer.strokeColor = strokeColor.cgColor
        }
    }
    
    // MARK: - Override
    
    override var frame: CGRect {
        didSet {
            transformShowLayer()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            transformShowLayer()
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        deployShowLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deployShowLayer()
    }
    
    // MARK: - Show Layer
    
    let showLayer: CAShapeLayer = CAShapeLayer()
    
    private func deployShowLayer() {
        showLayer.path = rectanglePath(size: bounds.size).cgPath
        showLayer.fillColor = backgroundColor?.cgColor
        layer.insertSublayer(showLayer, at: 0)
        
        fillColor = backgroundColor ?? UIColor.clear
        backgroundColor = nil
    }
    
    private func transformShowLayer() {
        showLayer.path = rectanglePath(size: bounds.size, a: corners.origin.x, b: corners.origin.y, c: corners.width, d: corners.height).cgPath
        layer.displayIfNeeded()
    }
    
    // MARK: - Drawer
    
    func rectanglePath(size: CGSize, a: CGFloat = 0, b: CGFloat = 0, c: CGFloat = 0, d: CGFloat = 0) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: a))
        path.addArc(withCenter: CGPoint(x: a, y: a), radius: a, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi / 2) * 3, clockwise: true)
        
        path.addLine(to: CGPoint(x: size.width - b, y: 0))
        path.addArc(withCenter: CGPoint(x: size.width - b, y: b), radius: b, startAngle: CGFloat(Double.pi / 2) * 3, endAngle: CGFloat(Double.pi / 2) * 4, clockwise: true)
        
        path.addLine(to: CGPoint(x: size.width, y: size.height - c))
        path.addArc(withCenter: CGPoint(x: size.width - c, y: size.height - c), radius: c, startAngle: 0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
        
        path.addLine(to: CGPoint(x: d, y: size.height))
        path.addArc(withCenter: CGPoint(x: d, y: size.height - d), radius: d, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
        return path
    }
    
}
