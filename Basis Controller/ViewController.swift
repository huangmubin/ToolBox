//
//  ViewController.swift
//  BinaryCalculator
//
//  Created by Myron on 2018/1/12.
//  Copyright © 2018年 Myron. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Appearing
    
    /** is appearing controller in the window */
    var is_appearing_controller: Bool = false
    
    // MARK: - Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientation_will_change),
            name: .UIApplicationWillChangeStatusBarOrientation,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientation_changed),
            name: .UIApplicationDidChangeStatusBarOrientation,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboard_will_change_frame(_:)),
            name: .UIKeyboardWillChangeFrame,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        is_appearing_controller = true
        switch (supportedInterfaceOrientations, UIDevice.current.orientation) {
        case (.all, _): break
        case (.portrait, .landscapeLeft), (.portrait, .landscapeRight):
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIApplication.shared.statusBarOrientation = .portrait
        case (.landscape, .portrait):
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            UIApplication.shared.statusBarOrientation = .landscapeLeft
        default: break
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        is_appearing_controller = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Orientation supporet
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    // MARK: - Status bar
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // MARK: - Orientation Observer
    
    @objc private func orientation_changed() {
        DispatchQueue.main.async {
            self.orientation_changed_action()
        }
    }
    
    @objc private func orientation_will_change() {
        DispatchQueue.main.async {
            self.orientation_will_change_action()
        }
    }
    
    /** Override: Call when orientation changed at main queue */
    func orientation_changed_action() { }
    
    /** Override: Call when orientation will change at main queue */
    func orientation_will_change_action() { }
    
    // MARK: - Keyboard Observer
    
    @objc func keyboard_will_change_frame(_ notification: Notification) {
        if let info = notification.userInfo {
            if let rect = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                self.keyboard_will_change_frame(keyboard: rect.cgRectValue)
            }
        }
    }
    
    /** keyboard will change to the new rect */
    func keyboard_will_change_frame(keyboard rect: CGRect) { }
    
    // MARK: - Tab Changed: work with the TabBarController
    
    /** tab bar controller will appear this controller */
    func tab_controller_will_appear() -> Bool {
        return true
    }
    
    /** tab bar controller appear this controller */
    func tab_controller_appear() {
        is_appearing_controller = true
    }
    
    /** tab bar controller disappear this controller */
    func tab_controller_disappear() {
        is_appearing_controller = false
    }
    
}
