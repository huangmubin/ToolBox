//
//  Ex_View_Tips.swift
//  SwiftiOS
//
//  Created by Myron on 2017/12/15.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

extension UIView {
    
    var tip_view: TipsView? {
        for view in subviews {
            if let tip = view as? TipsView {
                return tip
            }
        }
        return nil
    }
    
    /** 弹出一个文本提示框，并在 3 秒后消失 */
    @discardableResult public func tips(note: String, dismiss_time: TimeInterval = 3) -> TipsView {
        let tip = TipsView()
        addSubview(tip)
        tip.view_label.text = note
        tip.update_size()
        tip.run()
        tip.dismiss_time = dismiss_time
        tip.run_dismiss()
        return tip
    }
    
    
    /** 弹出一个成功提示框，并在 3 秒后消失 */
    @discardableResult public func tips(success note: String, dismiss_time: TimeInterval = 3) -> TipsView {
        let tip = TipsView()
        addSubview(tip)
        tip.view_animate.type = .success
        tip.view_label.text = note
        tip.update_size()
        tip.run()
        tip.dismiss_time = dismiss_time
        tip.run_dismiss()
        return tip
    }
    
    /** 弹出一个失败提示框，并在 3 秒后消失 */
    @discardableResult public func tips(error note: String, dismiss_time: TimeInterval = 3) -> TipsView {
        let tip = TipsView()
        addSubview(tip)
        tip.view_animate.type = .error
        tip.view_label.text = note
        tip.update_size()
        tip.run()
        tip.dismiss_time = dismiss_time
        tip.run_dismiss()
        return tip
    }
    
    
}
