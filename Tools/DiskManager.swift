//
//  DiskManager.swift
//  DiskManagerProject
//
//  Created by Myron on 2017/3/22.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit


// MARK: - Disk Manager
/**
 A disk manager.
 class DiskManager
    enum Path
    enum Size
 */
public class DiskManager {
    
    // MARK: - File Managers
    
    @discardableResult
    public class func exist(file: String) -> Bool {
        return FileManager.default.fileExists(atPath: file)
    }
    
    @discardableResult
    public class func read(file: String) -> Data? {
        return FileManager.default.contents(atPath: file)
    }
    
    @discardableResult
    public class func create(directory: String) -> Bool {
        do {
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: directory), withIntermediateDirectories: true, attributes: nil)
            return true
        } catch { }
        return false
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

// MARK: - Disk Manager extension: Path

extension DiskManager {
    
    public class Path {
        
        static let home: String = NSHomeDirectory()
        static let documents = "/Documents/"
        static let preferences = "/Library/Preferences/"
        static let caches = "/Library/Caches/"
        static let tmp = "/tmp/"
        
        /**
         ~/Documents/<file>
         - parameter file: file name or path
         - returns: path
         */
        class func documents(_ file: String) -> String {
            return home + Path.documents + file
        }
        /**
         ~/Library/Preferences/<file>
         - parameter file: file name or path
         - returns: path
         */
        class func preferences(_ file: String) -> String {
            return home + Path.preferences + file
        }
        /**
         ~/Library/Caches/<file>
         - parameter file: file name or path
         - returns: path
         */
        class func caches(_ file: String) -> String {
            return home + Path.caches + file
        }
        /**
         ~/tmp/<file>
         - parameter file: file name or path
         - returns: path
         */
        class func tmp(_ file: String) -> String {
            return home + Path.tmp + file
        }
        
        /**
         */
        class func subFiles(_ path: String) -> [String] {
            if let subPaths = FileManager.default.subpaths(atPath: path) {
                return subPaths
            }
            else {
                return []
            }
        }
        
    }
    
}

// MARK: - Disk Manager extension: Size

extension DiskManager {
    
    public enum Size: Double {
        
        case Bytes  = 1
        case KB     = 1000
        case MB     = 1000000
        case GB     = 1000000000
        
        /**
         folder or file's size to SizeType
         */
        public subscript(path: String, deep: Bool) -> Double {
            let attribute = DiskManager.typeAndSize(path: path)
            if attribute.0 {
                return Size.directory(path: path, deep: deep) / rawValue
            } else {
                return attribute.1 / rawValue
            }
        }
        
        /**
         folder or file's size to SizeType
         */
        public subscript(path: String) -> Double {
            return self[path, false]
        }
        
        /**
         size string use "%\(length)f Bytes" format
         - parameter path: file name or path
         - parameter length: size
         - returns:
         */
        public func toString(_ path: String, length: Double) -> String {
            switch self {
            case .Bytes:
                let format = "%\(length)f Bytes"
                return String(format: format, self[path])
            case .GB:
                let format = "%\(length)f GB"
                return String(format: format, self[path])
            case .MB:
                let format = "%\(length)f MB"
                return String(format: format, self[path])
            case .KB:
                let format = "%\(length)f KB"
                return String(format: format, self[path])
            }
        }
        
        // MARK: - Tools
        
        public static func directory(path: String, deep: Bool = false) -> Double {
            if let subPaths = FileManager.default.subpaths(atPath: path) {
                var iterator = subPaths.makeIterator()
                var subFileName = iterator.next()
                var subPath: String = ""
                let pathPrefix = "\(path)\(path.hasSuffix("/") ? "" : "/")"
                var totaleSize: Double = 0
                while subFileName != nil {
                    subPath = pathPrefix + subFileName!
                    let attribute = DiskManager.typeAndSize(path: subPath)
                    if attribute.0 {
                        if deep {
                            totaleSize += Size.directory(path: subPath, deep: deep)
                        }
                    } else {
                        totaleSize += attribute.1
                    }
                    subFileName = iterator.next()
                }
                return totaleSize
            }
            return 0
        }
    }
}
