//
//  TableViewCell.swift
//  BinaryCalculator
//
//  Created by Myron on 2018/1/12.
//  Copyright © 2018年 Myron. All rights reserved.
//

import UIKit

// MARK: - Protocol

@objc protocol TableViewCellDelegate: NSObjectProtocol {
    @objc optional func table_view(cell: TableViewCell, action_at index: IndexPath, sender: UIView?)
}

// MARK: - Cell

class TableViewCell: UITableViewCell {
    
    weak var cell_delegate: TableViewCellDelegate?
    var index_path: IndexPath?
    
    private var key_values: [String: Any] = [:]
    func set(key: TableViewCell.Key, value: Any?) {
        if value == nil {
            key_values.removeValue(forKey: key.value)
        } else {
            key_values.updateValue(value!, forKey: key.value)
        }
    }
    
    func get<T>(_ key: TableViewCell.Key) -> T? {
        return key_values[key.value] as? T
    }
    
    func get<T>(_ key: TableViewCell.Key, null: T) -> T {
        return (key_values[key.value] as? T) ?? null
    }
    
}

// MARK: - Keys

extension TableViewCell {
    
    class Key {
        let value: String
        init(_ key: String) {
            self.value = key
        }
        static let selected: Key = Key("TableViewCell.Selected")
    }
    
}
