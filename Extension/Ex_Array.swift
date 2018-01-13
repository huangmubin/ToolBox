//
//  Ex_Array.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 2017/12/11.
//  Copyright © 2017年 myron. All rights reserved.
//

import Foundation

// MARK: - 1D

extension Array {
    
    // MARK: Remove
    
    /** Remove element */
    public mutating func remove(where predicate: (Element) throws -> Bool) -> Int? {
        do {
            if let index = try self.index(where: predicate) {
                self.remove(at: index)
                return index
            }
        } catch { }
        return nil
    }
    
    /** Mutable Remove
     predicate: element predicate
     block: call when the predicate is return true. default = nil
     */
    public mutating func remove(mutable predicate: (Element) throws -> Bool, block: ((Int, Element) -> Void)? = nil) -> [Int] {
        var indexes = [Int]()
        var index: Int = 0, row: Int = 0, result = false
        while row < self.count {
            do { result = try predicate(self[row]) } catch { }
            if result {
                let value = self.remove(at: row)
                block?(index, value)
                indexes.append(index)
                index += 1
            } else {
                index += 1
                row += 1
            }
        }
        return indexes
    }
    
    /** Find the Element */
    public func find(predicate: (Element) throws -> Bool) -> Element? {
        do {
            if let index = try self.index(where: predicate) {
                return self[index]
            }
        } catch { }
        return nil
    }
    
}

// MARK: - 2D

extension Array {
    
    /** Find the value */
    public func indexPath<T>(where predicate: (T) throws -> Bool) -> IndexPath? {
        do {
            if let array = self as? [[T]] {
                for (section, values) in array.enumerated() {
                    if let row = try values.index(where: predicate) {
                        return IndexPath(row: row, section: section)
                    }
                }
            }
        } catch { }
        return nil
    }
    
}


