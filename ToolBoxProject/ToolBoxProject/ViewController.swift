//
//  ViewController.swift
//  ToolBoxProject
//
//  Created by Myron on 2017/4/20.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        HintBar(.text).text("Test!").centerColor(HintStatusBar.navigationDefaultColor).show()
        HintBar(.loading).text("Test!").centerColor(HintStatusBar.navigationDefaultColor).colors([UIColor.red, UIColor.white]).time(3).show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

