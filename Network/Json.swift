//
//  Json.swift
//  JsonProject
//
//  Created by 黄穆斌 on 2017/3/14.
//  Copyright © 2017年 MuBinHuang. All rights reserved.
//
//  A json analysis tool class.

import Foundation

/**
 Json data analysis tool.
 */
public class Json: CustomStringConvertible {
    
    // MARK: - JSON Data
    
    /** The complete json data. */
    private var json: Any?
    /** The temp json data when the user visiting. */
    private var temp: Any?
    
    /**
     Set the json data.
     
     - parameter json: json Data
     */
    public func set(_ json: Any?) {
        self.json = json
        self.temp = json
    }
    
    /**
     Reset the temp data.
     */
    public func reset() {
        self.temp = self.json
    }
    
    // MARK: - Description: CustomStringConvertible
    
    /** description string */
    public var description: String {
        return "==== Json Data Start ====\n\(String(describing: self.json))\n==== Json Data End   ===="
    }
    /** description methods */
    public func log() {
        print(description)
    }
    /** description temp methods */
    public func logTemp() {
        print("==== Json Temp Data Start ====")
        print("\(String(describing: self.temp))")
        print("==== Json Temp Data End   ====")
    }
    
    // MARK: - Init Data Object
    
    /**
     Initialize with a json format data.
     
     - parameter json: a dictionary or array object
     
     - returns: Json object
     */
    public init(json: Any?) {
        self.json = json
        self.temp = json
    }
    
    /**
     Initialize with a data.
     
     - parameter data: a json data
     
     - returns: if the data is a json data, return Json, or nil.
     */
    public init?(data: Data?) {
        if let data = data {
            if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) {
                self.json = json
                self.temp = json
                return
            }
        }
        return nil
    }
    
    // MARK: - Subscript Visit Methods
    
    /**
     Visit the json date use the keys.
     
     - parameter keys: some String or Int key. like [1, "key", 2]
     
     - returns: update the self.temp and return self
     */
    public subscript(keys: Any...) -> Json {
        var temp = self.temp
        for key in keys {
            if let json = temp as? [String: Any], let key = key as? String {
                temp = json[key]
            }
            else if let json = temp as? [Any], let key = key as? Int {
                temp = json[key]
            }
        }
        self.temp = temp
        return self
    }
    
    // MARK: - Take Data Use Type
    
    /** take the temp data use the String type */
    public var string: String? {
        defer { self.temp = self.json }
        if let value = temp as? String {
            return value
        }
        return nil
    }
    
    /** take the temp data use the Int type */
    public var int: Int? {
        defer { self.temp = self.json }
        if let value = temp as? Int {
            return value
        }
        if let value = temp as? String {
            return Int(value)
        }
        return nil
    }
    
    /** take the temp data use the Double type */
    public var double: Double? {
        defer { self.temp = self.json }
        if let value = temp as? Double {
            return value
        }
        if let value = temp as? String {
            return Double(value)
        }
        return nil
    }
    
    /** take the temp data use the Float type */
    public var float: Float? {
        defer { self.temp = self.json }
        if let value = temp as? Float {
            return value
        }
        if let value = temp as? String {
            return Float(value)
        }
        return nil
    }
    
    /** take the temp data use the Double type */
    public var bool: Bool? {
        defer { self.temp = self.json }
        if let value = temp as? Bool {
            return value
        }
        if let value = temp as? Int {
            return value == 1
        }
        if let value = temp as? String {
            switch value.lowercased() {
            case "", "0", "false", "no", "off":
                return false
            case "1", "true", "yes", "on":
                return true
            default:
                break
            }
        }
        return nil
    }
    
    /** take the temp data use the [Json] type */
    public var array: [Json] {
        defer { self.temp = self.json }
        if let datas = temp as? [Any] {
            var jsons = [Json]()
            for json in datas {
                jsons.append(Json(json: json))
            }
            return jsons
        }
        return []
    }
    
    // MARK: - Visit Methods
    
    /**
     Get the data with key.
     
     - parameter keys: some String or Int key. like [1, "key", 2]
     
     - returns: the T type data, or nil
     */
    public func get<T>(_ keys: Any...) -> T? {
        defer { self.temp = self.json }
        var temp = self.temp
        for key in keys {
            if let json = temp as? [String: Any], let key = key as? String {
                temp = json[key]
            }
            else if let json = temp as? [Any], let key = key as? Int {
                temp = json[key]
            }
        }
        return temp as? T
    }
    
    /**
     Get the data with key.
     
     - parameter keys: some String or Int key. like [1, "key", 2]
     - parameter null: if null.
     
     - returns: the T type data, if nill return the null
     */
    public func get<T>(_ keys: Any..., null: T) -> T {
        defer { self.temp = self.json }
        var temp = self.temp
        for key in keys {
            if let json = temp as? [String: Any], let key = key as? String {
                temp = json[key]
            }
            else if let json = temp as? [Any], let key = key as? Int {
                temp = json[key]
            }
        }
        return (temp as? T) ?? null
    }
    
    // MARK: - Class Tools
    
    /**
     Transform a Dictionary or Array to the json format string.
     
     - parameter keys: some Dictionary or Array
     
     - returns: the json format string
     */
    public class func toString(_ json: Any) -> String {
        var result = ""
        if let dic = json as? [String: Any] {
            result += "{"
            for (k, v) in dic {
                switch v {
                case is Int, is Double, is Float:
                    result += "\"\(k)\":\(v),"
                case is String:
                    result += "\"\(k)\":\"\(v)\","
                case is Bool:
                    let b = v as! Bool
                    result += "\"\(k)\":" + (b ? "true," : "false,")
                default:
                    result += "\"\(k)\":\(toString(v)),"
                }
            }
            result.remove(at: result.index(before: result.endIndex))
            result += "}"
        }
        else if let arr = json as? [Any] {
            result += "["
            for v in arr {
                switch v {
                case is Int, is Double, is Float:
                    result += "\(v),"
                case is String:
                    result += "\"\(v)\","
                case is Bool:
                    let b = v as! Bool
                    result += (b ? "true," : "false,")
                default:
                    result += "\(toString(v)),"
                }
            }
            result.remove(at: result.index(before: result.endIndex))
            result += "]"
        }
        return result
    }
    
    /**
     Transform a Dictionary or Array to the json format Data.
     
     - parameter keys: some Dictionary or Array
     
     - returns: if the json is a Data, return it. Or return the JSON data.
     */
    public class func body(_ json: Any) -> Data? {
        if let data = json as? Data {
            return data
        }
        if let data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) {
            return data
        }
        return nil
    }
    
}

