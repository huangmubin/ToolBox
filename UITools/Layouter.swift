//
//  Layouter.swift
//  AutoLayoutProject
//
//  Created by 黄穆斌 on 2017/3/18.
//  Copyright © 2017年 MuBinHuang. All rights reserved.
//

import UIKit

/**
 class Layouter
    enum Orientation
    class Container
        struct LayoutInfo
 */

// MARK: - Layouter Extension: Orientation

extension Layouter {
    public enum Orientation: Int {
        case portraitUpside     = 1
        case portraitUpsideDown = 2
        case landscapeLeft  = 4
        case landscapeRight = 8
        
        case portrait  = 3
        case landscape = 12
        
        case all = 15
        
        case unkown = 0
    }
}


// MARK: - Layouter Extension: Container

extension Layouter {
    
    /**
     A NSLayoutConstraint container, auto active or unactive the NSLayoutConstraint when the application status bar is orientation.
     */
    public class Container {
        
        // MARK: LayoutInfo struct
        
        private struct LayoutInfo {
            
            weak var layout: NSLayoutConstraint?
            var orient: Layouter.Orientation
            
            init(layout: NSLayoutConstraint, orient: Layouter.Orientation = .unkown) {
                self.layout = layout
                self.orient = orient
            }
            
            func match() {
                switch orient {
                case .unkown:
                    break
                case .all:
                    layout?.isActive = true
                case .portrait:
                    layout?.isActive = UIScreen.main.bounds.width < UIScreen.main.bounds.height
                case .landscape:
                    layout?.isActive = UIScreen.main.bounds.width > UIScreen.main.bounds.height
                case .portraitUpside:
                    layout?.isActive = UIDevice.current.orientation == UIDeviceOrientation.portrait
                case .portraitUpsideDown:
                    layout?.isActive = UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown
                case .landscapeRight:
                    layout?.isActive = UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
                case .landscapeLeft:
                    layout?.isActive = UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
                }
            }
            
        }
        
        // MARK: Data
        
        /** The layouts */
        private var layouts: [AnyHashable : LayoutInfo] = [:]
        
        init() {
            NotificationCenter.default.addObserver(self, selector: #selector(notify), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
        }
        deinit {
            NotificationCenter.default.removeObserver(self, name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
        }
        
        // MARK: Subscript
        
        subscript(key: AnyHashable) -> NSLayoutConstraint? {
            return layouts[key]?.layout
        }
        
        // MARK: Methods
        
        public func remove(key: AnyHashable) {
            layouts.removeValue(forKey: key)
        }
        
        public func clear() {
            layouts.removeAll()
        }
        
        public func append(key: AnyHashable, layout: NSLayoutConstraint, orient: Layouter.Orientation = .unkown) {
            layouts[key] = LayoutInfo(layout: layout, orient: orient)
        }
        
        // MAKR: Notify
        
        @objc func notify(object: Notification) {
            updateActive()
        }
        
        fileprivate func updateActive() {
            OperationQueue.main.addOperation {
                for (_, layout) in self.layouts {
                    layout.layout?.isActive = false
                }
                for (_, layout) in self.layouts {
                    layout.match()
                }
            }
        }
    }
    
}

// MARK: - Layouter

/**
 A simply autolayout tool.
 */
public class Layouter {
    
    // MARK: Views
    
    /** The view which add NSLayoutConstraint. */
    public weak var superview: UIView!
    public weak var view: UIView!
    public weak var relative: UIView!
    
    /**
     Change the views
     - parameter view:
     - parameter relative:
     - returns: self
     */
    public func setViews(view: UIView? = nil, relative: UIView? = nil) -> Layouter {
        if let view = view {
            self.view = view
            self.view.translatesAutoresizingMaskIntoConstraints = false
        }
        if let view = relative {
            self.relative = view
        }
        return self
    }
    
    // MARK: Init
    
    /**
     Initialize a layout container object.
     - parameter superview:
     - parameter view:
     - parameter relative:
     - parameter container:
     - returns:
     */
    init(superview: UIView, view: UIView, relative: UIView? = nil, container: Layouter.Container? = nil) {
        self.superview = superview
        self.view = view
        self.relative = relative ?? superview
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self._contrainer = container
    }
    
    // MARK: Constraints
    
