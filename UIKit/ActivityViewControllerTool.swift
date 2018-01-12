//
//  ActivityViewControllerTool.swift
//  Eyeglass
//
//  Created by Myron on 2017/11/9.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class ActivityViewControllerTool: NSObject {
    
    /** 用于复制到项目中进行自定义的方法，需要重写 activity 确定自定义的分享内容，以及 excluded_activity 确定不需要的分享内容 */
    func copy_func(`in` show_controller: UIViewController, ipad_view: UIView? = nil, shared_items: [Any], complete: @escaping UIActivityViewControllerCompletionWithItemsHandler) {
        
        let activity: [UIActivity]? = nil
        var excluded_activity: [UIActivityType]? = []
        if #available(iOS 6.0, *) {
            excluded_activity! += [
                UIActivityType.postToFacebook,
                UIActivityType.postToTwitter,
                UIActivityType.postToWeibo,
                UIActivityType.message,
                UIActivityType.mail,
                UIActivityType.print,
                UIActivityType.copyToPasteboard,
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll
            ]
        }
        if #available(iOS 7.0, *) {
            excluded_activity! += [
                UIActivityType.addToReadingList,
                UIActivityType.postToFlickr,
                UIActivityType.postToVimeo,
                UIActivityType.postToTencentWeibo,
                UIActivityType.airDrop
            ]
        }
        if #available(iOS 9.0, *) {
            excluded_activity! += [
                UIActivityType.openInIBooks
            ]
        }
        if #available(iOS 11.0, *) {
            excluded_activity! += [
                UIActivityType.markupAsPDF
            ]
        }
        
        //
        let controller = UIActivityViewController(
            activityItems: shared_items,
            applicationActivities: activity
        )
        controller.excludedActivityTypes = excluded_activity
        controller.completionWithItemsHandler = complete
        
        //
        if UIDevice.current.model.hasPrefix("iPad") {
            controller.modalPresentationStyle = UIModalPresentationStyle.popover
            controller.popoverPresentationController?.sourceRect = ipad_view?.bounds ?? CGRect.zero
            controller.popoverPresentationController?.sourceView = ipad_view
            controller.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        
        // 显示
        show_controller.present(controller, animated: true, completion: nil)
    }
    
    // 说明
    func demo() {
        // 弹出界面
        let show_controller: UIViewController = UIViewController()
        // iPad 的时候弹出的锚点视图
        let ipad_view: UIView = UIView()
        
        // 要分享的数据，图片分享 UIImage，视频分享 URL
        let activity_items: [Any]
            = []
        // 自定义的分享按钮，在第三行中
        let activity: [UIActivity]?
            = []
        // 不进行分享的对象
        var excluded_activity: [UIActivityType]? = []
        if #available(iOS 6.0, *) {
            excluded_activity! += [
                UIActivityType.postToFacebook,
                UIActivityType.postToTwitter,
                UIActivityType.postToWeibo,
                UIActivityType.message,
                UIActivityType.mail,
                UIActivityType.print,
                UIActivityType.copyToPasteboard,
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll
            ]
        }
        if #available(iOS 7.0, *) {
            excluded_activity! += [
                UIActivityType.addToReadingList,
                UIActivityType.postToFlickr,
                UIActivityType.postToVimeo,
                UIActivityType.postToTencentWeibo,
                UIActivityType.airDrop
            ]
        }
        if #available(iOS 9.0, *) {
            excluded_activity! += [
                UIActivityType.openInIBooks
            ]
        }
        if #available(iOS 11.0, *) {
            excluded_activity! += [
                UIActivityType.markupAsPDF
            ]
        }
        
        // 分享控制器
        let controller = UIActivityViewController(
            activityItems: activity_items,
            applicationActivities: activity
        )
        controller.excludedActivityTypes = excluded_activity
        
        // iPad 锚点
        if UIDevice.current.model.hasPrefix("iPad") {
            controller.modalPresentationStyle = UIModalPresentationStyle.popover
            controller.popoverPresentationController?.sourceRect = ipad_view.bounds
            controller.popoverPresentationController?.sourceView = ipad_view
            controller.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        
        // 显示
        show_controller.present(controller, animated: true, completion: nil)
    }
    
}

// MARK: - WeChat Friends

extension UIActivityType {
    static let wechat_friends: UIActivityType = UIActivityType(rawValue: "")
}

class Activity_WeChat_Friends: UIActivity {
    
    override var activityType: UIActivityType? {
        return UIActivityType.wechat_friends
    }
    
    override var activityTitle: String? {
        return "微信朋友圈".language
    }
    
    override var activityImage: UIImage? {
        if UIDevice.current.model.hasPrefix("iPad") {
            return UIImage(named: "WeChat friends ipad")
        } else {
            return UIImage(named: "WeChat friends")
        }
    }
    
    /** 弹出分享界面之前进行询问 */
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        print("canPerform withActivityItems \(activityItems)")
        return true
    }// override this to return availability of activity based on items. default returns NO
    
    /** 执行分享 */
    override func prepare(withActivityItems activityItems: [Any]) {
        print("prepare(withActivityItems activityItems: [Any])")
    }// override to extract items and set up your HI. default does nothing
    
    /** 分享时弹出的 Controller */
    override var activityViewController: UIViewController? {
        return nil
    }
    
    /** 如果没有 activityViewController 会执行 */
    override func perform() {
        print("perform()")
        self.activityDidFinish(false)
    }// if no view controller, this method is called. call activityDidFinish when done. default calls [self activityDidFinish:NO]
    
    
    // state method
    
    override func activityDidFinish(_ completed: Bool) {
        print("activityDidFinish(_ completed: Bool)")
    }// activity must call this when activity is finished
    
}
