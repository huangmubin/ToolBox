//
//  Bluetooth.swift
//  BluetoothTestDemo
//
//  Created by Myron on 2017/10/19.
//  Copyright © 2017年 Myron. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: - 基类

class Bluetooth: NSObject {
    
    /** 外设服务 */
    var services: [String: CBService] = [:]
    
    /** 外设字符 */
    var charateristics: [String: CBCharacteristic] = [:]
    
    //
    var log_open: Bool = true
    
    func log_tool(_ message: String, local: String = #function) {
        if log_open {
            print("Bluetooth: \(local) >> \(message)")
        }
    }
    
    func log_propertie(_ propertie: CBCharacteristicProperties) -> String {
        switch propertie {
        case CBCharacteristicProperties.authenticatedSignedWrites:
            return "authenticatedSignedWrites"
        case CBCharacteristicProperties.broadcast:
            return "broadcast"
        case CBCharacteristicProperties.extendedProperties:
            return "extendedProperties"
        case CBCharacteristicProperties.indicate:
            return "indicate"
        case CBCharacteristicProperties.indicateEncryptionRequired:
            return "indicateEncryptionRequired"
        case CBCharacteristicProperties.notify:
            return "notify"
        case CBCharacteristicProperties.notifyEncryptionRequired:
            return "notifyEncryptionRequired"
        case CBCharacteristicProperties.read:
            return "read"
        case CBCharacteristicProperties.write:
            return "write"
        case CBCharacteristicProperties.writeWithoutResponse:
            return "writeWithoutResponse"
        default:
            return "other"
        }
    }
    
    func log_value_16(_ value: Data) -> String {
        let values = [UInt8](value)
        var message = "["
        for v in values {
            message += String(format: "0x%X, ", v)
        }
        return message + "]"
    }
    
}

// MARK: - 辅助方法

class BluetoothTools: Bluetooth, CBCentralManagerDelegate {
    
    /** 主设备管理对象 */
    var manager: CBCentralManager?
    
    var complete: ((Bool) -> Void)?
    
    func is_open(_ complete: @escaping (Bool) -> Void) {
        self.complete = complete
        manager = CBCentralManager(
            delegate: self,
            queue: nil,
            options: nil
        )
    }
    
    // MARK: - CBCentralManagerDelegate
    
    // 设备蓝牙状态变化监听，在获取 manager 时以及状态变化时会调用。
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            complete?(true)
        default:
            complete?(false)
        }
        complete = nil
        manager  = nil
    }
    
}

// MARK: - 中心设备

/**
 蓝牙工具: 中心设备
 */
