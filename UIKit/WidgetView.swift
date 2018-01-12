//
//  WidgetView.swift
//  Eyeglass
//
//  Created by Myron on 2017/10/31.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

extension UIView {
    
    func widget_hide() {
        for subview in subviews {
            if let widget = subview as? WidgetView {
                widget.hide_animate()
            }
        }
    }
    
    func widget(text: String, complete: ((WidgetView) -> Void)? = nil) {
        let widget = WidgetView()
        widget.add_to_super(view: self)
        widget.complete_block = complete
        widget.content_label.text = text
        widget.frame = bounds
        widget.show_animate()
        widget.run_timer(time: 2)
    }
    
    func widget(image image_type: WidgetViewImageType, complete: ((WidgetView) -> Void)? = nil) {
        let widget = WidgetView()
        widget.add_to_super(view: self)
        widget.complete_block = complete
        widget.type = .image
        widget.content_image.image = WidgetView.ImageCache.image(type: image_type)
        widget.frame = bounds
        widget.show_animate()
        widget.run_timer(time: 2)
    }
    
    func widget(image image_type: WidgetViewImageType, text: String, complete: ((WidgetView) -> Void)? = nil) {
        let widget = WidgetView()
        widget.add_to_super(view: self)
        widget.complete_block = complete
        widget.type = .image_text
        widget.content_label.text = text
        widget.content_image.image = WidgetView.ImageCache.image(type: image_type)
        widget.edge_space = 16
        widget.frame = bounds
        widget.show_animate()
        widget.run_timer(time: 2)
    }
    
    @discardableResult
    func widget(wait title: String, complete: ((WidgetView) -> Void)? = nil) -> WidgetView {
        let widget = WidgetView()
        widget.add_to_super(view: self)
        widget.complete_block = complete
        widget.type = .custom_text
        widget.content_label.text = title
        widget.content_image.image = nil
        widget.content_custom = WidgetViewCustomWaitView()
        widget.edge_space = 16
        widget.frame = bounds
        widget.show_animate()
        return widget
    }
    
    func widget(wait_cancel title: String, detail: String? = nil, action: ((WidgetView) -> Bool)? = nil, complete: ((WidgetView) -> Void)? = nil) {
        let widget = WidgetView()
        widget.add_to_super(view: self)
        widget.button_action_block = action
        widget.complete_block = complete
        widget.type = .text_custom_text_button
        widget.content_label.text = title
        widget.content_image.image = nil
        widget.content_label_detail.text = detail
        widget.content_custom = WidgetViewCustomWaitView()
        widget.edge_space = 16
        widget.frame = bounds
        widget.show_animate()
    }
}


enum WidgetViewType {
    case text
    case image
    case image_text
    case custom_text
    case custom_text_button
    case text_custom_text_button
}

enum WidgetViewImageType {
    case success
    case error
    case info
}

protocol WidgetViewCustomProtocol: NSObjectProtocol {
    var data: [String: Any] { get set }
    func update_subviews()
    func resize_subviews()
}

extension WidgetViewCustomProtocol {
    func get(_ key: String) -> Any? {
        return data[key]
    }
    func set(_ key: String, value: Any) {
        data[key] = value
    }
}

// MARK: - WidgetView

class WidgetView: UIView {
    
    // MARK: - Values
    
    // 类型
    var type = WidgetViewType.text
    
    // 回调
    var complete_block: ((WidgetView) -> Void)?
    
    // Cancel
    var button_action_block: ((WidgetView) -> Bool)?
    
    // 边距离
    var edge_space: CGFloat = 8
    
    // 最小宽度
    var min_width: CGFloat = 60
    
    // 最小高度
    var min_height: CGFloat = 60
    
    // MARK: - Subviews
    
    // 动画图层
    let animate_view: UIView = UIView()
    
    // 背景图层
    let back_view: UIView = UIView()
    
    // 内容文本
    let content_label: UILabel = UILabel()
    
    // 详细内容文本
    let content_label_detail: UILabel = UILabel()
    
    // 内容图片
    let content_image: UIImageView = UIImageView()
    
    // 自定义图层
    var content_custom: WidgetViewCustomProtocol? {
        didSet {
            if let view = content_custom as? UIView {
                content_custom?.update_subviews()
                back_view.addSubview(view)
            }
        }
    }
    
    // 取消按钮
    let content_button: UIButton = UIButton()
    
