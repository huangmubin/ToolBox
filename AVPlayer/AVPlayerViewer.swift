//
//  AVPlayerViewer.swift
//  ShenLungCam
//
//  Created by Myron on 2017/10/26.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Other

enum AVPlayerViewerState {
    case loading
    case playing
    case pause
    case stop
    case end
    case error_input
    case error_item(AVPlayerItemStatus)
}

struct AVPlayerViewerTime {
    var duration: Double = 0
    var current: Double  = 0
    var progress: Double {
        if current == 0 {
            return 0
        } else if abs(current - duration) < 1 {
            return 1
        } else {
            return duration > 0 ? current / duration : 0
        }
    }
    
    func format(_ value: Double) -> String {
        func time(_ t: Int) -> String {
            return t >= 10 ? "\(t)" : "0\(t)"
        }
        let v = Int(value)
        return time(v / 60) + ":" + time(v % 60)
    }
    
    var duration_text: String { return format(duration) }
    var current_text: String { return format(current) }
    
    var duration_int: Int { return Int(duration) }
    var current_int: Int { return Int(current) }
}

protocol AVPlayerViewerDelegate: NSObjectProtocol {
    
    func avplayer_viewer_update(state: AVPlayerViewerState)
    func avplayer_viewer_update(time: Double)
    
}

// MARK: - AVPlayerViewer

class AVPlayerViewer: UIView {
    
    @IBInspectable var play_image: UIImage? = nil {
        didSet {
            play_button_state.play_image = play_image
        }
    }
    @IBInspectable var stop_image: UIImage? = nil{
        didSet {
            play_button_state.stop_image = stop_image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        init_deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init_deploy()
    }
    
    private func init_deploy() {
        addSubview(av_contrainer_view)
        deploy_timer()
        deploy_play_button()
        deploy_progress_view()
    }
    
    // MARK: - Delegate
    
    weak var delegate: AVPlayerViewerDelegate?
    
    // MARK: - State
    
    var state: AVPlayerViewerState = AVPlayerViewerState.stop {
        didSet {
            delegate?.avplayer_viewer_update(state: state)
            switch state {
            case .error_input, .error_item(_):
                state = .stop
            case .loading, .pause, .stop:
                play_button_state.state = .play
            case .playing:
                play_button_state.state = .stop
            case .end:
                state = .stop
                play_button_state.state = .play
            }
        }
    }
    
    var av_time: AVPlayerViewerTime = AVPlayerViewerTime()
    
    // MARK: - 当前播放项目
    
    var av_contrainer_view: UIView = UIView()
    var av_url: URL!
    var av_item: AVPlayerItem!
    var av_player: AVPlayer!
    var av_layer: AVPlayerLayer!
    
    // MARK: - 资源加载
    
    func load(url: URL) {
        print("AV Player Viewer: \(url)")
        av_url    = url
        av_item   = AVPlayerItem(url: url)
        //av_item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        av_player = AVPlayer(playerItem: av_item)
        av_layer  = AVPlayerLayer(player: av_player)
        av_layer.frame = self.bounds
        av_contrainer_view.layer.addSublayer(av_layer)
        state = .loading
    }

    func load(path: String) {
        if let url = URL(string: path) {
            load(url: url)
        } else {
            state = .error_input
        }
    }
    
    func load(file_path: String) {
        load(url: URL(fileURLWithPath: file_path))
    }
    
    // MARK: - 播放操作
    
    func play() {
        switch state {
        case .loading, .pause:
            av_player.play()
            state = .playing
        case .stop:
            if let url = av_url {
                load(url: url)
                switch state {
                case .loading:
                    av_player.play()
                    state = .playing
                default: break
                }
            } else {
                state = .error_input
            }
        default: break
        }
    }
    
    func pause() {
        av_player.pause()
        state = .pause
    }
    
    func stop() {
        av_item?.seek(to: CMTime(value: 0, timescale: 1))
        //av_item.removeObserver(self, forKeyPath: "status")
        av_layer.removeFromSuperlayer()
        av_player.pause()
        state = .stop
        av_item = nil
        self.setNeedsDisplay()
    }
    
    // MARK: - 播放控制
    
    /** 播放速度，0表示停止，1表示正常。 */
    var rate: Float {
        set { av_player.rate = newValue }
        get { return av_player.rate }
    }
    
    // MARK: - 截图操作
    
    /** 截取当前时间的图片画面, 时间为空则是当前时间，时间不为空，则是具体时间的10倍，比如第一秒是 10. */
    func image(time: Int?) -> UIImage? {
        if let asset = av_item?.asset {
            do {
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                var cm_timer = CMTime()
                var image_time: CMTime
                if let cut_time = time {
                    image_time = CMTime(value: CMTimeValue(cut_time), timescale: 10)
                }
                else {
                    image_time = av_item.currentTime()
                }
                let imageref = try generator.copyCGImage(at: image_time, actualTime: &cm_timer)
                return UIImage(cgImage: imageref)
            } catch { }
        }
        return nil
    }
    
    /** 截取当前时间的图片画面, 时间为空则是当前时间，时间不为空，则是具体时间的10倍，比如第一秒是 10. */
    func image_date(time: Int?) -> Data? {
        if let image = image(time: time) {
            return UIImagePNGRepresentation(image)
        }
        return nil
    }
    
    // MARK: - Observe
    
    /*
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let item = object as? AVPlayerItem {
            if keyPath == "status" {
                switch item.status {
                case .readyToPlay:
                    break
                case .failed:
                    state = .error_item(item.status)
                    log_message("observeValue item.status failed")
                case .unknown:
                    state = .error_item(item.status)
                    log_message("observeValue item.status failed")
                }
            }
        }
    }
    */
    
    
    // MARK: - Size
    
    override var frame: CGRect {
        didSet {
            update_size()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            update_size()
        }
    }
    
    private func update_size() {
        av_contrainer_view.frame = bounds
        av_layer?.frame = av_contrainer_view.bounds
        update_play_button_size()
        update_progress_view_size()
    }
    
    func update_contrainer_size(frame: CGRect) {
        av_contrainer_view.frame = frame
        av_layer?.frame = av_contrainer_view.bounds
    }
    
    // MARK: - Timer
    
    var timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.init(rawValue: 1), queue: DispatchQueue.main)
    var timer_can_update: Int = 0
    func deploy_timer() {
        timer.schedule(wallDeadline: DispatchWallTime.now(), repeating: DispatchTimeInterval.milliseconds(200))
//        timer.scheduleRepeating(wallDeadline: DispatchWallTime.now(), interval: DispatchTimeInterval.milliseconds(200))
        timer.setEventHandler(handler: { [weak self] in
            if (self?.timer_can_update ?? 1000) > 0 {
                self?.timer_can_update -= 1
            } else {
                if let av_item = self?.av_item, var av_time = self?.av_time {
                    if av_item.duration.seconds >= 0 && av_time.duration_int != Int(av_item.duration.seconds) {
                        self?.av_time.duration = av_item.duration.seconds
                        av_time.duration = av_item.duration.seconds
                        self?.progress_label_right.text = av_time.duration_text
                        self?.delegate?.avplayer_viewer_update(time: self!.av_time.progress)
                        //self?.log_message("currentTime: \(av_item.currentTime().seconds); duration: \(av_item.duration.seconds); progress: \(av_time.progress) \(av_time.duration_text) \(self?.progress_label_right.text)")
                    }
                    if av_item.currentTime().seconds >= 0 && av_time.current_int != Int(av_item.currentTime().seconds) {
                        self?.av_time.current = av_item.currentTime().seconds
                        av_time.current = av_item.currentTime().seconds
                        self?.progress_view.value = CGFloat(av_time.progress)
                        self?.progress_label_left.text = av_time.current_text
                        if av_time.progress == 1 {
                            self?.state = AVPlayerViewerState.end
                        }
                        self?.delegate?.avplayer_viewer_update(time: self!.av_time.progress)
                        //self?.log_message("currentTime: \(av_item.currentTime().seconds); duration: \(av_item.duration.seconds); progress: \(av_time.progress)")
                    }
                }
            }
            
            if let play_button_state = self?.play_button_state {
                switch play_button_state.state {
                case .stop:
                    if play_button_state.timer <= 0 {
                        self?.play_button_state.state = .hide
                    }
                    else {
                        self?.play_button_state.timer -= 1
                    }
                default: break
                }
            }
        })
        timer.resume()
    }
    
