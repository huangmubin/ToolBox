//
//  HintStatusBar.swift
//  ToolBoxProject
//
//  Created by Myron on 2017/4/20.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - Hint Bar

enum HintBarType {
    case text
    case loading
}

fileprivate protocol HintViewTextBarProtocol {
    var label: UILabel { get set }
}

fileprivate protocol HintViewColorBarProtocol {
    var colors: [UIColor] { get set }
}

public class HintBar {
    
    private let bar: HintStatusBar
    private let type: HintBarType
    init(_ type: HintBarType) {
        self.type = type
        switch type {
        case .text:
            bar = HintStatusTextBar(height: 20, time: 3)
        case .loading:
            bar = HintStatusLoadingBar(height: 20, time: 0)
        }
    }
    
    @discardableResult
    func show() -> HintBar {
        bar.showAnimation()
        return self
    }
    
    func clear() {
        HintStatusBar.pull(view: bar)
    }
    
    // MARK: View
    
    func height(_ value: CGFloat) -> HintBar {
        bar.height = value
        return self
    }
    
    func colors(_ value: [UIColor]) -> HintBar {
        if var bar = bar as? HintViewColorBarProtocol {
            bar.colors = value
        }
        return self
    }
    
    func centerColor(_ value: UIColor?) -> HintBar {
        bar.backgroundColor = UIColor.clear
        bar.centerLayer.backgroundColor = value?.cgColor
        if type == .loading {
            bar.updateContainer()
        }
        return self
    }
    
    func backgroundColor(_ value: UIColor?) -> HintBar {
        bar.backgroundColor = value
        bar.centerLayer.backgroundColor = UIColor.clear.cgColor
        return self
    }

    // MARK: Values
    
    func id(_ value: String) -> HintBar {
        bar.id = value
        return self
    }
    
    func time(_ value: Int) -> HintBar {
        bar.time = value
        return self
    }
    
    // MARK: Text
    
    func text(_ value: String) -> HintBar {
        switch type {
        case .text, .loading:
            if let bar = bar as? HintViewTextBarProtocol {
                bar.label.text = value
            }
        }
        return self
    }
    
    func textColor(_ value: UIColor) -> HintBar {
        switch type {
        case .text, .loading:
            if let bar = bar as? HintViewTextBarProtocol {
                bar.label.textColor = value
            }
        }
        return self
    }
    
    func textFont(_ value: UIFont) -> HintBar {
        switch type {
        case .text, .loading:
            if let bar = bar as? HintViewTextBarProtocol {
                bar.label.font = value
            }
        }
        return self
    }
    
    // MARK: Class Methods
    
    class func clear(id: String? = nil) {
        if let id = id {
            for view in HintStatusBar.views {
                if view.id == id {
                    HintStatusBar.pull(view: view)
                }
            }
        }
        else {
            for view in HintStatusBar.views {
                HintStatusBar.pull(view: view)
            }
        }
    }
    
}

// MARK: - Static Hint Status Bar

extension HintStatusBar {
    
    fileprivate static var views: [HintStatusBar] = []
    class func push(view: HintStatusBar) {
        views.append(view)
    }
    class func pull(view: HintStatusBar) {
        if let index = views.index(of: view) {
            views.remove(at: index)
        }
    }
    
    static let navigationDefaultColor = UIColor(red: 249.0 / 255.0, green: 249.0 / 255.0, blue: 249.0 / 255.0, alpha: 1)
    static let navigationBlackColor = UIColor(red: 79.0 / 255.0, green: 79.0 / 255.0, blue: 79.0 / 255.0, alpha: 1)
    
}

// MARK: - Hint Status Bar

public class HintStatusBar: UIView {
    
    // MARK: Values
    
    let edge: CGFloat = 70
    
    var rotateWindow: AutoRotateWindow!
    let centerLayer: CALayer = CALayer()
    
    var time: Int = 3
    var id: String = ""
    var height: CGFloat = 20 {
        didSet {
            self.rotateWindow.height = height
            self.rotateWindow.statusBarOrientationDidChanged()
            self.frame.size.height = height
            if self.frame.origin.y < 0 {
                self.frame.origin.y = -height
            }
            updateCenterLayerFrame()
        }
    }
    
    
    // MARK: Init
    
    @discardableResult
    public init(height: CGFloat = 20, time: Int = 3) {
        super.init(frame: CGRect(x: 0, y: -height, width: UIScreen.main.bounds.width, height: height))
        self.height = height
        self.time = time
        deploy()
        updateContainer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
        updateContainer()
    }
    