// MARK: - Json To Model
/**
 Extension the json:
 The json data to model's object.
 */
extension Json {
    
    /** The Json Model list */
    public static var classList: [String: JsonModelProtocol.Type] = [:]
    
    /**
     Use the json data to create model object.
     
     The model type must conform to JsonModelProtocol protocol and set into Json.classList.
     
     <T: JsonModelProtocol>: the return data model type
     
     - parameter data: the json data
     
     - returns: Data model obejct
     */
    public class func toModel<T: JsonModelProtocol>(_ data: Data?) -> T? {
        if let data = data {
            if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) {
                if let dic = json as? [String: Any] {
                    let model = T.init()
                    for (k, v) in dic {
                        model.setModelValue(key: k, json: v)
                    }
                    return model
                }
            }
        }
        return nil
    }
    
    /**
     Use the json data to create model object.
     
     The model type must conform to JsonAdaptProtocol protocol.
     
     <T: JsonAdaptProtocol>: the return data model type
     
     - parameter data: the json data
     
     - returns: Data model obejct
     */
    public class func toObject<T: JsonAdaptProtocol>(_ data: Data?) -> T? {
        if let json = Json(data: data) {
            return T.init(adapt: json)
        }
        return nil
    }
}

// MARK: - Json Model Protocol

/**
 The Json Model Protocol
 
 Must override the `func setValue(_ value: Any?, forUndefinedKey key: String)` function.
 
 func setValue(_ value: Any?, forUndefinedKey key: String) {
     print("\(self) -> key: \(key) is Undefined; value: \(value);")
 }
 */
public protocol JsonModelProtocol: NSObjectProtocol {
    init()
}

extension JsonModelProtocol {
    
    /**
     Set the json data to properties.
     
     - parameter data: json data
     */
    public func toModel(data: Data?) {
        if let data = data {
            if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) {
                if let dic = json as? [String: Any] {
                    for (k, v) in dic {
                        setModelValue(key: k, json: v)
                    }
                }
            }
        }
    }
    
    /**
     Set the json data to properties.
     
     - parameter key: the value key
     - parameter json: dictionary or array or value
     */
    public func setModelValue(key: String, json: Any) {
        // if json is a dictionary, may be is Dictionary/Model
        if let dic = json as? [String: Any] {
            // Model
            if let type = Json.classList[key] {
                let sub = type.init()
                for (k, v) in dic {
                    sub.setModelValue(key: k, json: v)
                }
            }
            // Dictionary
            else {
                (self as AnyObject).setValue(dic, forKey: key)
            }
        }
        // if json is array, may be is a Array/[Model]
        else if let arr = json as? [Any] {
            // [Model]
            if let type = Json.classList[key], let dics = json as? [[String: Any]] {
                var subs: [JsonModelProtocol] = []
                for value in dics {
                    let sub = type.init()
                    for (k, v) in value {
                        sub.setModelValue(key: k, json: v)
                    }
                    subs.append(sub)
                }
                (self as AnyObject).setValue(subs, forKey: key)
            }
            // Array
            else {
                (self as AnyObject).setValue(arr, forKey: key)
            }
        }
        // Else is a value
        else {
            (self as AnyObject).setValue(json, forKey: key)
        }
    }
    
}

// MARK: - Json Adapt Protocol

public protocol JsonAdaptProtocol {
    init?(adapt json: Json)
}

