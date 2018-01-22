//
//  Ex_Disk_String.swift
//  Eyeglass
//
//  Created by Myron on 2018/1/22.
//  Copyright © 2018年 Myron. All rights reserved.
//

import Foundation

extension String {
    
    /** Get file in self path */
    func file() -> Data? {
        return Disk.read(file: self)
    }
    
    /** Get image in self path */
    func image() -> UIImage? {
        return UIImage(contentsOfFile: self)
    }
    
    /** URL(fileURLWithPath: self) */
    func file_url() -> URL {
        return URL(fileURLWithPath: self)
    }
    
    /** return URL(string: self) */
    func url() -> URL? {
        return URL(string: self)
    }
    
    /** Disk.create(directory: self) */
    func directory() -> Bool {
        if Disk.isDirectory(path: self) {
            return true
        } else {
            return Disk.create(directory: self)
        }
    }
    
    /** Disk.delete(file: self) */
    @discardableResult
    func delete() -> Bool {
        if Disk.exist(file: self) {
            return Disk.delete(file: self)
        } else {
            return false
        }
    }
}