    // MARK: - Init
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        init_deploy()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        init_deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init_deploy()
    }
    
    private func init_deploy() {
        addSubview(animate_view)
        animate_view.layer.cornerRadius = 16
        
        addSubview(back_view)
        back_view.backgroundColor = UIColor.black
        back_view.layer.cornerRadius = 16
        back_view.alpha = 0
        
        back_view.addSubview(content_label)
        content_label.textColor = UIColor.white
        content_label.numberOfLines = 0
        content_label.textAlignment = NSTextAlignment.center
        
        back_view.addSubview(content_image)
        NotificationCenter.default.addObserver(self, selector: #selector(orientation), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
        back_view.addSubview(content_button)
        content_button.isHidden = true
        content_button.addTarget(self, action: #selector(content_button_action), for: .touchUpInside)
        content_button.frame.size = CGSize(width: 80, height: 30)
        content_button.setTitleColor(UIColor.white, for: .normal)
        content_button.layer.borderWidth = 1
        content_button.layer.borderColor = UIColor.white.cgColor
        content_button.layer.cornerRadius = 3
        
        content_button.setTitle("widget_cancel".localisation, for: .normal)
        content_button.setTitle("widget_cancel".language, for: .normal)
        
        back_view.addSubview(content_label_detail)
        content_label_detail.isHidden = true
        content_label_detail.font = UIFont(name: content_label.font.fontName, size: content_label.font.pointSize - 2)
        content_label_detail.textColor = UIColor.white
        content_label_detail.numberOfLines = 0
        content_label_detail.textAlignment = NSTextAlignment.center
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func add_to_super(view: UIView) {
        for subview in view.subviews {
            if let sub = subview as? WidgetView {
                sub.hide_animate()
            }
        }
        view.addSubview(self)
    }
    
    // MARK: Orientation
    
    @objc func orientation() {
        DispatchQueue.main.async { [weak self] in
            if let view = self?.superview {
                UIView.animate(withDuration: 0.25, animations: {
                    self?.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
                })
            }
        }
    }
    
    // MARK: - Button Action
    
    @objc func content_button_action() {
        if button_action_block?(self) ?? true {
            button_action_block = nil
            self.run_timer(time: 1)
        }
    }
    
    // MARK: - Size
    
    
    override var frame: CGRect {
        didSet {
            resize_subviews()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            resize_subviews()
        }
    }
    
    func resize_subviews() {
        switch type {
        case .text:
            resize_subviews_text(min_width: min_width, min_height: min_height, edge_space: edge_space)
        case .image:
            resize_subviews_image(min_width: min_width, min_height: min_height, edge_space: edge_space)
        case .image_text:
            resize_subviews_image_text(min_width: min_width, min_height: min_height, edge_space: edge_space)
        case .custom_text:
            resize_subviews_custom_text(min_width: min_width, min_height: min_height, edge_space: edge_space)
        case .custom_text_button:
            resize_subviews_custom_text_button(min_width: min_width, min_height: min_height, edge_space: edge_space)
        case .text_custom_text_button:
            resize_subviews_text_custom_text_button(min_width: min_width, min_height: min_height, edge_space: edge_space)
        }
    }
    
    func resize_subviews_text(min_width: CGFloat, min_height: CGFloat, edge_space: CGFloat) {
        var w: CGFloat = 0, h: CGFloat = 0
        
        content_label.bounds.size.width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
        content_label.sizeToFit()
        
        if content_label.bounds.height < min_height {
            h = min_height + edge_space * 2
            w = max(min_width, content_label.bounds.width) + edge_space * 2 + abs(content_label.bounds.height - min_height)
        }
        else {
            h = content_label.bounds.height + edge_space * 2
            w = max(min_width, content_label.bounds.width) + edge_space * 2
        }
        
        back_view.frame = CGRect(
            x: (bounds.width - w) / 2,
            y: (bounds.height - h) / 2,
            width: w,
            height: h
        )
        
        content_label.center = CGPoint(x: w / 2, y: h / 2)
    }
    
    func resize_subviews_image(min_width: CGFloat, min_height: CGFloat, edge_space: CGFloat) {
        let w = max(30, min_width) + edge_space * 2
        let h = max(30, min_height) + edge_space * 2
        
        back_view.frame = CGRect(
            x: (bounds.width - w) / 2,
            y: (bounds.height - h) / 2,
            width: w,
            height: h
        )
        
        content_image.frame = CGRect(
            x: (back_view.frame.width - 30) / 2,
            y: (back_view.frame.height - 30) / 2,
            width: 30,
            height: 30
        )
    }
    
    func resize_subviews_image_text(min_width: CGFloat, min_height: CGFloat, edge_space: CGFloat) {
        var w: CGFloat = 0, h: CGFloat = 0
        
        content_label.bounds.size.width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
        content_label.sizeToFit()
        
        w = max(max(min_width, 30), content_label.bounds.width) + edge_space * 2
        h = 38 + content_label.bounds.height + edge_space * 2
        
        back_view.frame = CGRect(
            x: (bounds.width - w) / 2,
            y: (bounds.height - h) / 2,
            width: w,
            height: h
        )
        
        content_image.frame = CGRect(
            x: (back_view.frame.width - 30) / 2,
            y: edge_space,
            width: 30,
            height: 30
        )
        content_label.center = CGPoint(
            x: w / 2,
            y: content_image.frame.maxY + 8 + content_label.bounds.height / 2
        )
    }
    
    func resize_subviews_custom_text(min_width: CGFloat, min_height: CGFloat, edge_space: CGFloat) {
        var w: CGFloat = 0, h: CGFloat = 0
        
        content_label.bounds.size.width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
        content_label.sizeToFit()
        
        w = max(max(min_width, 40), content_label.bounds.width) + edge_space * 2
        h = 48 + content_label.bounds.height + edge_space * 2
        
        back_view.frame = CGRect(
            x: (bounds.width - w) / 2,
            y: (bounds.height - h) / 2,
            width: w,
            height: h
        )
        
        content_image.frame = CGRect(
            x: (back_view.frame.width - 30) / 2,
            y: edge_space,
            width: 30,
            height: 30
        )
        content_label.center = CGPoint(
            x: w / 2,
            y: content_image.frame.maxY + 8 + content_label.bounds.height / 2
        )
        
        if let view = content_custom as? UIView {
            view.frame = content_image.frame
            content_custom?.resize_subviews()
        }
    }
    
    func resize_subviews_custom_text_button(min_width: CGFloat, min_height: CGFloat, edge_space: CGFloat) {
        var w: CGFloat = 0, h: CGFloat = 0
        
        content_label.bounds.size.width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
        content_label.sizeToFit()
        
        w = max(max(min_width, 40), content_label.bounds.width) + edge_space * 2
        h = 48 + content_label.bounds.height + edge_space * 2 + 38
        
        back_view.frame = CGRect(
            x: (bounds.width - w) / 2,
            y: (bounds.height - h) / 2,
            width: w,
            height: h
        )
        
        content_image.frame = CGRect(
            x: (back_view.frame.width - 30) / 2,
            y: edge_space,
            width: 40,
            height: 40
        )
        
        content_label.center = CGPoint(
            x: w / 2,
            y: content_image.frame.maxY + 8 + content_label.bounds.height / 2
        )
        
        content_button.isHidden = false
        content_button.center = CGPoint(
            x: w / 2,
            y: content_label.frame.maxY + 23
        )
        
        if let view = content_custom as? UIView {
            view.frame = content_image.frame
            content_custom?.resize_subviews()
        }
    }
    
    func resize_subviews_text_custom_text_button(min_width: CGFloat, min_height: CGFloat, edge_space: CGFloat) {
        var w: CGFloat = 0, h: CGFloat = 0
        
        content_label.bounds.size.width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
        content_label.sizeToFit()
        
        content_label_detail.bounds.size.width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
        content_label_detail.sizeToFit()
        
        if content_label_detail.text?.isEmpty ?? true {
            w = max(max(max(min_width, 100), content_label.bounds.width), content_label_detail.bounds.width) + edge_space * 2
            h = 48 + content_label.bounds.height + edge_space * 2 + 24
        } else {
            w = max(max(max(min_width, 100), content_label.bounds.width), content_label_detail.bounds.width) + edge_space * 2
            h = 48 + content_label.bounds.height + edge_space * 2 + 24 + content_label_detail.bounds.height + 8
        }
        
        back_view.frame = CGRect(
            x: (bounds.width - w) / 2,
            y: (bounds.height - h) / 2,
            width: w,
            height: h
        )
        
        content_label.center = CGPoint(
            x: w / 2,
            y: edge_space
        )
        
        content_image.frame = CGRect(
            x: (back_view.frame.width - 40) / 2,
            y: content_label.frame.maxY + 8,
            width: 40,
            height: 40
        )
        
        if !(content_label_detail.text?.isEmpty ?? true) {
            content_label_detail.isHidden = false
            content_label_detail.center = CGPoint(
                x: w / 2,
                y: content_image.frame.maxY + content_label_detail.bounds.height / 2 + 8
            )
        }
        
        if content_label_detail.text?.isEmpty ?? true {
            content_button.isHidden = false
            content_button.center = CGPoint(
                x: w / 2,
                y: content_image.frame.maxY + 23
            )
        } else {
            content_button.isHidden = false
            content_button.center = CGPoint(
                x: w / 2,
                y: content_label_detail.frame.maxY + 23
            )
        }
        
        if let view = content_custom as? UIView {
            view.frame = content_image.frame
            content_custom?.resize_subviews()
        }
    }
    // MARK: - Animation
    
    func show_animate() {
        animate_view.backgroundColor = back_view.backgroundColor
        animate_view.alpha = 0.5
        animate_view.frame = CGRect(
            x: (bounds.width - 32) / 2,
            y: (bounds.height - 32) / 2,
            width: 32,
            height: 32
        )
        
        UIView.animate(withDuration: 0.25, animations: {
            self.animate_view.alpha = 1
            self.animate_view.frame = self.back_view.frame
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, animations: {
                self.back_view.alpha = 1
            })
        })
    }
    
    func hide_animate() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.complete_block?(self)
            self.complete_block = nil
            self.button_action_block = nil
            self.removeFromSuperview()
            self.timer = nil
        })
    }
    
    // MARK: - Timer
    
    private var timer: DispatchSourceTimer?
    func run_timer(time: Int) {
        if time > 0 {
            var out_time = time
            timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 1), queue: DispatchQueue.main)
            timer?.schedule(wallDeadline: DispatchWallTime.now(), repeating: DispatchTimeInterval.seconds(1))
            
            timer?.setEventHandler(handler: { [weak self] in
                if out_time <= 0 {
                    self?.hide_animate()
                } else {
                    out_time -= 1
                }
            })
            timer?.resume()
        }
    }
}




