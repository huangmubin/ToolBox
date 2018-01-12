//
//  TipsView_Label.swift
//  SwiftiOS
//
//  Created by Myron on 2017/12/15.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

extension TipsView {
    
    class Label: TipsView.SubView {
        
        /** Label view */
        public let label: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            return label
        }()
        /** Title */
        public var text: String? {
            get { return label.text }
            set { label.text = newValue }
        }
        
        // MARK: - Init
        
        init() {
            super.init(frame: UIScreen.main.bounds)
            deploy()
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            deploy()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            deploy()
        }
        
        private func deploy() {
            addSubview(label)
            label.alpha = 0
        }
        
        // MARK: - Override
        
        /** 运行动画 */
        override func run() {
            self.label.alpha = 0
            UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseIn, animations: {
                self.label.alpha = 1
            }, completion: nil)
        }
        
        /** 更新视图尺寸并且返回 */
        @discardableResult override func update_size() -> CGRect {
            label.textColor = super_view.tint_color
            label.bounds.size.width = super_view.bounds.width / 2
            label.sizeToFit()
            self.bounds = CGRect(
                x: 0, y: 0,
                width: label.bounds.width + 20,
                height: label.bounds.height + 20
            )
            label.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
            return self.bounds
        }
        
    }
    
}
