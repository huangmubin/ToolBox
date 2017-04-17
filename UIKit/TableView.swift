//
//  TableView.swift
//  ToolBoxUIKit
//
//  Created by Myron on 2017/3/30.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - Status

enum TableViewStatus {
    case normal
    case header(CGFloat)
    case footer(CGFloat)
    case refreshing(Bool)
    case refreshed(Any)
}

// MARK: - Refresh View

class RefreshView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(value: CGFloat) {
        
    }
    
}

// MARK: - Protocol

@objc protocol TableViewRefresh {
    func tableView(_ tableView: TableView, refreshHeader refreshView: RefreshView)
    func tableView(_ tableView: TableView, refreshfooter refreshView: RefreshView)
}

// MARK: - TableView

class TableView: UITableView {

    // MARK: - Init
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    
    private func deploy() {
        
    }
    
    // MARK: - Datas
    
    weak var refreshDelegate: TableViewRefresh?
    var status: TableViewStatus = .normal {
        didSet {
            
        }
    }
    
    // MARK: - Refresh Views
    
    var header: RefreshView? {
        didSet {
            if let header = header {
                headerHeight = header.bounds.height
                header.frame = CGRect(x: 0, y: -headerHeight, width: self.bounds.width, height: headerHeight)
                insertSubview(header, at: 0)
            }
            else {
                headerHeight = 0
                oldValue?.removeFromSuperview()
            }
        }
    }
    var footer: RefreshView? {
        didSet {
            if let footer = footer {
                footerHeight = footer.bounds.height
                footer.frame = CGRect(x: 0, y: max(contentSize.height, bounds.height), width: self.bounds.width, height: footerHeight)
                insertSubview(footer, at: 0)
            }
            else {
                footerHeight = 0
                oldValue?.removeFromSuperview()
            }
        }
    }
    
    var headerHeight: CGFloat = 0
    var footerHeight: CGFloat = 0
    
    // MARK: Size
    
    override var bounds: CGRect {
        didSet {
            updateSize()
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateSize()
        }
    }
    
    private func updateSize() {
        header?.frame = CGRect(x: 0, y: -headerHeight, width: self.bounds.width, height: headerHeight)
        footer?.frame = CGRect(x: 0, y: max(contentSize.height, bounds.height), width: self.bounds.width, height: footerHeight)
    }
    
    // MARK: - Content
    
    override var contentOffset: CGPoint {
        didSet {
            switch status {
            case .normal:
                break
            default:
                break
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("Touch ended")
    }
    
}
