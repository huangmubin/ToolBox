//
//  TipsView_Background.swift
//  SwiftiOS
//
//  Created by Myron on 2017/12/15.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

extension TipsView {
    
    class Background: TipsView.SubView {
        
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
            self.layer.cornerRadius = 8
            self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.layer.shadowOpacity = 1
            self.layer.shadowOffset = CGSize.zero
            self.alpha = 0
        }
        
        // MARK: - Override
        
        override func run() {
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 1
            })
        }
        
        @discardableResult override func update_size() -> CGRect {
            self.bounds = CGRect(
                x: 0, y: 0,
                width: max(max(super_view.view_animate.bounds.width, super_view.view_label.bounds.width), 100) + 20,
                height: super_view.view_animate.bounds.height + super_view.view_label.bounds.height + 20
            )
            return self.bounds
        }
    }
    
}