    /**
     When add a NSLayoutConstraint, it will append to _constrants.
     Use the clearConstrants to clear it.
     */
    fileprivate var _constrants: [NSLayoutConstraint] = []
    
    @discardableResult
    public func clearConstrants() -> Layouter {
        _constrants.removeAll(keepingCapacity: true)
        return self
    }
    
    @discardableResult
    public func constrants(_ block: ([NSLayoutConstraint]) -> Void) -> Layouter {
        block(_constrants)
        return self
    }
    
    @discardableResult
    public func constrants(index: Int) -> NSLayoutConstraint {
        return _constrants[index]
    }
    
    @discardableResult
    public func constrants(last: (NSLayoutConstraint) -> Void) -> Layouter {
        last(_constrants.last!)
        return self
    }
    
    // MARK: Container
    
    public weak var _contrainer: Layouter.Container?
    
    @discardableResult
    public func setContrainer(_ con: Layouter.Container) -> Layouter {
        _contrainer = con
        return self
    }
    
    @discardableResult
    public func contrainer(appendLayoutAt index: Int, key: String, orient: Layouter.Orientation = .unkown) -> Layouter {
        _contrainer?.append(key: key, layout: _constrants[index], orient: orient)
        return self
    }
    
    @discardableResult
    public func contrainer(appendLastLayoutTo key: String, orient: Layouter.Orientation = .unkown, active: Bool = false) -> Layouter {
        _constrants.last!.isActive = active
        _contrainer?.append(key: key, layout: _constrants.last!, orient: orient)
        return self
    }
    
    @discardableResult
    public func contrainer(foreach block: (Int, NSLayoutConstraint) -> String?) -> Layouter {
        for (index, layout) in _constrants.enumerated() {
            if let key = block(index, layout) {
                _contrainer?.append(key: key, layout: layout)
            }
        }
        return self
    }
    
}

// MARK: - Layouter Extension: Custom

extension Layouter {
    
    @discardableResult
    public func layout(
        edge: NSLayoutAttribute,
        to: NSLayoutAttribute,
        constant: CGFloat           = 0,
        multiplier: CGFloat         = 1,
        priority: Float             = 1000,
        related: NSLayoutRelation   = .equal
        ) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: edge, relatedBy: related, toItem: relative, attribute: to, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
}

// MARK: - Layouter Extension: Size

extension Layouter {
    
    /// Height To relative
    @discardableResult
    public func height(
        _ constant: CGFloat = 0,
        multiplier: CGFloat = 1,
        priority: Float = 1000,
        related: NSLayoutRelation = .equal
        ) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .height, relatedBy: related, toItem: relative, attribute: .height, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    /// Height To self
    @discardableResult
    public func heightSelf(
        _ constant: CGFloat = 0,
        multiplier: CGFloat = 1,
        priority: Float = 1000,
        related: NSLayoutRelation = .equal
        ) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .height, relatedBy: related, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    /// Width To relative
    @discardableResult
    public func width(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .width, relatedBy: related, toItem: relative, attribute: .width, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    /// Width To self
    @discardableResult
    public func widthSelf(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .width, relatedBy: related, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    /// Type true is width to height, false is height to width
    @discardableResult
    public func aspect(type: Bool = true, constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: type ? .width : .height, relatedBy: related, toItem: view, attribute: type ? .height : .width, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    /// width and height
    @discardableResult
    public func size(w: CGFloat, h: CGFloat, priority: Float = 1000) -> Layouter {
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: w)
            lay.priority = priority
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: h)
            lay.priority = priority
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        return self
    }
    
    /// width and height to relative
    @discardableResult
    public func size(priority: Float = 1000) -> Layouter {
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: relative, attribute: .width, multiplier: 1, constant: 0)
            lay.priority = priority
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: relative, attribute: .height, multiplier: 1, constant: 0)
            lay.priority = priority
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        return self
    }
    
}

// MARK: - Layouter Extension: Single Layout

extension Layouter {
    