class BluetoothCentral: Bluetooth, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: - Values
    
    /** 主设备管理对象 */
    var manager: CBCentralManager?
    
    /** 外设 */
    var peripherals: [String: CBPeripheral] = [:]
    var peripherals_total: [CBPeripheral] = []
    
    /** 设置为 true，会自动监听 CBCharacteristicProperties.broadcast, CBCharacteristicProperties.notify, CBCharacteristicProperties.notifyEncryptionRequired 类型的 charateristic */
    var auto_listen_notify: Bool = true
    
    // MARK: - Methods
    
    /** 创建蓝牙管理，并检测状态，如果打开则开始扫描 */
    func open(queue: DispatchQueue? = nil, options: [String: Any]? = nil) {
        manager = CBCentralManager(
            delegate: self,
            queue: queue,
            options: options
        )
    }
    
    // MARK: - CBCentralManagerDelegate
    
    // 设备蓝牙状态变化监听，在获取 manager 时以及状态变化时会调用。
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetooth_central_manager_state_update(state: central.state)
        switch central.state {
        case .unknown:      log_tool("unknown")
        case .resetting:    log_tool("resetting")
        case .unsupported:  log_tool("unsupported")
        case .unauthorized: log_tool("unauthorized")
        case .poweredOff:   log_tool("poweredOff")
        case .poweredOn:    log_tool("poweredOn")
        //开始扫描周围的外设
        /*
         第一个参数nil就是扫描周围所有的外设，扫描到外设后会进入
         func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
         */
        manager?.scanForPeripherals(
            withServices: nil,
            options: nil
            )
        }
    }
    
    // 扫描外设
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals_total.contains(peripheral) {
            log_tool("name: \(String(describing: peripheral.name)); RSSI: \(RSSI);")
            peripherals_total.append(peripheral)
            if let key = bluetooth_central_manager_discover(
                    peripheral: peripheral,
                    name: peripheral.name,
                    advertisementData: advertisementData
                ) {
                peripherals[key] = peripheral
                manager?.connect(peripheral, options: nil)
            }
        }
    }
    
    func centralManagerStopScan() {
        peripherals_total.removeAll()
        manager?.stopScan()
    }
    
    // MARK: - CBPeripheralDelegate
    
    //连接到Peripherals-成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log_tool("Connect \(String(describing: peripheral.name)) success.")
        bluetooth_central_manager_connect_success(peripheral: peripheral, name: peripheral.name)
        
        //设置的peripheral委托CBPeripheralDelegate
        peripheral.delegate = self
        
        //扫描外设Services，成功后会进入方法：func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
        peripheral.discoverServices(nil)
    }
    
    //连接到Peripherals-失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log_tool("Connect \(String(describing: peripheral.name)) error. >> error: \(String(describing: error))")
        bluetooth_central_manager_connect_error(peripheral: peripheral, name: peripheral.name, error: error)
    }
    
    //Peripherals断开连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log_tool("\(String(describing: peripheral.name)) is disconnect. >> error: \(String(describing: error))")
        bluetooth_central_manager_disconnect(peripheral: peripheral, name: peripheral.name, error: error)
    }
    
    // 扫描外设中的服务和特征(discover)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let value = error {
            log_tool("name: \(String(describing: peripheral.name)); error: \(value)")
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                log_tool("name: \(String(describing: peripheral.name)); server: \(service.uuid.uuidString);")
                if let key = bluetooth_central_manager_discover_service(peripheral: peripheral, service: service, name: service.uuid.uuidString) {
                    self.services[key] = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
        else {
            log_tool("name: \(String(describing: peripheral.name)); error: (no services)")
        }
    }
    
    // 扫描 Characteristic 特征符
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let value = error {
            log_tool("name: \(String(describing: peripheral.name)); service: \(service.uuid.uuidString); error: \(value)")
        }
        else if let characteristics = service.characteristics {
            for characteristic in characteristics {
                log_tool("name: \(String(describing: peripheral.name)); service: \(service.uuid.uuidString); characteristic: \(characteristic.uuid.uuidString); propertie: \(log_propertie(characteristic.properties))")
                if let key = bluetooth_central_manager_discover_charateristics(peripheral: peripheral, service: service, characteristic: characteristic, name: characteristic.uuid.uuidString, properties: characteristic.properties) {
                    self.charateristics[key] = characteristic
                    if auto_listen_notify {
                        switch characteristic.properties {
                        case CBCharacteristicProperties.broadcast, CBCharacteristicProperties.notify, CBCharacteristicProperties.notifyEncryptionRequired:
                            peripheral.setNotifyValue(true, for: characteristic)
                        default:
                            break
                        }
                    }
                    bluetooth_central_manager_discovered_charateristics(peripheral: peripheral, service: service, characteristic: characteristic, name: characteristic.uuid.uuidString, properties: characteristic.properties)
                }
            }
        }
        else {
            log_tool("name: \(String(describing: peripheral.name)); service: \(service.uuid.uuidString); error: (no characteristics)")
        }
    }

    // MARK: - 接收到数据
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        var data: [UInt8] = []
        if let value = error {
            log_tool("name: \(String(describing: peripheral.name)); characteristic: \(characteristic.uuid.uuidString); error: \(value)")
        }
        else if let value = characteristic.value {
            log_tool("name: \(String(describing: peripheral.name)); characteristic: \(characteristic.uuid.uuidString); value: \(log_value_16(value))")
            data = [UInt8](value)
        }
        else {
            log_tool("name: \(String(describing: peripheral.name)); characteristic: \(characteristic.uuid.uuidString); error: (no values)")
        }
        bluetooth_central_manager_update_value(peripheral: peripheral, didUpdateValueFor: characteristic, error: error, value: data)
    }
    
    // MARK: - 写数据
    
    func writeCharacter(peripheral: CBPeripheral, characteristic: CBCharacteristic, value: Data) {
        if characteristic.properties.contains(CBCharacteristicProperties.write) {
            peripheral.writeValue(
                value,
                for: characteristic,
                type: CBCharacteristicWriteType.withResponse
            )
            log_tool("name: \(String(describing: peripheral.name)); characteristic: \(characteristic.uuid.uuidString); proerties: \(log_propertie(characteristic.properties)); write: \(log_value_16(value))")
        }
        else {
            log_tool("name: \(String(describing: peripheral.name)); characteristic: \(characteristic.uuid.uuidString); proerties: \(log_propertie(characteristic.properties)); error: (can't write propertie)")
        }
    }
}

