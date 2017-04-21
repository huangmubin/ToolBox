//
//  NewViewController.swift
//  ToolBoxProject
//
//  Created by Myron on 2017/4/21.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class NewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = alert
            .textField(placeholder: "test 1", hanlder: nil)
            .changed({
                print("test1 = \(String(describing: $0.text))")
            })
            .textField(placeholder: "test 2", hanlder: nil)
            .changed({
                print("test2 = \(String(describing: $0.text))")
            })
            .action(title: "text", handler: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("New View Controller: View Did Appear.")
    }
    
    deinit {
        print("New View Controller: \(self) is deinit.")
    }
    
    let alert = Alert(title: "Test", message: "test message!")
    
    @IBAction func test_action_center(_ sender: UIButton) {
        alert.show(self)
    }
}
