//
//  NavigationController.swift
//  BinaryCalculator
//
//  Created by Myron on 2018/1/12.
//  Copyright © 2018年 Myron. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if visibleViewController is UIAlertController {
            if viewControllers.count >= 2 {
                return viewControllers[viewControllers.count - 2].supportedInterfaceOrientations
            } else {
                return UIInterfaceOrientationMask.all
            }
        } else {
            return self.visibleViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.all
        }
    }
    
}