// MARK: - Sub Methods

// 根据需要重新这些方法
extension BluetoothCentral {
    
    /** 
     1. 本机蓝牙状态变化调用，如果打开会自动开启扫描外设 
     */
    
    #if os(OSX)
    func bluetooth_central_manager_state_update(state: CBCentralManagerState) {
    
    }
    #elseif os(iOS)
    func bluetooth_central_manager_state_update(state: CBManagerState) {
        
    }
    #endif
    
    /** 
     2. 获取到外设的回调。
     返回 String 会对该外设进行备注在 var peripherals: [String: CBPeripheral] 字典中。
     如果是需要的设备，请调用 manager?.connect(peripheral, options: nil)
     如果已经不需要扫描了，请调用 func centralManagerStopScan()
     */
    func bluetooth_central_manager_discover(peripheral: CBPeripheral, name: String?, advertisementData data: [String : Any]) -> String? {
        return nil
    }
    
    /**
     2.1 连接成功的回调
     */
    func bluetooth_central_manager_connect_success(peripheral: CBPeripheral, name: String?) {
        
    }
    
    /**
     2.2 连接失败的回调
     */
    func bluetooth_central_manager_connect_error(peripheral: CBPeripheral, name: String?, error: Error?) {
        
    }
    
    /**
     3. 扫描到外设中的服务
     */
    func bluetooth_central_manager_discover_service(peripheral: CBPeripheral, service: CBService, name: String) -> String? {
        return nil
    }
    
    /**
     4. 扫描到外设服务中的特征符，然后就可以用这些特征符进行通讯了。
     如果需要监听某个数据通知，则调用 peripheral.setNotifyValue(true, for: characteristic)
     如果需要检查类型，可以用
     switch propertie {
     case CBCharacteristicProperties.authenticatedSignedWrites: break
     case CBCharacteristicProperties.broadcast: break
     case CBCharacteristicProperties.extendedProperties: break
     case CBCharacteristicProperties.indicate: break
     case CBCharacteristicProperties.indicateEncryptionRequired: break
     case CBCharacteristicProperties.notify: break
     case CBCharacteristicProperties.notifyEncryptionRequired: break
     case CBCharacteristicProperties.read: break
     case CBCharacteristicProperties.write: break
     case CBCharacteristicProperties.writeWithoutResponse: break
     default: break
     }
     */
    func bluetooth_central_manager_discover_charateristics(peripheral: CBPeripheral, service: CBService, characteristic: CBCharacteristic, name: String, properties: CBCharacteristicProperties) -> String? {
        return nil
    }
    
    /**
     4.1 设置完外设，可以开始收发数据
     */
    func bluetooth_central_manager_discovered_charateristics(peripheral: CBPeripheral, service: CBService, characteristic: CBCharacteristic, name: String, properties: CBCharacteristicProperties) {
    
    }
    
    /**
     5.1 接收到数据
     */
    func bluetooth_central_manager_update_value(peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?, value: [UInt8]) {
        
    }
    
    /**
     5.2 写数据
     */
    func bluetooth_central_manager_send(peripheral: CBPeripheral, characteristic: CBCharacteristic, value: Data) {
        writeCharacter(peripheral: peripheral, characteristic: characteristic, value: value)
    }
    
    func bluetooth_central_manager_send(name: String, character: String, value: Data) {
        if let peripheral = peripherals[name], let char = charateristics[character] {
            writeCharacter(peripheral: peripheral, characteristic: char, value: value)
        }
    }
    
    /**
     6. 断开连接的回调
     主动断开可以调用
     manager?.cancelPeripheralConnection(peripheral: CBPeripheral)
     */
    func bluetooth_central_manager_disconnect(peripheral: CBPeripheral, name: String?, error: Error?) {
    }
}

// MARK: - 外设

class BluetoothPeripheral: Bluetooth, CBPeripheralManagerDelegate {
    