    // MARK: - Play Action
    
    enum AVPlayerViewerPlayButtonStateEnum {
        case play
        case stop
        case hide
    }
    
    struct AVPlayerViewerPlayButtonState {
        var timer: Int = 5
        
        var play_image: UIImage?
        var stop_image: UIImage?
        var hide_image: UIImage?
        
        var state = AVPlayerViewerPlayButtonStateEnum.play {
            didSet {
                switch state {
                case .play:
                    button?.setImage(play_image, for: .normal)
                    progress?.isHidden = false
                case .stop:
                    button?.setImage(stop_image, for: .normal)
                    progress?.isHidden = false
                case .hide:
                    button?.setImage(hide_image, for: .normal)
                    progress?.isHidden = true
                }
            }
        }
        weak var button: UIButton?
        weak var progress: UIView?
    }
    
    var play_button: UIButton = UIButton()
    var play_button_state = AVPlayerViewerPlayButtonState()
    
    @objc func play_aciton() {
        switch state {
        case .loading, .stop, .pause:
            play()
            play_button_state.timer = 8
            play_button_state.state = .stop
        case .playing:
            pause()
            play_button_state.state = .play
        default: break
        }
        
    }
    
    func deploy_play_button() {
        play_button.addTarget(self, action: #selector(play_aciton), for: .touchUpInside)
        addSubview(play_button)
        update_play_button_size()
        play_button_state.button = play_button
    }
    
    func update_play_button_size() {
        play_button.frame = CGRect(x: bounds.width / 3, y: bounds.height / 3, width: bounds.width / 3, height: bounds.height / 3)
    }
    
    // MARK: - Progress
    
    var progress_background_view = UIView()
    
    var progress_view: AVPlayerViewerProgressView = AVPlayerViewerProgressView()
    
    var progress_label_right = UILabel()
    var progress_label_left = UILabel()
    
    /** 0 - 1 */
    func progress(to: Double) {
        let time = av_time.duration * to
        av_item.seek(to: CMTime(value: CMTimeValue(time), timescale: 1))
    }
    
    func deploy_progress_view() {
        addSubview(progress_background_view)
        progress_background_view.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        progress_background_view.layer.cornerRadius = 4
        progress_background_view.addSubview(progress_view)
        progress_background_view.addSubview(progress_label_right)
        progress_background_view.addSubview(progress_label_left)
        progress_view.player_viewer = self
        
        progress_label_right.text = "00:00"
        progress_label_left.text = "00:00"
        progress_label_right.textAlignment = NSTextAlignment.center
        progress_label_left.textAlignment = NSTextAlignment.center
        progress_label_right.textColor = UIColor.white
        progress_label_left.textColor = UIColor.white
    }
    
    func update_progress_view_size() {
        let height = CGFloat(40)
        let label_w = CGFloat(60)
        progress_background_view.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
        progress_view.frame = CGRect(x: label_w, y: 0, width: bounds.width - label_w * 2, height: height)
        progress_label_left.frame = CGRect(x: 0, y: 0, width: label_w, height: height)
        progress_label_right.frame = CGRect(x: progress_background_view.bounds.width - label_w, y: 0, width: label_w, height: height)
    }
    
    // MARK: - Tools
    
    private func log_message(_ value: Any?) {
        print("AVPlayerViewer: " + String(describing: value))
    }
    
    
}

// MARK: - AVPlayerViewerProgressView

class AVPlayerViewerProgressView: UIView {
    