    func deploy() {
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChanged), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
        rotateWindow = AutoRotateWindow(height: self.bounds.height)
        rotateWindow.windowLevel = UIWindowLevelStatusBar
        rotateWindow.addSubview(self)
        
        centerLayer.frame = CGRect(x: edge, y: 0, width: self.bounds.width - edge * 2, height: self.bounds.height)
        centerLayer.cornerRadius = 4
        layer.addSublayer(centerLayer)
        
        self.backgroundColor = HintStatusBar.navigationDefaultColor
    }

    deinit {
        //print("\(self) Hint Status Bar is deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Update Views
    
    func updateContainer() {
        
    }
    
    func updateCenterLayerFrame() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.centerLayer.frame = CGRect(x: edge, y: 0, width: self.bounds.width - edge * 2, height: self.bounds.height)
        CATransaction.commit()
    }
    
    // MARK: Notification
    
    func statusBarOrientationDidChanged() {
        DispatchQueue.main.async {
            self.frame.size.width = UIScreen.main.bounds.width
            self.updateContainer()
            self.updateCenterLayerFrame()
        }
    }
    
    // MARK: Animation
    
    func showAnimation() {
        rotateWindow.makeKeyAndVisible()
        HintStatusBar.push(view: self)
        UIView.animate(withDuration: 0.25, animations: { 
            self.frame.origin.y = 0
        }, completion: { _ in
            self.run(time: self.time)
        })
    }
    
    func hideAnimation() {
        UIView.animate(withDuration: 0.25, animations: { 
            self.frame.origin.y = -self.bounds.height
        }, completion: { _ in
            self.timer?.cancel()
            self.timer = nil
            self.removeFromSuperview()
            self.rotateWindow = nil
            
            HintStatusBar.pull(view: self)
        })
    }
    
    // MARK: Timer
    
    var timer: DispatchSourceTimer?
    func run(time: Int) {
        if time <= 0 {
            return
        }
        var timeOut = time
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 1), queue: DispatchQueue.main)
        timer?.scheduleRepeating(wallDeadline: DispatchWallTime.now(), interval: DispatchTimeInterval.seconds(1))
        timer?.setEventHandler(handler: { [weak self] in
            if timeOut <= 0 {
                self?.hideAnimation()
            } else {
                timeOut -= 1
            }
        })
        timer?.resume()
    }
}

// MARK: - Hint Status Bar: Auto Rotate Window

extension HintStatusBar {
    
    public class AutoRotateWindow: UIWindow {
        
        // MARK: Values
        
        /// 屏幕宽度
        static let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        /// 屏幕高度
        static let screenHeight = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        
        var height: CGFloat = 20
        
        // MARK: Init
        
        public init(height: CGFloat) {
            super.init(frame: CGRect(x: 0, y: 0, width: AutoRotateWindow.screenWidth, height: height))
            self.height = height
            deploy()
        }
        
        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            deploy()
        }
        
        deinit {
            //print("\(self) Auto Rotate Window is deinit")
            NotificationCenter.default.removeObserver(self)
        }
        
        func deploy() {
            NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChanged), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
            statusBarOrientationDidChanged()
        }
        
        // MARK: Notification
        
        func statusBarOrientationDidChanged() {
            DispatchQueue.main.async {
                let iPhone = UIDevice.current.model.hasPrefix("iPhone")
                let height = self.height
                switch UIApplication.shared.statusBarOrientation {
                case .portrait:
                    if iPhone {
                        self.transform = CGAffineTransform(rotationAngle: 0)
                    }
                    self.frame = CGRect(
                        x: 0,
                        y: 0,
                        width: AutoRotateWindow.screenWidth,
                        height: height
                    )
                case .portraitUpsideDown:
                    if iPhone {
                        self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                        self.frame = CGRect(
                            x: 0,
                            y: AutoRotateWindow.screenHeight - height,
                            width: AutoRotateWindow.screenWidth,
                            height: height
                        )
                    }
                    else {
                        self.frame = CGRect(
                            x: 0,
                            y: 0,
                            width: AutoRotateWindow.screenWidth,
                            height: height
                        )
                    }
                case UIInterfaceOrientation.landscapeLeft:
                    if iPhone {
                        self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
                        self.frame = CGRect(
                            x: 0,
                            y: 0,
                            width: height,
                            height: AutoRotateWindow.screenHeight
                        )
                        self.center = CGPoint(
                            x: height / 2,
                            y: AutoRotateWindow.screenHeight / 2
                        )
                    }
                    else {
                        self.frame = CGRect(
                            x: 0,
                            y: 0,
                            width: AutoRotateWindow.screenWidth,
                            height: height
                        )
                    }
                case .landscapeRight:
                    if iPhone {
                        self.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                        self.frame = CGRect(
                            x: 0,
                            y: 0,
                            width: height,
                            height: AutoRotateWindow.screenHeight
                        )
                        self.center = CGPoint(
                            x: AutoRotateWindow.screenWidth - height / 2,
                            y: AutoRotateWindow.screenHeight / 2
                        )
                    }
                    else {
                        self.frame = CGRect(
                            x: 0,
                            y: 0,
                            width: AutoRotateWindow.screenWidth,
                            height: height
                        )
                    }
                default:break
                }
            }
        }
    }
}