// MARK: - ImageCache

extension WidgetView {
    
    struct ImageCache {
        static var _checkmark: UIImage?
        static var _cross: UIImage?
        static var _info: UIImage?
        
        static func image(type: WidgetViewImageType) -> UIImage {
            switch type {
            case .success:
                return checkmark
            case .error:
                return cross
            case .info:
                return info
            }
        }
        
        static var checkmark: UIImage {
            if let image = _checkmark {
                return image
            }
            else {
                UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
                ImageCache.draw(.success)
                _checkmark = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return _checkmark!
            }
        }
        static var cross: UIImage {
            if let image = _cross {
                return image
            }
            else {
                UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
                ImageCache.draw(.error)
                _cross = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return _cross!
            }
        }
        static var info: UIImage {
            if let image = _info {
                return image
            }
            else {
                UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
                ImageCache.draw(.info)
                _info = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return _info!
            }
        }
        
        
        static func draw(_ type: WidgetViewImageType) {
            let checkmarkShapePath = UIBezierPath()
            // draw circle
            checkmarkShapePath.move(to: CGPoint(x: 36, y: 18))
            checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 18), radius: 17.5, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
            checkmarkShapePath.close()
            
            switch type {
            case .success: // draw checkmark
                checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
                checkmarkShapePath.addLine(to: CGPoint(x: 16, y: 24))
                checkmarkShapePath.addLine(to: CGPoint(x: 27, y: 13))
                checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
                checkmarkShapePath.close()
            case .error: // draw X
                checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
                checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 26))
                checkmarkShapePath.move(to: CGPoint(x: 10, y: 26))
                checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 10))
                checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
                checkmarkShapePath.close()
            case .info:
                checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
                checkmarkShapePath.addLine(to: CGPoint(x: 18, y: 22))
                checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
                checkmarkShapePath.close()
                
                UIColor.white.setStroke()
                checkmarkShapePath.stroke()
                
                let checkmarkShapePath = UIBezierPath()
                checkmarkShapePath.move(to: CGPoint(x: 18, y: 27))
                checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 27), radius: 1, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
                checkmarkShapePath.close()
                
                UIColor.white.setFill()
                checkmarkShapePath.fill()
            }
            
            UIColor.white.setStroke()
            checkmarkShapePath.stroke()
        }
    }
    
}

// MARK: - Custom View

class WidgetViewCustomView: UIView, WidgetViewCustomProtocol {
    
    var data: [String : Any] = [:]
    
    func resize_subviews() {
        
    }
    
    func update_subviews() {
        
    }
    
}

class WidgetViewCustomWaitView: WidgetViewCustomView {
    
    var wait_view: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func resize_subviews() {
        wait_view.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    override func update_subviews() {
        addSubview(wait_view)
        wait_view.startAnimating()
    }
    
    
}
