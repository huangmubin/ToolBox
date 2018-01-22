//
//  Ex_Disk_Size.swift
//  Eyeglass
//
//  Created by Myron on 2018/1/22.
//  Copyright © 2018年 Myron. All rights reserved.
//

import Foundation

extension Disk {
    
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
        
        /** Size to directory */
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
