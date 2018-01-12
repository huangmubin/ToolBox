//
//  TipsView_Animate.swift
//  SwiftiOS
//
//  Created by Myron on 2017/12/15.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

/* 质量，影响图层运动时的弹簧惯性，质量越大，弹簧拉伸和压缩的幅度越大 默认是 1 */
// open var mass: CGFloat
/* 弹簧刚性，越大越快。默认 100 */
// open var stiffness: CGFloat
/* 阻尼系数，默认为 10，阻力越大，停止越快. */
// open var damping: CGFloat
/* 初始速度，默认为 0 */
// open var initialVelocity: CGFloat

extension TipsView {
    
    class Animate: TipsView.SubView {
        
        enum AnimateType {
            case note
            case success
            case error
            case loading
        }
        
        /** 动画类型 */
        public var type: AnimateType = .note
        
        /** 运行动画 */
        public override func run() {
            DispatchQueue.global().async {
                Thread.sleep(forTimeInterval: 0.1)
                DispatchQueue.main.async {
                    switch self.type {
                    case .note:
                        self.run_note()
                    case .success:
                        self.run_success()
                    case .error:
                        self.run_error()
                    default:
                        break
                    }
                }
            }
        }
        
        /** 文本动画 */
        private func run_note() {
            let layer = CALayer()
            layer.frame = CGRect(x: 38, y: 8, width: 4, height: 4)
            layer.backgroundColor = super_view.tint_color.cgColor
            layer.cornerRadius = 2
            self.layer.addSublayer(layer)
            
            let animate = CASpringAnimation(keyPath: "bounds")
            animate.toValue = NSValue(cgRect: CGRect(x: 0, y: 18, width: 80, height: 4))
            animate.mass = 5
            animate.stiffness = 100
            animate.damping = 20
            animate.duration = animate.settlingDuration
            animate.fillMode = kCAFillModeForwards
            animate.isRemovedOnCompletion = false
            
            layer.add(animate, forKey: "SpringAnimation")
        }
        
        /** 成功动画 */
        private func run_success() {
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
            layer.lineWidth = 3
            layer.strokeEnd = 0
            layer.lineCap = kCALineCapRound
            layer.lineJoin = kCALineJoinRound
            layer.strokeColor = super_view.tint_color.cgColor
            self.layer.addSublayer(layer)
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 7, y: 37))
            path.addLine(to: CGPoint(x: 23, y: 50))
            path.addLine(to: CGPoint(x: 60, y: 5))
            layer.path = path.cgPath
            
            let animate = CASpringAnimation(keyPath: "strokeEnd")
            animate.toValue = NSNumber(value: 0.9)
            animate.mass = 1
            animate.stiffness = 100
            animate.damping = 10
            animate.duration = animate.settlingDuration
            animate.fillMode = kCAFillModeForwards
            animate.isRemovedOnCompletion = false
            
            layer.add(animate, forKey: "SpringAnimation")
        }
        
        /** 失败动画 */
        private func run_error() {
            let layer1 = CAShapeLayer()
            layer1.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
            layer1.lineWidth = 3
            layer1.strokeStart = 0.5
            layer1.strokeEnd = 0.5
            layer1.lineCap = kCALineCapRound
            layer1.lineJoin = kCALineJoinRound
            layer1.strokeColor = super_view.tint_color.cgColor
            self.layer.addSublayer(layer1)
            
            let path1 = UIBezierPath()
            path1.move(to: CGPoint(x: 10, y: 10))
            path1.addLine(to: CGPoint(x: 50, y: 50))
            layer1.path = path1.cgPath
            
            let layer2 = CAShapeLayer()
            layer2.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
            layer2.lineWidth = 3
            layer2.strokeStart = 0.5
            layer2.strokeEnd = 0.5
            layer2.lineCap = kCALineCapRound
            layer2.lineJoin = kCALineJoinRound
            layer2.strokeColor = super_view.tint_color.cgColor
            self.layer.addSublayer(layer2)
            
            let path2 = UIBezierPath()
            path2.move(to: CGPoint(x: 10, y: 50))
            path2.addLine(to: CGPoint(x: 50, y: 10))
            layer2.path = path2.cgPath
            
            let animate_e = CASpringAnimation(keyPath: "strokeEnd")
            animate_e.toValue = NSNumber(value: 0.9)
            animate_e.mass = 1
            animate_e.stiffness = 100
            animate_e.damping = 10
            animate_e.duration = animate_e.settlingDuration
            animate_e.fillMode = kCAFillModeForwards
            animate_e.isRemovedOnCompletion = false
            
            let animate_s = CASpringAnimation(keyPath: "strokeStart")
            animate_s.toValue = NSNumber(value: 0.1)
            animate_s.mass = 1
            animate_s.stiffness = 100
            animate_s.damping = 10
            animate_s.duration = animate_s.settlingDuration
            animate_s.fillMode = kCAFillModeForwards
            animate_s.isRemovedOnCompletion = false
            
            layer1.add(animate_s, forKey: "SpringAnimation_Start")
            layer1.add(animate_e, forKey: "SpringAnimation_End")
            layer2.add(animate_s, forKey: "SpringAnimation_Start")
            layer2.add(animate_e, forKey: "SpringAnimation_End")
        }
        
        /** 更新视图尺寸并且返回 */
        @discardableResult override func update_size() -> CGRect {
            switch type {
            case .note:
                self.bounds = CGRect(x: 0, y: 0, width: 80, height: 20)
            case .success, .error:
                self.bounds = CGRect(x: 0, y: 0, width: 60, height: 50)
            default:
                self.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
            }
            return self.bounds
        }
        
    }
    
}
