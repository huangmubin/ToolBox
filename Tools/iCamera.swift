//
//  iPhoneCamera.swift
//  Eyeglass
//
//  Created by Myron on 2017/11/1.
//  Copyright © 2017年 Myron. All rights reserved.
//
/*
 需要在 info.plist 中添加相机权限以及图片权限
 Privacy - Camera Usage Description
 Privacy - Photo Library Usage Description
 Privacy - Microphone Usage Description
 */
import UIKit
import AVFoundation
import Photos

class iCamera: UIView, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, CAAnimationDelegate {

    /** 地址 */
    var video_temp_url = URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/iCamera_temp_video_file.mp4")
    
    /** 内容视图 */
    let container_view = UIView()
    
    /** 确定方向 */
    var device_position: AVCaptureDevice.Position = .back
    
    /** 控制会话 */
    var session: AVCaptureSession = AVCaptureSession()
    
    /** 输入设备 */
    var device: AVCaptureDevice?
    
    /** 音频输入设备 */
    var audio_device: AVCaptureDevice?
    
    /** 输入源 */
    var device_input: AVCaptureDeviceInput?
    
    /** 音频输入源头 */
    var audio_device_input: AVCaptureDeviceInput?
    
    /** 图像输出 */
    var photo_output: AVCapturePhotoOutput = AVCapturePhotoOutput()
    