    weak var player_viewer: AVPlayerViewer?
    var pan_gesture: UIPanGestureRecognizer!
    
    var value: CGFloat {
        get {
            return CGFloat(player_viewer?.av_time.progress ?? 0)
        }
        set {
            move_layer(to: newValue)
            line_layer.strokeEnd = newValue
        }
    }
    
    // MARK: Layers
    
    var back_layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineCap = kCALineCapRound
        layer.lineWidth = 4
        layer.strokeColor = UIColor.darkGray.cgColor
        return layer
    }()
    var line_layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineCap = kCALineCapRound
        layer.lineWidth = 4
        layer.strokeColor = UIColor.white.cgColor
        return layer
    }()
    var move_layer: CALayer = {
        let layer = CALayer()
        layer.cornerRadius = 4
        layer.backgroundColor = UIColor.white.cgColor
        layer.shadowOpacity = 1
        return layer
    }()
    
    // MARK: - Init
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        deploy()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    
    private func deploy() {
        layer.addSublayer(back_layer)
        layer.addSublayer(line_layer)
        layer.addSublayer(move_layer)
        
        pan_gesture = UIPanGestureRecognizer(target: self, action: #selector(pan_gesture_action(_:)))
    }
    
    // MARK: - Frame
    
    override var frame: CGRect {
        didSet {
            update_frame()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            update_frame()
        }
    }
    
    func update_frame() {
        let path = UIBezierPath()
        path.move(to: CGPoint(
            x: 0,
            y: bounds.height / 2
        ))
        path.addLine(to: CGPoint(
            x: bounds.width,
            y: bounds.height / 2
        ))
        
        back_layer.path = path.cgPath
        line_layer.path = path.cgPath
        line_layer.strokeEnd = value
        
        move_layer.frame = CGRect(
            x: bounds.width * value - 2,
            y: bounds.height / 4,
            width: 4,
            height: bounds.height  / 2
        )
    }
    
    func move_layer(to: CGFloat) {
        var x = bounds.width * to - 2
        x = x <= -2 ? -2 : x
        x = x >= bounds.width - 2 ? bounds.width - 2 : x
        move_layer.frame = CGRect(
            x: bounds.width * to - 2,
            y: bounds.height / 4,
            width: 4,
            height: bounds.height  / 2
        )
    }
    
    // MARK: - Touch
    
    @objc func pan_gesture_action(_ sender: UIPanGestureRecognizer) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player_viewer?.timer_can_update = Int.max

        let x = touches.first!.location(in: self).x
        let v = x / bounds.width
        move_layer(to: v)
        line_layer.strokeEnd = v
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let x = touches.first!.location(in: self).x
        let v = x / bounds.width
        move_layer(to: v)
        line_layer.strokeEnd = v

        if let viewer = player_viewer {
            let time = viewer.av_time.duration * Double(v)
            viewer.progress_label_left.text = viewer.av_time.format(time)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let x = touches.first!.location(in: self).x
        let v = x / bounds.width
        move_layer(to: v)
        line_layer.strokeEnd = v
        player_viewer?.timer_can_update = 20

        if let viewer = player_viewer {
            let time = viewer.av_time.duration * Double(v)
            viewer.av_item.seek(to: CMTime(value: CMTimeValue(time), timescale: 1))
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        player_viewer?.timer_can_update = 0
    }
    
}
