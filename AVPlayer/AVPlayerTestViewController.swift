//
//  AVPlayerTestViewController.swift
//  RangerCam2
//
//  Created by Myron on 2017/9/20.
//  Copyright © 2017年 黄穆斌. All rights reserved.
//

import UIKit

var avplayer_url = "" {
    didSet {
        print("avplayer_url : \(avplayer_url)")
    }
}

class AVPlayerTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player_view.play(url: avplayer_url)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player_view.player.pause()
        player_view.player = nil
        if let sub = player_view.layer.sublayers {
            for s in sub {
                s.removeFromSuperlayer()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back_action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var player_view: AVPlayerView!
    
    
}
