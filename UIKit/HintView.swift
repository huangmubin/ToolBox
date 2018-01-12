//
//  HintView.swift
//  HintView
//
//  Created by Myron on 2017/4/14.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - Extension View

extension UIView {
    
    func hint(text value: String, inDown: Bool = false) {
        let hint: HintView = inDown ? DownHintView() : HintView()
        hint.show(text: value, inView: self)
    }
    
    func hint(success value: String?, inDown: Bool = false) {
        let hint: HintView = inDown ? DownHintView() : HintView()
        hint.show(success: value ?? NSLocalizedString("Success", comment: "Success"), inView: self)
    }
    
    func hint(error value: String?, inDown: Bool = false) {
        let hint: HintView = inDown ? DownHintView() : HintView()
        hint.show(error: value ?? NSLocalizedString("Error", comment: "Error"), inView: self)
    }
    
    func hint(info value: String?, inDown: Bool = false) {
        let hint: HintView = inDown ? DownHintView() : HintView()
        hint.show(info: value ?? NSLocalizedString("Info", comment: "Info"), inView: self)
    }
    
    func hint(loading value: String?, inDown: Bool = false) {
        let hint: HintView = inDown ? DownHintView() : HintView()
        hint.show(loading: value ?? NSLocalizedString("Success", comment: "Success"), inView: self)
    }
    
    func hint(custom value: String, image: UIImage, inDown: Bool = false) {
        let hint: HintView = inDown ? DownHintView() : HintView()
        hint.show(custom: value, image: image, inView: self)
    }
    
    func hint(success value: String?, inDown: Bool = false, time: Int) {
        let hint: HintView = inDown ? DownHintView() : HintView()
        hint.show(custom: value ?? NSLocalizedString("Success", comment: "Success"), images: [HintView.ImageCache.checkmark], duration: 0, inView: self, time: time)
    }
    
    func hint(custon value: String, images: [UIImage], duration: TimeInterval, time: Int = 0, inDown: Bool = false) {
        let hint: HintView = inDown ? DownHintView() : HintView()
        hint.show(custom: value, images: images, duration: duration, inView: self, time: time)
    }
    
    func hintClear(long: Bool = false) {
        for sub in subviews {
            if let view = sub as? HintView {
                if long {
                    if view.timer == nil {
                        view.dismiss()
                    }
                }
                else {
                    view.dismiss()
                }
            }
        }
    }
    
}

// MARK: - Hint Type

extension HintView {
    
    enum HintType {
        case text(String)
        case success(String?)
        case error(String?)
        case info(String?)
        case loading(String?)
        case images([UIImage], String?, CGSize)
    }
    
}

// MARK: - Hint View

class HintView: UIView {
    
    let label = UILabel()
    let imageview  = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    /// 显示时长
    var showTime: Int = 3
    /// 图片大小
    var imageSize: CGSize = CGSize(width: 36, height: 36)
    
    // MARK: - Init
    
    init() {
        super.init(frame: CGRect.zero)
        deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func deploy() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        self.layer.cornerRadius = 16
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize.zero
        
        label.textColor = UIColor.white
        label.numberOfLines = 0
        addSubview(label)
        
        addSubview(imageview)
        imageview.isHidden = true
        
        addSubview(activity)
        activity.hidesWhenStopped = true
        activity.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientation), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
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
    
    // MARK: Timer
    
    fileprivate var timer: DispatchSourceTimer?
    fileprivate func run(time: Int) {
        if time <= 0 {
            return
        }
        var timeOut = time
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 1), queue: DispatchQueue.main)
        timer?.schedule(wallDeadline: DispatchWallTime.now(), repeating: DispatchTimeInterval.seconds(1))
        
        timer?.setEventHandler(handler: { [weak self] in
            if timeOut <= 0 {
                self?.dismiss()
            } else {
                timeOut -= 1
            }
        })
        timer?.resume()
    }
    
    // MARK: Animation
    
    func dismiss() {
        self.timer?.cancel()
        self.timer = nil
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.activity.stopAnimating()
            self.removeFromSuperview()
        })
    }
    
    func display(inView view: UIView) {
        self.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        self.alpha = 0
        view.addSubview(self)
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1
        })
    }
    
    // MARK: Size
    
    func updateSubView(width: CGFloat) {
        updateText(width: width)
        
        if label.text?.isEmpty == false {
            bounds = CGRect(x: 0, y: 0, width: max(imageSize.width + 30, label.bounds.width + 30), height: max(imageSize.height + 30, label.bounds.height + 72))
            imageview.center = CGPoint(x: bounds.width / 2, y: imageview.bounds.height / 2 + 15)
            activity.center = imageview.center
            label.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2 + imageview.bounds.height / 2 + 8)
        }
        else {
            bounds = CGRect(x: 0, y: 0, width: imageSize.width + 30, height: imageSize.height + 30)
            imageview.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            activity.center = imageview.center
        }
    }
    
    
    func updateText(width: CGFloat) {
        label.frame = CGRect(x: 0, y: 0, width: width * 0.4, height: 1000)
        label.sizeToFit()
        if label.bounds.width * 2 < label.bounds.height {
            label.frame = CGRect(x: 0, y: 0, width: width * 0.8, height: 1000)
            label.sizeToFit()
        }
    }
    
}

