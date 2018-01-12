//
//  Extension_DateFormatter.swift
//  ShenLungCam
//
//  Created by Myron on 2017/8/3.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

extension DateFormatter {
    
    convenience public init(format: String) {
        self.init()
        self.dateFormat = format
    }
    
    func string(from_time: TimeInterval) -> String {
        return string(from: Date(timeIntervalSince1970: from_time))
    }
    
    static let date_0 = DateFormatter(format: "yyyy-MM-dd HH:mm")
    
}
