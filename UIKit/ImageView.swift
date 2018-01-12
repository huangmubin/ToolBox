//
//  ImageView.swift
//  SwiftiOS
//
//  Created by Myron on 2017/12/15.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class ImageView: UIImageView {
    
    /** layer cornerRedius */
    @IBInspectable var corner: CGFloat = 0 {
        didSet {
            mask?.layer.cornerRadius = corner
            layer.cornerRadius = corner
        }
    }
    
    /** layer borderWidth */
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    /** layer borderColor */
    @IBInspectable var borderColor: UIColor? = nil {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
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
    
}
