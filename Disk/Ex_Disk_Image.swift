//
//  Ex_Disk_Image.swift
//  Eyeglass
//
//  Created by Myron on 2018/1/22.
//  Copyright © 2018年 Myron. All rights reserved.
//

import Foundation

extension UIImage {
    
    /** Disk.save(data: data, to: path) */
    func save(`in` path: String) -> Bool {
        if let data = UIImagePNGRepresentation(self) {
            return Disk.save(data: data, to: path)
        } else {
            return false
        }
    }
    
}
