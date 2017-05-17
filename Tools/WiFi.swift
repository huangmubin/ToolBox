import SystemConfiguration.CaptiveNetwork

class WiFi {
    
    /**
     获取 WiFi 名称跟 Mac 信息。
     */
    class func infos() -> (ssid: String, mac: String) {
        if let cfas: NSArray = CNCopySupportedInterfaces() {
            for cfa in cfas {
                if let dict = CFBridgingRetain(
                    CNCopyCurrentNetworkInfo(cfa as! CFString)
                    ) as? NSDictionary {
                    if let ssid = dict["SSID"] as? String,
                        let mac = dict["BSSID"] as? String {
                        return (ssid, mac)
                    }
                }
            }
        }
        return ("Unknow", "Unknow")
    }
    
    /**
     获取 WiFi 名称。
     */
    class func ssid() -> String? {
        if let cfas: NSArray = CNCopySupportedInterfaces() {
            for cfa in cfas {
                if let dict = CFBridgingRetain(
                    CNCopyCurrentNetworkInfo(cfa as! CFString)
                    ) as? NSDictionary {
                    if let ssid = dict["SSID"] as? String {
                        return ssid
                    }
                }
            }
        }
        return nil
    }
    
    
    /**
     获取 Mac 信息。
     */
    class func mac() -> String? {
        if let cfas: NSArray = CNCopySupportedInterfaces() {
            for cfa in cfas {
                if let dict = CFBridgingRetain(
                    CNCopyCurrentNetworkInfo(cfa as! CFString)
                    ) as? NSDictionary {
                    if let mac = dict["BSSID"] as? String {
                        return mac
                    }
                }
            }
        }
        return nil
    }
    
}