    /** 外设管理 */
    var manager: CBPeripheralManager?
    
    // MARK: - Methods
    
    /** 创建蓝牙管理，并检测状态，如果打开则开始扫描 */
    func open(queue: DispatchQueue? = nil, options: [String: Any]? = nil) {
        manager = CBPeripheralManager(
            delegate: self,
            queue: queue,
            options: options
        )
    }
    
    // MARK: - CBPeripheralManagerDelegate
    
    /** 
     状态更新，启动后会自动调用一次
     通常在这时候调用 manager?.add(service: CBMutableService)
     */
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        bluetooth_peripheral_manager_state_update()
        switch peripheral.state {
        case .unknown:      log_tool("unknown")
        case .resetting:    log_tool("resetting")
        case .unsupported:  log_tool("unsupported")
        case .unauthorized: log_tool("unauthorized")
        case .poweredOff:   log_tool("poweredOff")
        case .poweredOn:    log_tool("poweredOn")
            bluetooth_peripheral_manager_deploy_service()
            for service in services {
                manager?.add(service.value as! CBMutableService)
            }
        }
    }
    
    /**
     调用 manager?.add(service: CBMutableService) 之后会调用
     通常会调用 manager?.startAdvertising(advertisementData: [String : Any]?) 来发送广播
     manager?.startAdvertising([
         CBAdvertisementDataServiceUUIDsKey: [
             CBUUID
         ],
         CBAdvertisementDataLocalNameKey: String
     ])
     然后会调用 func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?)
     */
    var add_service: [CBService] = []
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let value = error {
            log_tool("name: \(service.uuid.uuidString); error: \(value)")
        }
        else {
            log_tool("name: \(service.uuid.uuidString)")
            if !add_service.contains(service) {
                add_service.append(service)
                if add_service.count == services.count {
                    manager?.startAdvertising([
                        CBAdvertisementDataServiceUUIDsKey: add_service.flatMap({ return $0.uuid })
                    ])
                }
            }
        }
    }
    
    /**
     设备开始广播
     */
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        log_tool("error: \(String(describing: error))")
    }
    
    /**
     设备字符被订阅了
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        log_tool("central: \(central.identifier.uuidString); characteristic: \(characteristic.uuid.uuidString)")
    }
    
    /**
     设备字符被取消订阅
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        log_tool("central: \(central.identifier.uuidString); characteristic: \(characteristic.uuid.uuidString)")
    }
    
    /**
     收到读取请求
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        log_tool("central: \(request.central.identifier.uuidString); characteristic: \(request.characteristic.uuid.uuidString); value: \(request.value != nil ? log_value_16(request.value!) : "nil")")
    }
    
    /**
     收到输入请求
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            log_tool("central: \(request.central.identifier.uuidString); characteristic: \(request.characteristic.uuid.uuidString); value: \(request.value != nil ? log_value_16(request.value!) : "nil")")
        }
    }
    
    /**
     准备好来更新订阅
     */
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        log_tool("")
    }
    
}

extension BluetoothPeripheral {
    
    /**
     1. 更新蓝牙状态
     */
    func bluetooth_peripheral_manager_state_update() {
        
    }
    
    /**
     2. 蓝牙状态正常，开始设置
     */
    func bluetooth_peripheral_manager_deploy_service() {
        let service = CBMutableService(
            type: CBUUID(string: "FFF0"),
            primary: true
        )
        
        let read = CBMutableCharacteristic(
            type: CBUUID(string: "FFA1"),
            properties: CBCharacteristicProperties.read,
            value: nil,
            permissions: CBAttributePermissions.readable
        )
        
        let write = CBMutableCharacteristic(
            type: CBUUID(string: "FFA2"),
            properties: CBCharacteristicProperties.write,
            value: nil,
            permissions: CBAttributePermissions.writeable
        )
        
        let notify = CBMutableCharacteristic(
            type: CBUUID(string: "FFA3"),
            properties: CBCharacteristicProperties.notify,
            value: nil,
            permissions: CBAttributePermissions.readable
        )
        
        service.characteristics = [
            read,
            write,
            notify
        ]
        
        services["TestService"] = service
        charateristics["readCharacteristic"] = read
        charateristics["writeCharacteristic"] = write
        charateristics["notifyCharacteristic"] = notify
    }
    
    /**
     
     */
    
    /**
     
     */
    
    /**
     
     */
}
