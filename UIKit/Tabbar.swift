//
//  Tabbar.swift
//  CustomTabBar
//
//  Created by Myron on 2017/11/3.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

/*
override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    (tabBar as? Tabbar)?.update_total_subview()
}
 */

// MARK: - TabBarBag

class TabBarBag: NSObject {
    
    var index: Int = 0
    weak var item: UITabBarItem?
    weak var item_label: UILabel?
    weak var item_view: UIView?
    var image_view: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    var label_view: UILabel = UILabel()
}

// MARK: - Tabbar

class Tabbar: UITabBar, UITabBarDelegate {
    
    /** bags 列表 */
    var tabbar_bags: [Int: TabBarBag] = [:]
    
    /** 背景视图 */
    var background_view: UIView?
    
    /** 更新所有子视图 */
    func update_total_subview() {
        for key in tabbar_bags.keys {
            update_subviews(bag_index: key)
        }
    }
    
    /** 更新某个特定子视图 */
    func update_subviews(bag_index: Int) {
        if let bag = tabbar_bags[bag_index] {
            let select = selectedItem === bag.item && bag.item != nil
            if let item = bag.item, let item_label = bag.item_label {
                bag.image_view.image = select ? item.selectedImage : item.image
                if let image = bag.item_view {
                    bag.image_view.center = CGPoint(x: image.bounds.width / 2, y: 18)
                }
                
                bag.label_view.text = item_label.text
                bag.label_view.textColor = item_label.textColor
                bag.label_view.font = item_label.font
                bag.label_view.sizeToFit()
                bag.label_view.center = CGPoint(x: item_label.bounds.width / 2, y: item_label.bounds.height / 2)
            }
        }
    }
    
    // MARK: - Layout Sub Views
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (subview_index, subview) in subviews.enumerated() {
            if subview_index < 1 {
                background_view = subview
                continue
            }
            let index = subview_index - 1
            if let item = self.items?[index] {
                if tabbar_bags[index] == nil {
                    let bag = TabBarBag()
                    bag.index = index
                    bag.item = item
                    bag.image_view.contentMode = .scaleAspectFill
                    for sub_sub in subview.subviews {
                        bag.item_view = subview
                        subview.addSubview(bag.image_view)
                        if let image_view = sub_sub as? UIImageView {
                            print(image_view.frame)
                            image_view.isHidden = true
                        }
                        if let label_view = sub_sub as? UILabel {
                            bag.item_label = label_view
                            label_view.addSubview(bag.label_view)
                        }
                    }
                    tabbar_bags[index] = bag
                }
                update_subviews(bag_index: index)
            }
        }
    }
    
}
