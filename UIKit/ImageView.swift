//
//  ImageView.swift
//  ToolBoxUIKit
//
//  Created by Myron on 2017/3/30.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class ImageView: UIImageView {
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        deploy()
    }
    override init(image: UIImage?) {
        super.init(image: image)
        deploy()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        deploy()
    }
    
    private func deploy() {
        mask = UIView()
        mask?.frame = bounds
        mask?.backgroundColor = UIColor.black
    }
    
    // MARK: - Size
    
    
    override var frame: CGRect {
        didSet {
            mask?.frame = bounds
        }
    }
    
    override var bounds: CGRect {
        didSet {
            mask?.frame = bounds
        }
    }

    // MARK: - Corner
    
    @IBInspectable
    var corner: CGFloat {
        set {
            mask?.layer.cornerRadius = newValue
        }
        get {
            return mask?.layer.cornerRadius ?? 0
        }
    }
    
    
}
