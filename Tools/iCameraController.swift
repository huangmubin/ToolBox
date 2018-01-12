//
//  iCameraController.swift
//  Eyeglass
//
//  Created by Myron on 2017/11/1.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class iCameraController: UIView {

    /** iCamera */
    @IBOutlet weak var camera: iCamera! {
        didSet {
            init_camera()
        }
    }
    
    var layout_container: Layouter.Container = Layouter.Container()
    
    // MARK: - Init
    
    init(camera: iCamera) {
        super.init(frame: UIScreen.main.bounds)
        self.camera = camera
        init_deploy()
        init_subviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init_deploy()
    }
    
    private func init_deploy() {
        self.backgroundColor = UIColor.clear
    }
    
    func init_subviews() {
        let _ = {
            if control_view == nil {
                let view = UIView()
                view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.addSubview(view)
                Layouter(superview: self, view: view)
                    .setContrainer(layout_container)
                    .leading().bottom().trailing().height(100)
                    .contrainer(orient: .portrait, foreach: { (index, layout) in
                        if layout.firstItem === view {
                            log_tools.print_log(flag: 11, message: "index = \(index); \(layout)")
                            return "control_view_protrait_\(index)"
                        }
                        else {
                            return nil
                        }
                    })
//                    .top().bottom().trailing().width(100)
//                    .contrainer(orient: .landscape, foreach: { (index, layout) in
//                        return "control_view_landscape_\(index)"
//                    }).clearConstrants()
                control_view = view
            }
        }()
        layout_container.notify(object: Notification(name: Notification.Name.AVPlayerItemTimeJumped))
        
        
        let _ = {
            let button = UIButton(type: UIButtonType.system)
            button.setTitle("P", for: UIControlState.normal)
            button.backgroundColor = UIColor.red
            addSubview(button)
            capture_button = button
        }()
    }
    
    private func init_camera() {
        camera.addSubview(self)
        Layouter(superview: camera, view: self).edges()
    }
    
    // MARK: - Control View
    
    @IBOutlet weak var control_view: UIView!
    
    // MARK: - Capture Button
    
    @IBOutlet weak var capture_button: UIButton! {
        didSet {
//            Layouter(superview: self, view: capture_button)
//                .setContrainer(layout_container)
//                .centerX().contrainer(
//                    appendLastLayoutTo: "capture_button_P_centerx",
//                    orient: Layouter.Orientation.portrait,
//                    active: true)
//                .bottom(20).contrainer(
//                    appendLastLayoutTo: "capture_button_P_bottom",
//                    orient: Layouter.Orientation.portrait,
//                    active: true)
//                .centerY().contrainer(
//                    appendLastLayoutTo: "capture_button_L_centery",
//                    orient: Layouter.Orientation.landscape,
//                    active: true)
//                .trailing(20).contrainer(
//                    appendLastLayoutTo: "capture_button_L_trailing",
//                    orient: Layouter.Orientation.landscape,
//                    active: true)
        }
    }
    
}