extension HintView {
    
    
    func show(text: String, inView view: UIView) {
        let w = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        
        label.text = text
        updateText(width: w)
        
        self.bounds = CGRect(x: 0, y: 0, width: label.bounds.width + 30, height: label.bounds.height + 20)
        label.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        display(inView: view)
        run(time: 3)
    }
    
    func show(success text: String, inView view: UIView) {
        show(image: HintView.ImageCache.checkmark, text: text, inView: view)
    }
    
    func show(error text: String, inView view: UIView) {
        show(image: HintView.ImageCache.cross, text: text, inView: view)
    }
    
    func show(info text: String, inView view: UIView) {
        show(image: HintView.ImageCache.info, text: text, inView: view)
    }
    
    func show(custom text: String, image: UIImage, inView view: UIView) {
        show(image: image, text: text, inView: view)
    }
    
    func show(custom text: String, images: [UIImage], duration: TimeInterval, inView view: UIView, time: Int) {
        imageview.animationDuration = duration
        imageview.animationImages = images
        imageview.animationRepeatCount = 10000
        show(image: images[0], text: text, inView: view, time: time)
        imageview.startAnimating()
    }
    
    func show(image: UIImage, text: String, inView view: UIView, time: Int = 3) {
        imageview.image = image
        label.text = text
        
        imageview.isHidden = false
        activity.isHidden = true
        
        imageview.frame = CGRect(origin: CGPoint.zero, size: imageSize)
        updateSubView(width: view.bounds.width)
        
        display(inView: view)
        run(time: time)
    }
    
    func show(loading text: String, inView view: UIView) {
        label.text = text
        
        imageview.isHidden = true
        activity.isHidden = false
        activity.startAnimating()
        
        imageview.frame = CGRect(origin: CGPoint.zero, size: imageSize)
        updateSubView(width: view.bounds.width)
        
        display(inView: view)
    }
    
}

// MARK: - Images

extension HintView {
    
    class func draw(_ type: HintType) {
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
        default:break
        }
        
        UIColor.white.setStroke()
        checkmarkShapePath.stroke()
    }
    
    
    struct ImageCache {
        static var _checkmark: UIImage?
        static var _cross: UIImage?
        static var _info: UIImage?
        
        static var checkmark: UIImage {
            if let image = _checkmark {
                return image
            }
            else {
                UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
                HintView.draw(.success(nil))
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
                HintView.draw(.error(nil))
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
                HintView.draw(.info(nil))
                _info = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return _info!
            }
        }
    }
    
}

// MARK: - Down Hint View

class DownHintView: HintView {
    
    override func dismiss() {
        self.timer?.cancel()
        let y = self.bounds.height / 2 + (self.superview?.bounds.height ?? 0) + 4
        UIView.animate(withDuration: 0.25, animations: {
            self.center.y = y
        }, completion: { _ in
            self.activity.stopAnimating()
            self.removeFromSuperview()
        })
    }
    
    override func display(inView view: UIView) {
        let y = view.bounds.height - self.bounds.height / 2 - 10
        self.center = CGPoint(x: view.bounds.width / 2, y: y + self.bounds.height + 14)
        self.layer.cornerRadius = 10
        view.addSubview(self)
        UIView.animate(withDuration: 0.25, animations: {
            self.center.y = y
        })
    }
    
    override func updateSubView(width: CGFloat) {
        updateText(width: width)
        
        if label.text?.isEmpty == false {
            bounds = CGRect(x: 0, y: 0, width: imageSize.width + 38 + label.bounds.width, height: max(imageSize.height + 20, label.bounds.height + 20))
            imageview.center = CGPoint(x: imageSize.width / 2 + 15, y: bounds.height / 2)
            activity.center = imageview.center
            label.center = CGPoint(x: bounds.width / 2 + imageSize.width / 2 + 8, y: bounds.height / 2)
        }
        else {
            bounds = CGRect(x: 0, y: 0, width: imageSize.width + 40, height: imageSize.height + 20)
            imageview.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            activity.center = imageview.center
        }
    }
    
    override func updateText(width: CGFloat) {
        label.frame = CGRect(x: 0, y: 0, width: width * 0.8 - imageSize.width - 38, height: 1000)
        label.sizeToFit()
    }
}

