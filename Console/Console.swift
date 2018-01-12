//
//  Console.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 2017/12/28.
//  Copyright © 2017年 myron. All rights reserved.
//

import Foundation

let cin = Console.default

/**
 Get console input
 */
public class Console {
    
    // MARK: - Single
    
    public static var `default` = Console()
    private init() { }
    
    // MARK: - User input dats value
    
    // user input datas
    private var user_input: [[UInt8]] = []
    // scan the console input
    private func scan() -> [UInt8] {
        while user_input.isEmpty {
            let data = [UInt8](FileHandle.standardInput.availableData)
            var start_index = 0
            for (i, d) in data.enumerated() {
                switch d {
                case 32, 10:
                    user_input.append(Array(data[start_index ..< i]))
                    start_index = i + 1
                default: break
                }
            }
        }
        return user_input.removeFirst()
    }
    
    // MARK: - Custom operator
    
    @discardableResult
    static func >><T>(l: Console, r: inout T) -> Console {
        l.to(&r)
        return l
    }
    
    // MARK: - Chain
    
    @discardableResult
    public func to<T>(_ value: inout T) -> Console {
        switch value {
        case is Int:
            value = scan_int() as! T
        case is Int64:
            value = scan_int64() as! T
        case is String:
            value = scan_string() as! T
        case is Double:
            value = scan_double() as! T
        case is Float:
            value = Float(scan_double()) as! T
        default: break
        }
        return self
    }
    
    // MARK: - Sub scans
    
    private func scan_int() -> Int {
        var data = scan()
        var value = 0
        while !data.isEmpty {
            value = value * 10 + Int(data.removeFirst() - 48)
        }
        return value
    }
    
    private func scan_int64() -> Int64 {
        var data = scan()
        var value: Int64 = 0
        while !data.isEmpty {
            value = value * 10 + Int64(data.removeFirst() - 48)
        }
        return value
    }
    
    private func scan_string() -> String {
        while true {
            if let value = String(bytes: scan(), encoding: .utf8) {
                return value
            }
        }
    }
    
    private func scan_double() -> Double {
        var data = scan()
        var value: Double = 0, x: Double = 0
        var unit: UInt8 = 0
        
        while !data.isEmpty {
            unit = data.removeFirst()
            if unit == 46 {
                x = 0.1
                continue
            }
            if x > 0 {
                value = value + Double(unit) * x
                x /= 10
            } else {
                value = value * 10 + Double(unit - 48)
            }
        }
        return value
    }
}
