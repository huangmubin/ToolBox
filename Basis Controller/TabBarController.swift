//
//  TabBarController.swift
//  BinaryCalculator
//
//  Created by Myron on 2018/1/12.
//  Copyright © 2018年 Myron. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientation_changed),
            name: .UIApplicationDidChangeStatusBarOrientation,
            object: nil
        )
    }
    
    // MARK: - Orientation supporet
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let navigation = self.selectedViewController as? UINavigationController {
            if let interface = navigation.viewControllers.first?.supportedInterfaceOrientations {
                return interface
            }
        }
        return self.selectedViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.all
    }
    
    // MARK: - Orientation Observer
    
    @objc private func orientation_changed() {
        DispatchQueue.main.async {
            self.orientation_changed_action()
        }
    }
    
    @IBInspectable var auto_hide_when_landscape: Bool = false
    private var tab_height: CGFloat = 0
    /** Auto hide the tab bar */
    func orientation_changed_action() {
        if auto_hide_when_landscape {
            if tab_height == 0 {
                tab_height = view.subviews[0].frame.height
            }
            if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
                view.subviews[0].frame = CGRect(x: 0, y: 0, width: view.subviews[0].frame.width, height: tab_height)
                tabBar.isHidden = false
            } else {
                view.subviews[0].frame = CGRect(x: 0, y: 0, width: view.subviews[0].frame.width, height: 0)
                tabBar.isHidden = true
            }
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let appear_controller = viewController as? ViewController {
            if appear_controller.tab_controller_will_appear() {
                (tabBarController.selectedViewController as? ViewController)?.tab_controller_disappear()
                return true
            } else {
                return false
            }
        }
        if let appear_controller = viewController as? TableViewController {
            if appear_controller.tab_controller_will_appear() {
                (tabBarController.selectedViewController as? ViewController)?.tab_controller_disappear()
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        (viewController as? ViewController)?.tab_controller_appear()
        (viewController as? TableViewController)?.tab_controller_appear()
    }
}
