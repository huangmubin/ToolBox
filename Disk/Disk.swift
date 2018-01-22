//
//  Disk.swift
//  Eyeglass
//
//  Created by Myron on 2018/1/22.
//  Copyright © 2018年 Myron. All rights reserved.
//

import UIKit

public class Disk {
    
    // MARK: - File
    
    public class func exist(file: String) -> Bool {
        return FileManager.default.fileExists(atPath: file)
    }
    
    public class func read(file: String) -> Data? {
        return FileManager.default.contents(atPath: file)
    }
    
    @discardableResult
    public class func save(data: Data, to: String) -> Bool {
        do {
            try data.write(to: URL(fileURLWithPath: to))
            return true
        } catch { }
        return false
    }
    
    @discardableResult
    public class func delete(file: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: file)
            return true
        } catch { }
        return false
    }
    
    @discardableResult
    public class func copy(file: String, to: String) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: file) && !FileManager.default.fileExists(atPath: to) {
                var paths = to.components(separatedBy: "/")
                if paths.count <= 1 {
                    return false
                }
                paths.removeLast()
                let directory = paths.joined(separator: "/")
                if !FileManager.default.fileExists(atPath: directory) {
                    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
                }
                try FileManager.default.copyItem(atPath: file, toPath: to)
                return true
            }
        } catch { }
        return false
    }
    
    @discardableResult
    public class func move(file: String, to: String) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: file) && !FileManager.default.fileExists(atPath: to) {
                var paths = to.components(separatedBy: "/")
                if paths.count <= 1 {
                    return false
                }
                paths.removeLast()
                let directory = paths.joined(separator: "/")
                if !FileManager.default.fileExists(atPath: directory) {
                    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
                }
                try FileManager.default.moveItem(atPath: file, toPath: to)
                return true
            }
        } catch { }
        return false
    }
    
    // MARK: - Directory
    
    @discardableResult
    public class func create(directory: String) -> Bool {
        do {
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: directory), withIntermediateDirectories: true, attributes: nil)
            return true
        } catch { }
        return false
    }
    
    // MARK: - File Attribute
    
    public class func isDirectory(path: String) -> Bool {
        if let attribute = try? FileManager.default.attributesOfItem(atPath: path) {
            if let type = attribute[FileAttributeKey.type] as? String {
                return type == FileAttributeType.typeDirectory.rawValue
            }
        }
        return false
    }
    
    public class func size(path: String) -> Double {
        if let attribute = try? FileManager.default.attributesOfItem(atPath: path) {
            if let size = attribute[FileAttributeKey.size] as? Double {
                return size
            }
        }
        return 0
    }
    
    public class func typeAndSize(path: String) -> (Bool, Double) {
        if let attribute = try? FileManager.default.attributesOfItem(atPath: path) {
            if let type = attribute[FileAttributeKey.type] as? String,
                let size = attribute[FileAttributeKey.size] as? Double {
                return (type == FileAttributeType.typeDirectory.rawValue, size)
            }
        }
        return (false, 0)
    }
    
}



