//
//  TipsView.swift
//  SwiftiOS
//
//  Created by Myron on 2017/12/15.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

public class TipsView: UIView {

    // MARK: - Sub Views
    
    /** 提示框的背景视图 */
    var view_background: Background = Background()
    /** 动画视图 */
    var view_animate: Animate = Animate()
    /** 文本视图 */
    var view_label: Label = Label()
    
    // MARK: - Values
    
    /** 父视图的大小 */
    public var super_bounds: CGRect { return superview!.bounds }
    
    /** 动画线条的颜色 */
    public var tint_color: UIColor = UIColor.white
    
    /** 页面消失时间 */
    public var dismiss_time: TimeInterval = 3
    
    // MARK: - Init
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        init_deploy()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        init_deploy()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init_deploy()
    }
    
    private func init_deploy() {
        addSubview(view_background)
        addSubview(view_animate)
        addSubview(view_label)
    }
    
    // MARK: - Size
    
    /** 更新子视图的位置 */
    public func update_size() {
        if let super_view = superview {
            self.backgroundColor = UIColor.white
            
            self.frame = super_view.bounds
            let center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
            
            let _ = self.view_label.update_size()
            let _ = self.view_animate.update_size()
            let _ = self.view_background.update_size()
            
            self.view_label.center = CGPoint(
                x: center.x,
                y: center.y + self.view_animate.bounds.height / 2
            )
            
            self.view_animate.center = CGPoint(
                x: center.x,
                y: self.view_label.frame.origin.y - self.view_animate.bounds.height / 2
            )
            
            self.view_background.center = center
            
            self.view_background.update_size()
        }
    }
    
    /** 运行动画 */
    public func run() {
        self.view_label.run()
        self.view_animate.run()
        self.view_background.run()
    }
    
    // MARK: - Timer
    
    /** 启动消失延时 */
    private var timer: DispatchSourceTimer?
    private var dismiss_time_temp: TimeInterval = 0
    public func run_dismiss() {
        dismiss_time_temp = dismiss_time
        if self.dismiss_time_temp > 0 {
            timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 1), queue: DispatchQueue.main)
            timer?.schedule(wallDeadline: DispatchWallTime.now(), repeating: DispatchTimeInterval.seconds(1))
            
            timer?.setEventHandler(handler: { [weak self] in
                if (self?.dismiss_time_temp ?? 0) <= 0 {
                    self?.dismiss()
                } else {
                    self?.dismiss_time_temp -= 1
                }
            })
            timer?.resume()
        }
    }
    
    public func dismiss() {
        self.dismiss_time_temp = 0
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.alpha = 0
        }, completion: {  [weak self] _ in
            self?.timer?.cancel()
            self?.timer = nil
            self?.removeFromSuperview()
        })
    }
}
