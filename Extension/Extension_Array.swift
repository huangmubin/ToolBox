//
//  Extension_Array.swift
//  
//
//  Created by Myron on 2017/3/21.
//
//

import Foundation

extension Array {
    
    // MARK: - Remove
    
    /**
     Remove multiple elements.
     - parameter predicate: the predicate to which element. (row, data)
     - returns: indexes which element is removed.
     */
    public mutating func remove(where predicate: (Int, Element) -> Bool) -> [Int] {
        var i = 0
        var index = 0
        var removes = [Int]()
        while i < self.count {
            if predicate(index, self[i]) {
                removes.append(index)
                self.remove(at: i)
            } else {
                i += 1
            }
            index += 1
        }
        return removes
    }
    
//    /** 获取子数组 */
//    subscript(range: Range<Int>) -> Array {
//        var new = Array()
//        for i in range.lowerBound ..< range.upperBound {
//            new.append(self[i])
//        }
//        return new
//    }
    
}


// MARK: - Array Tools

public class ArrayTools {
    
    // MARK: - Remove
    
    /**
     Remove multiple elements.
     - parameter data: the array
     - parameter predicate: the predicate to which element. (section, row, data)
     - returns: (new array, removeIndex, removeSection)
     */
    public class func remove<T>(array data: [[T]], where predicate: (Int, Int, T) -> Bool) -> (new: [[T]], removeIndex: [IndexPath], removeSection: IndexSet) {
        var array = data
        var index_sec = 0, index_row = 0, log_sec = 0, log_row = 0
        var indexes: [IndexPath] = [], sets: IndexSet = IndexSet()
        
        
        section_loop: while index_sec < array.count {
            row_loop: while index_row < array[index_sec].count {
                if predicate(log_sec, log_row, array[index_sec][index_row]) {
                    indexes.append(IndexPath(row: log_row, section: log_sec))
                    array[index_sec].remove(at: index_row)
                } else {
                    index_row += 1
                }
                log_row += 1
            }
            
            if array[index_sec].count == 0 {
                sets.insert(log_sec)
            } else {
                index_sec += 1
            }
            
            index_row = 0
            log_row = 0
            log_sec += 1
        }
        
        return (array, indexes, sets)
    }
    
}
