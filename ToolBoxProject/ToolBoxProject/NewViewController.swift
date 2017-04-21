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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("New View Controller: View Did Appear.")
    }
    
    deinit {
        print("New View Controller: \(self) is deinit.")
    }
    
}
