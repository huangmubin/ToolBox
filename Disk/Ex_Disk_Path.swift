//
//  Ex_Disk_Path.swift
//  Eyeglass
//
//  Created by Myron on 2018/1/22.
//  Copyright © 2018年 Myron. All rights reserved.
//

import Foundation

// MARK: - Path

extension Disk {
    
    class Path {
        
        // MARK: Home Path
        
        static let home: String = NSHomeDirectory()
        static let documents = "/Documents/"
        static let preferences = "/Library/Preferences/"
        static let caches = "/Library/Caches/"
        static let tmp = "/tmp/"
        
        // MARK: Methods
        
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
        
        /** Sub paths in path */
        class func subs(_ path: String) -> [String] {
            return FileManager.default.subpaths(atPath: path) ?? []
        }
        
    }
    
}
