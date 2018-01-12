//
//  AVPlayerView.swift
//  RangerCam2
//
//  Created by Myron on 2017/9/20.
//  Copyright © 2017年 黄穆斌. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerView: UIView {

    func play(url: String) {
        let item = AVPlayerItem(url: URL(string: url)!)
        item.addObserver(
            self,
            forKeyPath: "loadedTimeRanges",
            options: NSKeyValueObservingOptions.new,
            context: nil
        )
        item.addObserver(
            self,
            forKeyPath: "status",
            options: NSKeyValueObservingOptions.new,
            context: nil
        )
        
        self.player = AVPlayer(playerItem: item)
        
        let player_layer = AVPlayerLayer(player: player)
        //AVLayerVideoGravityResizeAspectFill
        //player_layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        player_layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player_layer.contentsScale = UIScreen.main.scale
        player_layer.frame = self.bounds
        self.layer.addSublayer(player_layer)
    }
    
    var player: AVPlayer!
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let item = object as? AVPlayerItem {
            if keyPath == "status" {
                if item.status == AVPlayerItemStatus.readyToPlay {
                    self.player.play()
                }
                else {
                    print("observeValue(forKeyPath load error")
                }
                
                switch item.status {
                case .readyToPlay:
                    print("observeValue(forKeyPath keyPa readyToPlay")
                case .failed:
                    print("observeValue(forKeyPath keyPa failed")
                case .unknown:
                    print("observeValue(forKeyPath keyPa unknown")
                }
            }
            if keyPath == "loadedTimeRanges" {
                print("observeValue(forKeyPath  time \(item.currentTime())")
            }
        }
    }
//    
//    //监听回调
//    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
//    {
//    AVPlayerItem *playerItem = (AVPlayerItem *)object;
//    
//    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
//    
//    }else if ([keyPath isEqualToString:@"status"]){
//    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
//    NSLog(@"playerItem is ready");
//    [self.avPlayer play];
//    } else{
//    NSLog(@"load break");
//    }
//    }
//    }
//    
//    作者：阿聪o
//    链接：http://www.jianshu.com/p/de418c21d33c
//    來源：简书
//    著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
    
}
