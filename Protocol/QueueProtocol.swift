//
//  QueueProtocol.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 2017/12/11.
//  Copyright © 2017年 myron. All rights reserved.
//

import Foundation

// MARK: - Queue Protocol

/**
 Queue Protocol
 An Array container, implement some stack and queue methods.
 Is generice type.
 */
public protocol QueueProtocol {
    /** Generice type */
    associatedtype QueueType
    /** The data array */
    var datas: [QueueType] { get set }
    /** If true, the pull will remove first element, false is remove last element. */
    var isSequence: Bool { get set }
}

// MARK: - Queue Protocol Extension - Default methods

extension QueueProtocol {
    
    /**
     Push a data in queue.
     - parameter data: data
     */
    mutating func push(_ data: QueueType) {
        datas.append(data)
    }
    
    /**
     Push a data in queue.
     - returns: if isSequence is true, the first data or last data. if datas is empty, return nil.
     */
    mutating func pull() -> QueueType? {
        if datas.count > 0 {
            return isSequence ? datas.removeFirst() : datas.removeLast()
        } else {
            return nil
        }
    }
    
    /**
     Advance a element to the next.
     - parameter where: the predicate to which data.
     */
    mutating func advanceToNext(where predicate: (QueueType) -> Bool) {
        if let i = datas.index(where: predicate) {
            let data = datas.remove(at: i)
            if isSequence {
                datas.insert(data, at: 0)
            } else {
                datas.append(data)
            }
        }
    }
    
    /**
     Find a data with predicate closures.
     - parameter where: the predicate to which data.
     - returns: the data or nil.
     */
    func find(where predicate: (QueueType) -> Bool) -> QueueType? {
        if let i = datas.index(where: predicate) {
            return datas[i]
        } else {
            return nil
        }
    }
    
    /**
     Find a data with predicate closures.
     - parameter where: the predicate to which data.
     - returns: the data or nil.
     */
    func contains(where predicate: (QueueType) -> Bool) -> Bool {
        return datas.contains(where: predicate)
    }
    
    /**
     Remove a data with predicate closures.
     - parameter where: the predicate to which data.
     - returns: the data or nil.
     */
    @discardableResult
    mutating func remove(where predicate: (QueueType) -> Bool) -> QueueType? {
        if let i = datas.index(where: predicate) {
            return datas.remove(at: i)
        }
        else {
            return nil
        }
    }
    
    /**
     Remove all data.
     */
    mutating func removeAll() {
        datas.removeAll()
    }
    
}

// MARK: - Queue Control Protocol

/**
 Control Queue.
 Have a current to take the latest data and it methods.
 */
public protocol QueueControlProtocol :QueueProtocol {
    /** The latest data. */
    var current: QueueType? { get set }
}

// MARK: - Queue Control Protocol Extension - Default Methods

extension QueueControlProtocol {
    
    /**
     Pull a data and set it to current.
     - returns: if data is empty will false.
     */
    mutating func next() -> Bool {
        if current == nil {
            if let data = pull() {
                current = data
                return true
            }
        }
        return false
    }
    
    /**
     Set the current to nil.
     */
    mutating func done() {
        current = nil
    }
    
    /**
     Find a data with predicate closures.
     - parameter where: the predicate to which data.
     - returns: the data or nil.
     */
    func find(where predicate: (QueueType) -> Bool) -> QueueType? {
        if let data = self.current {
            if predicate(data) {
                return self.current
            }
        }
        
        if let i = datas.index(where: predicate) {
            return datas[i]
        } else {
            return nil
        }
    }
    
    /**
     Find a data with predicate closures.
     - parameter where: the predicate to which data.
     - returns: the data or nil.
     */
    func contains(where predicate: (QueueType) -> Bool) -> Bool {
        if let data = self.current {
            if predicate(data) {
                return true
            }
        }
        return datas.contains(where: predicate)
    }
    
}

// MARK: - Queue Control

/**
 Queue Control
 A generice class which implement Control Queue protocol.
 Use to control the queue.
 */
public class QueueControl<T>: QueueControlProtocol {
    
    // MARK: Queue
    
    /** The generice type. */
    public typealias QueueType = T
    public var isSequence: Bool = true
    public var datas: [T] = []
    
    // MARK: ControlQueue
    
    public var current: T?
}