// MARK: - Hint Status Text Bar

public class HintStatusTextBar: HintStatusBar, HintViewTextBarProtocol {
    
    // MARK: Value
    
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)
        return label
    }()
    
    override func deploy() {
        super.deploy()
        addSubview(label)
    }
    
    override func updateContainer() {
        label.frame = self.bounds
    }
    
}

// MARK: - Hint Status Loading Bar

public class HintStatusLoadingBar: HintStatusTextBar, HintViewColorBarProtocol {
    
    var loadings: [CALayer] = []
    var colorIndex: Int = 0
    var colors: [UIColor] = [
        UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1),
        UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1)
    ]
    
    override func deploy() {
        super.deploy()
        for _ in 0 ..< 6 {
            let subLayer = CALayer()
            subLayer.cornerRadius = 5
            layer.addSublayer(subLayer)
            loadings.append(subLayer)
        }
        startLoadingAnimation()
    }
    
    override func updateContainer() {
        super.updateContainer()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        var edge: CGFloat = 10
        if centerLayer.backgroundColor != nil && centerLayer.backgroundColor != UIColor.clear.cgColor {
            edge = self.edge
        }
        
        for i in 0 ..< 3 {
            loadings[i].frame = CGRect(x: edge + CGFloat(i) * 14, y: bounds.height / 2 - 5, width: 10, height: 10)
        }
        let offset = self.bounds.width - edge - 38
        for i in 0 ..< 3 {
            loadings[i + 3].frame = CGRect(x: offset + CGFloat(i) * 14, y: bounds.height / 2 - 5, width: 10, height: 10)
        }
        CATransaction.commit()
    }
    
    func startLoadingAnimation() {
        let loadingTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 1), queue: DispatchQueue.main)
        loadingTimer.scheduleRepeating(wallDeadline: DispatchWallTime.now(), interval: DispatchTimeInterval.milliseconds(500))
        loadingTimer.setEventHandler(handler: { [weak self] in
            if let view = self {
                switch view.colorIndex {
                case 0:
                    view.colorIndex = 1
                    view.loadings[0].backgroundColor = view.colors[0].cgColor
                    view.loadings[1].backgroundColor = view.colors[1].cgColor
                    view.loadings[2].backgroundColor = view.colors[1].cgColor
                    view.loadings[3].backgroundColor = view.colors[1].cgColor
                    view.loadings[4].backgroundColor = view.colors[1].cgColor
                    view.loadings[5].backgroundColor = view.colors[0].cgColor
                case 1:
                    view.colorIndex = 2
                    view.loadings[0].backgroundColor = view.colors[1].cgColor
                    view.loadings[1].backgroundColor = view.colors[0].cgColor
                    view.loadings[2].backgroundColor = view.colors[1].cgColor
                    view.loadings[3].backgroundColor = view.colors[1].cgColor
                    view.loadings[4].backgroundColor = view.colors[0].cgColor
                    view.loadings[5].backgroundColor = view.colors[1].cgColor
                case 2:
                    view.colorIndex = 0
                    view.loadings[0].backgroundColor = view.colors[1].cgColor
                    view.loadings[1].backgroundColor = view.colors[1].cgColor
                    view.loadings[2].backgroundColor = view.colors[0].cgColor
                    view.loadings[3].backgroundColor = view.colors[0].cgColor
                    view.loadings[4].backgroundColor = view.colors[1].cgColor
                    view.loadings[5].backgroundColor = view.colors[1].cgColor
                default: break
                }
            }
            else {
                loadingTimer.cancel()
            }
        })
        loadingTimer.resume()
    }
}
