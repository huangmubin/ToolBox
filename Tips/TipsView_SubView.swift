//
//  TipsView_SubView.swift
//  SwiftiOS
//
//  Created by Myron on 2017/12/15.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

extension TipsView {
    
    /** 提示视图的子视图 */
    class SubView: UIView {
        
        /** 父视图 */
        public var super_view: TipsView { return superview as! TipsView }
        
        /** 运行动画 */
        public func run() { }
        
        /** 更新视图尺寸并且返回 */
        @discardableResult public func update_size() -> CGRect {
            return self.bounds
        }
        
    }
    
}
