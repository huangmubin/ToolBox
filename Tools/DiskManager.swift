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
    
    public class func exist(file: String) -> Bool {
        return FileManager.default.fileExists(atPath: file)
    }
    
    public class func read(file: String) -> Data? {
        return FileManager.default.contents(atPath: file)
    }
    
    public class func create(directory: String) -> Bool {
        do {
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: directory), withIntermediateDirectories: true, attributes: nil)
            return true
        } catch { }
        return false
    }
    
    public class func save(data: Data, to: String) -> Bool {
        do {
            try data.write(to: URL(fileURLWithPath: to))
            return true
        } catch { }
        return false
    }
    
    public class func delete(file: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: file)
            return true
        } catch { }
        return false
    }
    
    public class func copy(file: String, to: String) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: file) {
                try FileManager.default.copyItem(atPath: file, toPath: to)
                return true
            }
        } catch { }
        return false
    }
    
    public class func move(file: String, to: String) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: file) {
                try FileManager.default.moveItem(atPath: file, toPath: to)
                return true
            }
        } catch { }
        return false
    }

}

// MARK: - Disk Manager extension: Path

extension DiskManager {
    
    public class Path {
        
        static let home: String = NSHomeDirectory()
        
        /// Documents 文件夹。iTunes 备份，程序中用到的文件数据。
        static let documents = "/Documents/"
        /// Library/Preferences 文件夹。默认设置或状态信息。iTunes 备份。
        static let preferences = "/Library/Preferences/"
        /// Library/Caches 文件夹。缓存文件，不会自动删除。
        static let caches = "/Library/Caches/"
        /// tmp/ 文件夹。临时文件，系统可能删除其内容。
        static let tmp = "/tmp/"
        
        class func documents(_ file: String) -> String {
            return home + Path.documents + file
        }
        class func preferences(_ file: String) -> String {
            return home + Path.preferences + file
        }
        class func caches(_ file: String) -> String {
            return home + Path.caches + file
        }
        class func tmp(_ file: String) -> String {
            return home + Path.tmp + file
        }
        
    }
    
}

// MARK: - Disk Manager extension: Size

extension DiskManager {
    
    enum Size: Double {
        
        case Bytes  = 1
        case KB     = 1000
        case MB     = 1000000
        case GB     = 1000000000
        
        /// 判断路径，如果是文件夹则搜索底下所有文件的大小之和
        subscript(path: String) -> Double? {
            guard let attribute = try? FileManager.default.attributesOfItem(atPath: path) else { return nil }
            guard let type = attribute[FileAttributeKey.type] as? String else { return nil }
            if type == FileAttributeType.typeDirectory.rawValue {
                var size: UInt = 0
                guard let subPaths = FileManager.default.subpaths(atPath: path) else { return nil }
                for sub in subPaths {
                    let subPath = "\(path)\(path.hasSuffix("/") ? "" : "/")\(sub)"
                    guard let subAtt = try? FileManager.default.attributesOfItem(atPath: subPath) else { continue }
                    guard let type = subAtt[FileAttributeKey.type] as? String else { continue }
                    if type != FileAttributeType.typeDirectory.rawValue {
                        guard let s = subAtt[FileAttributeKey.size] as? UInt else { continue }
                        size += s
                    }
                }
                return Double(size) / rawValue
            } else {
                guard let size = attribute[FileAttributeKey.size] as? UInt else { return nil }
                return Double(size) / rawValue
            }
        }
        
        static func bytes(path: String) -> UInt {
            guard let attribute = try? FileManager.default.attributesOfItem(atPath: path) else { return 0 }
            guard let type = attribute[FileAttributeKey.type] as? String else { return 0 }
            
            if type == FileAttributeType.typeDirectory.rawValue {
                var size: UInt = 0
                guard let subPaths = FileManager.default.subpaths(atPath: path) else { return 0 }
                
                for sub in subPaths {
                    let subPath = "\(path)\(path.hasSuffix("/") ? "" : "/")\(sub)"
                    guard let subAtt = try? FileManager.default.attributesOfItem(atPath: subPath) else { continue }
                    guard let type = subAtt[FileAttributeKey.type] as? String else { continue }
                    
                    if type != FileAttributeType.typeDirectory.rawValue {
                        guard let s = subAtt[FileAttributeKey.size] as? UInt else { continue }
                        size += s
                    }
                }
                return size
            } else {
                guard let size = attribute[FileAttributeKey.size] as? UInt else { return 0 }
                return size
            }
        }
        
        
    }
}
