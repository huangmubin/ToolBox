//
//  Extension_CGRect.swift
//  Quoridor
//
//  Created by Myron on 2017/3/24.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

extension CGRect {

    func zoom(_ size: CGFloat) -> CGRect {
        return CGRect(
            x: origin.x + size,
            y: origin.y + size,
            width: width - size * 2,
            height: height - size * 2
        )
    }

}
