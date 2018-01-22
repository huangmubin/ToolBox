//
//  Ex_Dick_Data.swift
//  Eyeglass
//
//  Created by Myron on 2018/1/22.
//  Copyright © 2018年 Myron. All rights reserved.
//

import Foundation

extension Data {
    
    /** Disk.save(data: self, to: path) */
    @discardableResult
    func save(`in` path: String) -> Bool {
        return Disk.save(data: self, to: path)
    }
    
}
