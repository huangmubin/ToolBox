//
//  Ex_Device.swift
//  SwiftiOSTests
//
//  Created by 黄穆斌 on 2017/12/14.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

extension UIDevice {
    
    // MARK: - Device Info
    
    /** is iPhone */
    public class func is_iPhone() -> Bool {
        return UIDevice.current.model.hasPrefix("iPhone")
    }
    
    /** is iPad */
    public class func is_iPad() -> Bool {
        return UIDevice.current.model.hasPrefix("iPad")
    }
    
    /** get the current model: iPhone 6s */
    public class func model() -> String {
        var system_info = utsname()
        uname(&system_info)
        var machine = [Int8]()
        if system_info.machine.0 != 0 {
            machine.append(system_info.machine.0)
        }
        if system_info.machine.1 != 0 {
            machine.append(system_info.machine.1)
        }
        if system_info.machine.2 != 0 {
            machine.append(system_info.machine.2)
        }
        if system_info.machine.3 != 0 {
            machine.append(system_info.machine.3)
        }
        if system_info.machine.4 != 0 {
            machine.append(system_info.machine.4)
        }
        if system_info.machine.5 != 0 {
            machine.append(system_info.machine.5)
        }
        if system_info.machine.6 != 0 {
            machine.append(system_info.machine.6)
        }
        if system_info.machine.7 != 0 {
            machine.append(system_info.machine.7)
        }
        if system_info.machine.8 != 0 {
            machine.append(system_info.machine.8)
        }
        if system_info.machine.9 != 0 {
            machine.append(system_info.machine.9)
        }
        if let string = String(cString: machine, encoding: String.Encoding.utf8) {
            switch string {
            case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
            case "iPhone4,1": return "iPhone 4S"
            case "iPhone5,1": return "iPhone 5"
            case "iPhone5,2": return "iPhone 5 (GSM+CDMA)"
            case "iPhone5,3": return "iPhone 5c (GSM)"
            case "iPhone5,4": return "iPhone 5c (GSM+CDMA)"
            case "iPhone6,1": return "iPhone 5s (GSM)"
            case "iPhone6,2": return "iPhone 5s (GSM+CDMA)"
            case "iPhone7,1": return "iPhone 6 Plus"
            case "iPhone7,2": return "iPhone 6"
            case "iPhone8,1": return "iPhone 6s"
            case "iPhone8,2": return "iPhone 6s Plus"
            case "iPhone8,4": return "iPhone SE"
                
            case "iPod1,1": return "iPod Touch 1G"
            case "iPod2,1": return "iPod Touch 2G"
            case "iPod3,1": return "iPod Touch 3G"
            case "iPod4,1": return "iPod Touch 4G"
            case "iPod5,1": return "iPod Touch (5 Gen)"
                
            case "iPad1,1": return "iPad"
            case "iPad1,2": return "iPad 3G"
            case "iPad2,1": return "iPad 2 (WiFi)"
            case "iPad2,2", "iPad2,4": return "iPad 2"
            case "iPad2,3": return "iPad 2 (CDMA)"
            case "iPad2,5": return "iPad Mini (WiFi)"
            case "iPad2,6": return "iPad Mini"
            case "iPad2,7": return "iPad Mini (GSM+CDMA)"
            case "iPad3,1": return "iPad 3 (WiFi)"
            case "iPad3,2": return "iPad 3 (GSM+CDMA)"
            case "iPad3,3": return "iPad 3"
            case "iPad3,4": return "iPad 4 (WiFi)"
            case "iPad3,5": return "iPad 4"
            case "iPad3,6": return "iPad 4 (GSM+CDMA)"
            case "iPad4,1": return "iPad Air (WiFi)"
            case "iPad4,2": return "iPad Air (Cellular)"
            case "iPad4,4": return "iPad Mini 2 (WiFi)"
            case "iPad4,5": return "iPad Mini 2 (Cellular)"
            case "iPad4,6": return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad Mini 3"
            case "iPad5,1": return "iPad Mini 4 (WiFi)"
            case "iPad5,2": return "iPad Mini 4 (LTE)"
            case "iPad5,3", "iPad5,4": return "iPad Air 2"
            case "iPad6,3", "iPad6,4": return "iPad Pro 9.7"
            case "iPad6,7", "iPad6,8": return "iPad Pro 12.9"
                
            case "i386", "x86_64": return "Simulator"
            default: break
            }
        }
        return "Apple"
    }
    
    /** get current device's name: Myron 的 iPad */
    public class func device_name() -> String {
        return UIDevice.current.name
    }
    
    /** get system version: 10.1.1 */
    public class func system_version() -> String {
        return UIDevice.current.systemVersion
    }
    
    /** get device'uuid: 3E0B7D22-C3EB-46C1-A82C-3D82596FC0A6 */
    public class func uuid() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    // MARK: - 设备方向
    
    /** Screen orientation is protrait? */
    public class func is_protrait() -> Bool {
        return UIScreen.main.bounds.width < UIScreen.main.bounds.height
    }
    
    /** Screen orientation is langscape? */
    public class func is_landscape() -> Bool {
        return UIScreen.main.bounds.width > UIScreen.main.bounds.height
    }
    
    /** Change the orientation to new. */
    public class func orientation_changed(to: UIInterfaceOrientation) {
        UIDevice.current.setValue(to.rawValue, forKey: "orientation")
        UIApplication.shared.statusBarOrientation = to
    }
    
    // MARK: - 设备内存信息
    
    /** Get the device hard disc size */
    public class func total_size() -> Int {
        if let attribute = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) {
            if let size = attribute[FileAttributeKey.systemSize] as? Int {
                return size
            }
        }
        return 0
    }
    
    /** Get the device hard disc size */
    public class func free_size() -> Int {
        if let attribute = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) {
            if let size = attribute[FileAttributeKey.systemFreeSize] as? Int {
                return size
            }
        }
        return 0
    }
    
}