    @discardableResult
    public func top(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .top, relatedBy: related, toItem: relative, attribute: .top, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    @discardableResult
    public func bottom(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: related, toItem: relative, attribute: .bottom, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    @discardableResult
    public func leading(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: related, toItem: relative, attribute: .leading, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    @discardableResult
    public func trailing(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: related, toItem: relative, attribute: .trailing, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    @discardableResult
    public func centerX(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: related, toItem: relative, attribute: .centerX, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    @discardableResult
    public func centerY(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: related, toItem: relative, attribute: .centerY, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
}

// MARK: - Layouter Extension: Double Layout

extension Layouter {
    
    @discardableResult
    public func center(x: CGFloat = 0, y: CGFloat = 0) -> Layouter {
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: relative, attribute: .centerX, multiplier: 1, constant: x)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: relative, attribute: .centerY, multiplier: 1, constant: y)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        return self
    }
    
    @discardableResult
    public func horizontal(leading: CGFloat = 0, trailing: CGFloat = 0) -> Layouter {
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: relative, attribute: .leading, multiplier: 1, constant: leading)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: relative, attribute: .trailing, multiplier: 1, constant: trailing)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        return self
    }
    
    @discardableResult
    public func vertical(top: CGFloat = 0, bottom: CGFloat = 0) -> Layouter {
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: relative, attribute: .top, multiplier: 1, constant: top)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: relative, attribute: .bottom, multiplier: 1, constant: bottom)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        return self
    }
    
}


// MARK: - Layouter Extension: Four Layout

extension Layouter {
    
    @discardableResult
    public func edges(top: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0) -> Layouter {
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: relative, attribute: .top, multiplier: 1, constant: top)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: relative, attribute: .bottom, multiplier: 1, constant: bottom)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: relative, attribute: .leading, multiplier: 1, constant: leading)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: relative, attribute: .trailing, multiplier: 1, constant: trailing)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        return self
    }
    
}


/*
// TODO: - Test Layouter Operations
 
// MARK: - Layout Operations

extension Layouter {
    
    /*
     通过运算符来进行 Layout 设置。
     */
    class Operation {
        weak var view: UIView!
        var attribute: NSLayoutAttribute
        
        var constant: CGFloat = 0
        var multiplier: CGFloat = 1
        var priority: Float = 1000
        
        init(view: UIView, attribute: NSLayoutAttribute) {
            self.view = view
            self.attribute = attribute
        }
    }
    
}

// MARK: - Layout Operations: == <= >=

extension Layouter.Operation {
    
    static func ==(left: Layouter.Operation, right: Layouter.Operation) -> NSLayoutConstraint {
        left.view.translatesAutoresizingMaskIntoConstraints = false
        let layout = NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: .equal, toItem: right.view, attribute: right.attribute, multiplier: right.multiplier, constant: right.constant)
        layout.priority = right.priority
        return layout
    }
    
    static func <=(left: Layouter.Operation, right: Layouter.Operation) -> NSLayoutConstraint {
        left.view.translatesAutoresizingMaskIntoConstraints = false
        let layout = NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: .lessThanOrEqual, toItem: right.view, attribute: right.attribute, multiplier: right.multiplier, constant: right.constant)
        layout.priority = right.priority
        return layout
    }
    
    static func >=(left: Layouter.Operation, right: Layouter.Operation) -> NSLayoutConstraint {
        left.view.translatesAutoresizingMaskIntoConstraints = false
        let layout = NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: .greaterThanOrEqual, toItem: right.view, attribute: right.attribute, multiplier: right.multiplier, constant: right.constant)
        layout.priority = right.priority
        return layout
    }
    
}

// MARK: - Layout Operations: + - * / |

extension Layouter.Operation {
    
    static func +(left: Layouter.Operation, right: CGFloat) -> Layouter.Operation {
        left.constant = right
        return left
    }
    
    static func -(left: Layouter.Operation, right: CGFloat) -> Layouter.Operation {
        left.constant = -right
        return left
    }
    
    static func *(left: Layouter.Operation, right: CGFloat) -> Layouter.Operation {
        left.multiplier = right
        return left
    }
    
    static func /(left: Layouter.Operation, right: CGFloat) -> Layouter.Operation {
        left.multiplier = 1/right
        return left
    }
    
    static func |(left: Layouter.Operation, right: Float) -> Layouter.Operation {
        left.priority = right
        return left
    }
    
}

// MARK: - Layout Operations Protocol

extension UIView {
    
    var width: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .width)
    }
    
    var height: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .height)
    }
    
    var centerX: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .centerX)
    }
    
    var centerY: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .centerY)
    }
    
    var top: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .top)
    }
    
    var bottom: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .bottom)
    }
    
    var leading: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .leading)
    }
    
    var trailing: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .trailing)
    }
    
}
*/