    /** 视频输出 */
    var moive_file_output: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    
    /** 预览画面 */
    var preview_layer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Init
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        init_deploy()
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
        addSubview(container_view)
        container_view.frame = bounds
        self.backgroundColor = UIColor.clear
        object_timer()
    }
    
    var device_focus_point_of_interest: CGPoint = CGPoint.zero
    var update_focus_time: Int = 10
    func object_timer() {
        DispatchQueue.delay(time: 0.5, run: { [weak self] in
            if let point = self?.device?.focusPointOfInterest, let focus = self?.device_focus_point_of_interest {
                if focus != point {
                    self?.device_focus_point_of_interest = point
                    self?.camera_focus_animation_device(point: point)
                }
            }
            
            self?.update_focus_time -= 1
            if (self?.update_focus_time ?? 1) < 0 {
                if let weak_self = self {
                    let point = CGPoint(x: weak_self.bounds.width / 2, y: weak_self.bounds.height / 2)
                    self?.focus_on(point: point)
                    self?.update_focus_time = 10
                }
            }
            
            self?.object_timer()
        })
    }
    
    // MARK: - Frame
    
    override var frame: CGRect {
        didSet {
            reset_size()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            reset_size()
        }
    }
    
    private func reset_size() {
        container_view.frame = bounds
        preview_layer?.frame = bounds
    }
    
    // MARK: - Preview Layer
    
    /** 获取相机输入 */
    @discardableResult
    func deploy_camera_preview_layer() -> Bool {
        device = AVCaptureDevice.default(for: AVMediaType.video)
        audio_device = AVCaptureDevice.default(for: AVMediaType.audio)
        if device == nil || audio_device == nil {
            return false
        }
        
        do {
            device_input = try AVCaptureDeviceInput(device: device!)
            audio_device_input = try AVCaptureDeviceInput(device: audio_device!)
        } catch {
            log_message("init_deploy device_input error \(String(describing: error))")
            return false
        }
        
        // 连接输入与输出会话
        if session.canAddInput(device_input!) &&
            session.canAddOutput(photo_output) &&
            session.canAddInput(audio_device_input!) &&
            session.canAddOutput(moive_file_output) {
            session.addInput(device_input!)
            session.addOutput(photo_output)
            session.addInput(audio_device_input!)
            session.addOutput(moive_file_output)
        }
        else {
            return false
        }
        
        // 预览画面
        preview_layer?.removeFromSuperlayer()
        preview_layer = AVCaptureVideoPreviewLayer(session: session)
        container_view.layer.addSublayer(preview_layer!)
        return true
    }
    
    // MARK: - 拍照
    
    /** 截图回调 */
    var photo_complete: ((UIImage?, Data?, Error?) -> Void)?
    
    /** 截图 */
    func take_photo(complete: ((UIImage?, Data?, Error?) -> Void)?) {
        self.photo_complete = complete
        let sesttings: AVCapturePhotoSettings
        if #available(iOS 11.0, *) {
            sesttings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        } else {
            sesttings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])
        }
        photo_output.capturePhoto(with: sesttings, delegate: self)
    }
    
    /** AVCapturePhotoCaptureDelegate 图片抓取回调 */
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let buffer = photoSampleBuffer {
            if let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                if let image = UIImage(data: data) {
                    if let complete = self.photo_complete {
                        complete(image, data, nil)
                        self.photo_complete = nil
                    }
                    else {
                        iCamera.request_photo_authorization(complete: {
                            if $0 {
                                PHPhotoLibrary.shared().performChanges({
                                    let _ = PHAssetChangeRequest.creationRequestForAsset(from: image)
                                }, completionHandler: { (result, error) in
                                    self.log_message("photoOutput didFinishProcessingPhoto: result = \(result), error = \(String(describing: error))")
                                })
                            }
                        })
                    }
                    return
                }
            }
        }
        self.photo_complete?(nil, nil, error)
        self.photo_complete = nil
    }
    
    // MARK: - 录像
    
    /** 是否在录像状态 */
    var is_recording: Bool {
        return moive_file_output.isRecording
    }
    
    /** 录像回调 */
    var record_complete: ((URL?, Error?) -> Void)?
    
    /** 录像 */
    func start_record() {
        if !is_recording {
            moive_file_output.startRecording(to: video_temp_url, recordingDelegate: self)
        }
    }
    
    /** 停止录像 */
    func stop_record(complete: ((URL?, Error?) -> Void)?) {
        if is_recording {
            record_complete = complete
            moive_file_output.stopRecording()
        }
        else {
            complete?(nil, NSError(domain: "没有在录像中", code: 400, userInfo: nil))
        }
    }
    
    /** AVCaptureFileOutputRecordingDelegate */
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    /** AVCaptureFileOutputRecordingDelegate */
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            record_complete?(outputFileURL, error)
        }
        else {
            if let complete = record_complete {
                complete(outputFileURL, nil)
            }
            else {
                iCamera.request_photo_authorization(complete: {
                    if $0 {
                        PHPhotoLibrary.shared().performChanges({
                            let _ = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                        }, completionHandler: { (result, error) in
                            self.log_message("photoOutput didFinishProcessingPhoto: result = \(result), error = \(String(describing: error))")
                        })
                    }
                })
            }
        }
        record_complete = nil
    }
    
    // MARK: - Control
    
    /** 设置闪光灯 */
    func flash(level: Float) {
        do {
            try device?.lockForConfiguration()
            try device?.setTorchModeOn(level: level)
            device?.unlockForConfiguration()
        } catch {
            log_message("flash error \(error)")
        }
    }
    
    /** 切换前后摄像头 */
    func position(to: AVCaptureDevice.Position) -> Bool {
        self.device_position = to
        if let device = discovery_session(position: to) {
            self.device = device
            
            var input: AVCaptureDeviceInput!
            do {
                input = try AVCaptureDeviceInput(device: device)
            } catch { return false }
            self.session.beginConfiguration()
            if self.device_input != nil {
                self.session.removeInput(self.device_input!)
            }
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.device_input = input
            }
            
            camera_changed_animation()
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: - Animation
    
    /** 切换摄像头时的动画用的图层 */
    var camera_changed_animation_layer: CALayer = CALayer()
    
    /** 切换摄像头时的动画 */
    func camera_changed_animation() {
        let radius = CGFloat(hypot(Double(self.bounds.height), Double(self.bounds.width)) / 2)
        let frame  = CGRect(
            x: bounds.width / 2 - radius,
            y: bounds.height / 2 - radius,
            width: radius * 2,
            height: radius * 2
        )
        
        camera_changed_animation_layer.frame = frame
        camera_changed_animation_layer.cornerRadius = radius
        camera_changed_animation_layer.backgroundColor = UIColor.black.cgColor
        preview_layer?.mask = camera_changed_animation_layer
        
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.session.commitConfiguration()
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    self.preview_layer?.mask = nil
                })
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
                CATransaction.setAnimationDuration(0.5)
                self.camera_changed_animation_layer.frame = frame
                self.camera_changed_animation_layer.cornerRadius = radius
                CATransaction.commit()
            })
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
            CATransaction.setAnimationDuration(0.5)
            self.camera_changed_animation_layer.frame = CGRect(x: self.bounds.width / 2, y: self.bounds.height / 2, width: 0, height: 0)
            self.camera_changed_animation_layer.cornerRadius = 0
            CATransaction.commit()
        }
    }
    
    /** 对焦点图案 */
    var camera_focus_animation_imageview: UIImageView?
    /** 对焦点默认图层 */
    var camera_focus_animation_layer: CALayer!
    /** 对焦点消失时间 */
    var camera_focus_animation_time: Int = 0
    
    /** 对焦方法 */
    func camera_focus_animation_device(point: CGPoint) {
        camera_focus_animation(point: CGPoint(
            x: (1 - point.y) * bounds.width,
            y: point.x * bounds.height
        ))
    }
    
    /** 对焦动画 */
    func camera_focus_animation(point: CGPoint) {
        if let imageview = camera_focus_animation_imageview {
            addSubview(imageview)
            imageview.frame = CGRect(
                x: point.x - 70,
                y: point.y - 70,
                width: 140,
                height: 140
            )
            imageview.alpha = 1
            UIView.animate(withDuration: 0.2, animations: {
                self.camera_focus_animation_imageview?.frame = CGRect(
                    x: point.x - 50,
                    y: point.y - 50,
                    width: 100,
                    height: 100
                )
            })
        }
        else {
            if camera_focus_animation_layer == nil {
                camera_focus_animation_layer = CALayer()
                camera_focus_animation_layer.cornerRadius = 4
                camera_focus_animation_layer.borderWidth = 1
                camera_focus_animation_layer.borderColor = UIColor.yellow.withAlphaComponent(0.8).cgColor
            }
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            camera_focus_animation_layer.frame = CGRect(
                x: point.x - 50,
                y: point.y - 50,
                width: 100,
                height: 100
            )
            CATransaction.commit()
            container_view.layer.addSublayer(camera_focus_animation_layer)
        }
        //print(camera_focus_animation_layer.frame)
        if self.camera_focus_animation_time == 0 {
            camera_focus_animation_time = 4
            camera_focus_animation_time_run()
        }
        else {
            camera_focus_animation_time = 4
        }
    }
    
    func camera_focus_animation_time_run() {
        self.camera_focus_animation_time -= 1
        if camera_focus_animation_time > 0 {
            DispatchQueue.delay(time: 1, run: { [weak self] in
                self?.camera_focus_animation_time_run()
            })
        }
        else {
            UIView.animate(withDuration: 0.2, animations: {
                self.camera_focus_animation_imageview?.alpha = 0
            }, completion: { _ in
                self.camera_focus_animation_imageview?.removeFromSuperview()
            })
            self.camera_focus_animation_layer?.removeFromSuperlayer()
        }
    }
    
    // MARK: - Touch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let point = touches.first?.location(in: self) {
            focus_on(point: point)
        }
    }
    
    /** 对焦到屏幕上某点 */
    func focus_on(point: CGPoint) {
        do {
            try self.device?.lockForConfiguration()
            if let point_camera = preview_layer?.captureDevicePointConverted(fromLayerPoint: point) {
                //print("point = \(point); camera = \(point_camera);")
                if device?.isFocusPointOfInterestSupported == true {
                    device?.focusPointOfInterest = point_camera
                    device?.focusMode = .continuousAutoFocus
                }
                if device?.isExposureModeSupported(AVCaptureDevice.ExposureMode.autoExpose) == true {
                    self.device?.exposurePointOfInterest = point_camera
                    self.device?.exposureMode = .autoExpose
                }
            }
            self.device?.unlockForConfiguration()
        } catch  { }
    }
    
    // MARK: - Tools
    
    /** 输出信息 */
    func log_message(_ value: Any?) {
        log_tools.print_log(flag: 10, message: value)
    }
    
    /** 搜索摄像头 */
    func discovery_session(type: [AVCaptureDevice.DeviceType] = [AVCaptureDevice.DeviceType.builtInDualCamera, AVCaptureDevice.DeviceType.builtInMicrophone, AVCaptureDevice.DeviceType.builtInTelephotoCamera, AVCaptureDevice.DeviceType.builtInWideAngleCamera], media: AVMediaType? = nil, position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: type, mediaType: media, position: position).devices.first
    }
    
    
    
}


// MARK: - User Authorization

extension iCamera {
    
    /** 请求相机访问许可 */
    class func request_camera_authorization(complete: @escaping (Bool) -> Void) {
        let authorization_status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorization_status {
        case .notDetermined: // 没有许可，需要请求
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (user_feedback) in
                if user_feedback { // 用户同意
                    complete(true)
                }
                else { // 用户拒绝
                    complete(false)
                }
            })
        case .authorized: // 已经有权限
            complete(true)
        case .denied, .restricted: // 无法获得权限
            complete(false)
        }
    }
    
    /** 请求相册访问许可 */
    class func request_photo_authorization(complete: @escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized {
                    complete(true)
                }
                else {
                    complete(false)
                }
            })
        case .authorized:
            complete(true)
        case .denied, .restricted:
            complete(false)
        }
    }
}
