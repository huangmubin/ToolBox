//
//  Socket.swift
//  Socket10
//
//  Created by Myron on 2017/4/13.
//  Copyright © 2017年 Myron. All rights reserved.
//

import Foundation

// MARK: - C
// MARK: Tools

 @_silgen_name("socket_input") private func c_socket_input(input: UnsafePointer<UInt8>, length: Int32) -> Void
 @_silgen_name("socket_host_address") private func c_socket_host_address() -> UnsafePointer<UInt8>

// MARK: Close

 @_silgen_name("socket_close") private func c_socket_close(socket: Int32) -> Int32
 @_silgen_name("socket_shutdown") private func c_socket_shutdown(socket: Int32, howto: Int32) -> Int32

// MARK: TCP

@_silgen_name("socket_tcp_new_server") private func c_socket_tcp_create_server(port: Int32, listens: Int32) -> Int32

@_silgen_name("socket_tcp_new_client") private func c_socket_tcp_create_client(address: UnsafePointer<UInt8>, port: Int32, sec: Int32, usec: Int32) -> Int32

@_silgen_name("socket_tcp_accept") private func c_socket_tcp_accept(socket: Int32, address: UnsafePointer<UInt8>, port: UnsafePointer<Int32>, sec: Int32, usec: Int32) -> Int32


// MARK: UDP

@_silgen_name("socket_udp_server") private func c_socket_udp_server(port: Int32) -> Int32
@_silgen_name("socket_udp_client") private func c_socket_udp_client() -> Int32
@_silgen_name("socket_opt") private func c_socket_opt(socket: Int32, open: Int32) -> Void

// MARK: Write

@_silgen_name("socket_write_t") private func c_socket_write_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, sec: Int32, usec: Int32) -> Int32
@_silgen_name("socket_send_t") private func c_socket_send_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, sec: Int32, usec: Int32) -> Int32
@_silgen_name("socket_sendto_t") private func c_socket_sendto_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, address: UnsafePointer<UInt8>, port: Int32, sec: Int32, usec: Int32) -> Int32

// MARK: Read

@_silgen_name("socket_read_t") private func c_socket_read_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, sec: Int32, usec: Int32) -> Int32
@_silgen_name("socket_recv_t") private func c_socket_recv_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, sec: Int32, usec: Int32) -> Int32
@_silgen_name("socket_recvfrom_t") private func c_socket_recvfrom_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, fromAddress: UnsafePointer<UInt8>, fromPort: UnsafePointer<Int32>, sec: Int32, usec: Int32) -> Int32

// MARK: - Error

extension Socket {
    
    enum SocketError: Int32, Error {
        case socket         = -1
        case bind           = -2
        case listion        = -3
        case accept         = -4
        case connect        = -5
        case reuseaddr      = -6
        case read           = -7
        case write          = -8
        case select         = -9
        case timeout        = -10
        
        static func `try`(_ value: Int32) throws {
            if let error = SocketError(rawValue: value) {
                throw error
            }
        }
    }
    
}

// MARK: - Type

extension Socket {
    
    enum SocketType {
        case tcp_server
        case tcp_client
        case udp_server
        case udp_client
        
        func toString() -> String {
            switch self {
            case .tcp_server:
                return "TCP Server"
            case .tcp_client:
                return "TCP Client"
            case .udp_server:
                return "UDP Server"
            case .udp_client:
                return "UDP Client"
            }
        }
    }
    
}

// MARK: - Status
/*
 extension Socket {
     enum SocketStatus {
         case deploying
         case connecting
         case chating
         case closed
         
         func toString() -> String {
             switch self {
                 case .deploying:
                 return "Deploying"
                 case .connecting:
                 return "Connecting"
                 case .chating:
                 return "Chating"
                 case .closed:
                 return "Closed"
             }
         }
     }
 }
 */
// MARK: - Socket

class Socket {
    
    var socket: Int32?
    var address: String = ""
    var port: Int32 = 0
    
    var flag: Int32 = 0
    
    var isBroadcast = false
    
    var type: SocketType = SocketType.tcp_server
    
    init() { }
    
    init(tcp_server_port port: Int32, listens: Int32 = 1) throws {
        let result = c_socket_tcp_create_server(port: port, listens: listens)
        try SocketError.try(result)
        self.socket  = result
        self.address = String(cString: c_socket_host_address())
        self.port    = port
        self.type    = .tcp_server
    }
    
    init(tcp_client_port port: Int32, address: String, time: TimeInterval = 0) throws {
        let time_f = modf(time)
        let sec = Int32(time_f.0)
        let usec = Int32(time_f.1 * 1000000)
        
        let result = c_socket_tcp_create_client(address: address, port: port, sec: sec, usec: usec)
        try SocketError.try(result)
        self.socket  = result
        self.address = address
        self.port    = port
        self.type    = .tcp_client
    }
    
    init(udp_server_port port: Int32) throws {
        let result = c_socket_udp_server(port: port)
        try SocketError.try(result)
        self.socket  = result
        self.address = String(cString: c_socket_host_address())
        self.port    = port
        self.type    = .udp_server
    }
    
    init(udp_client_port port: Int32) throws {
        let result = c_socket_udp_client()
        try SocketError.try(result)
        self.socket  = result
        self.address = String(cString: c_socket_host_address())
        self.port    = port
        self.type    = .udp_client
    }
    
}

// MARK: - Deploy

extension Socket {
    
    func tcp_server(port: Int32, listens: Int32 = 1) throws {
        let result = c_socket_tcp_create_server(port: port, listens: listens)
        try SocketError.try(result)
        self.socket  = result
        self.address = String(cString: c_socket_host_address())
        self.port    = port
        self.type    = .tcp_server
    }
    
    func tcp_client(port: Int32, address: String, time: TimeInterval = 0) throws {
        let time_f = modf(time)
        let sec = Int32(time_f.0)
        let usec = Int32(time_f.1 * 1000000)
        let result = c_socket_tcp_create_client(address: address, port: port, sec: sec, usec: usec)
        try SocketError.try(result)
        self.socket  = result
        self.address = address
        self.port    = port
        self.type    = .tcp_client
    }
    
    func udp_server(port: Int32) throws {
        let result = c_socket_udp_server(port: port)
        try SocketError.try(result)
        self.socket  = result
        self.address = String(cString: c_socket_host_address())
        self.port    = port
        self.type    = .udp_server
    }
    
    func udp_client(port: Int32 = 9999) throws {
        let result = c_socket_udp_client()
        try SocketError.try(result)
        self.socket  = result
        self.address = String(cString: c_socket_host_address())
        self.port    = port
        self.type    = .udp_client
    }
    
}

// MARK: - Normal

extension Socket {
    
    enum ShutDown: Int32 {
        case read = 0
        case write = 1
        case read_write = 2
        
    }
    
    @discardableResult
    func close() throws -> Bool {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        return c_socket_close(socket: socket) == 0
    }
    
    @discardableResult
    func shutdown(_ type: ShutDown) throws -> Bool {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        switch type {
        case .read:
            return c_socket_shutdown(socket: socket, howto: SHUT_RD) == 0
        case .write:
            return c_socket_shutdown(socket: socket, howto: SHUT_WR) == 0
        case .read_write:
            return c_socket_shutdown(socket: socket, howto: SHUT_RDWR) == 0
        }
    }
    
}

// MARK: - Tcp

extension Socket {
    
    func accept(time: TimeInterval) throws -> Socket {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        let time_f = modf(time)
        let sec = Int32(time_f.0)
        let usec = Int32(time_f.1 * 1000000)
        var remoteHost: [UInt8] = [UInt8](repeating: 0x0, count: 16)
        var remotePort: Int32   = 0
        let client = c_socket_tcp_accept(socket: socket, address: remoteHost, port: &remotePort, sec: sec, usec: usec)
        try SocketError.try(client)
        
        let client_socket = Socket()
        client_socket.socket  = client
        client_socket.address = String(cString: &remoteHost)
        client_socket.port    = remotePort
        return client_socket
    }
    
}

// MARK: - UDP

extension Socket {
    
    func broadcast(isOpen: Bool) throws {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        let open: Int32 = isOpen ? 1 : 0
        c_socket_opt(socket: socket, open: open)
        self.isBroadcast = isOpen
    }
    
}

// MARK: - Read

extension Socket {
    
    func read(byte_length length: Int32, time: TimeInterval = 0) throws -> [UInt8] {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        let time_f  = modf(time)
        let sec     = Int32(time_f.0)
        let usec    = Int32(time_f.1 * 1000000)
        let buffer = [UInt8](repeating: 0x0, count: Int(length))
        let r_size = c_socket_read_t(socket: socket, buffer: buffer, length: length, sec: sec, usec: usec)
        try SocketError.try(r_size)
        return Array(buffer[0 ..< Int(r_size)])
    }
    func read(text_length length: Int32, time: TimeInterval = 0) throws -> String {
        let byte = try read(byte_length: length, time: time)
        return String(cString: byte)
    }
    func read(data_length length: Int32, time: TimeInterval = 0) throws -> Data {
        let byte = try read(byte_length: length, time: time)
        return Data(bytes: byte)
    }
    
    func recv(byte_length length: Int32, time: TimeInterval = 0) throws -> [UInt8] {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        let time_f  = modf(time)
        let sec     = Int32(time_f.0)
        let usec    = Int32(time_f.1 * 1000000)
        let buffer = [UInt8](repeating: 0x0, count: Int(length))
        let r_size = c_socket_recv_t(socket: socket, buffer: buffer, length: length, sec: sec, usec: usec)
        try SocketError.try(r_size)
        return Array(buffer[0 ..< Int(r_size)])
    }
    func recv(text_length length: Int32, time: TimeInterval = 0) throws -> String {
        let byte = try recv(byte_length: length, time: time)
        return String(cString: byte)
    }
    func recv(data_length length: Int32, time: TimeInterval = 0) throws -> Data {
        let byte = try recv(byte_length: length, time: time)
        return Data(bytes: byte)
    }
    
    
    func recvfrom(byte_length length: Int32, time: TimeInterval = 0) throws -> ([UInt8], String, Int32) {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        let time_f  = modf(time)
        let sec     = Int32(time_f.0)
        let usec    = Int32(time_f.1 * 1000000)
        let buffer  = [UInt8](repeating: 0x0, count: Int(length))
        let address = [UInt8](repeating: 0x0, count: 16)
        var port    = Int32(0)
        let r_size = c_socket_recvfrom_t(socket: socket, buffer: buffer, length: length, fromAddress: address, fromPort: &port, sec: sec, usec: usec)
        try SocketError.try(r_size)
        return (Array(buffer[0 ..< Int(r_size)]), String(cString: address), port)
    }
    func recvfrom(text_length length: Int32, time: TimeInterval = 0) throws -> (String, String, Int32) {
        let result = try recvfrom(byte_length: length, time: time)
        return (String(cString: result.0), result.1, result.2)
    }
    func recvfrom(data_length length: Int32, time: TimeInterval = 0) throws -> (Data, String, Int32) {
        let result = try recvfrom(byte_length: length, time: time)
        return (Data(bytes: result.0), result.1, result.2)
    }
    
}

// MARK: - Write

extension Socket {
    
    func write(byte: [UInt8], time: TimeInterval = 0) throws {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        let time_f  = modf(time)
        let sec     = Int32(time_f.0)
        let usec    = Int32(time_f.1 * 1000000)
        let w_size = c_socket_write_t(socket: socket, buffer: byte, length: Int32(byte.count), sec: sec, usec: usec)
        try SocketError.try(w_size)
    }
    func write(text: String, time: TimeInterval = 0) throws {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        let time_f  = modf(time)
        let sec     = Int32(time_f.0)
        let usec    = Int32(time_f.1 * 1000000)
        let w_size = c_socket_write_t(socket: socket, buffer: text, length: Int32(text.count), sec: sec, usec: usec)
        //let w_size = c_socket_write_t(socket: socket, buffer: text, length: Int32(text.characters.count), sec: sec, usec: usec)
        try SocketError.try(w_size)
    }
    func write(data: Data, time: TimeInterval = 0) throws {
        try write(byte: data.map({ return $0 }), time: time)
    }
    
    func send(byte: [UInt8], time: TimeInterval = 0) throws {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        let time_f  = modf(time)
        let sec     = Int32(time_f.0)
        let usec    = Int32(time_f.1 * 1000000)
        let w_size = c_socket_send_t(socket: socket, buffer: byte, length: Int32(byte.count), sec: sec, usec: usec)
        try SocketError.try(w_size)
    }
    func send(text: String, time: TimeInterval = 0) throws {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        let time_f  = modf(time)
        let sec     = Int32(time_f.0)
        let usec    = Int32(time_f.1 * 1000000)
        let w_size = c_socket_send_t(socket: socket, buffer: text, length: Int32(text.count), sec: sec, usec: usec)
        //let w_size = c_socket_send_t(socket: socket, buffer: text, length: Int32(text.characters.count), sec: sec, usec: usec)
        try SocketError.try(w_size)
    }
    func send(data: Data, time: TimeInterval = 0) throws {
        try write(byte: data.map({ return $0 }), time: time)
    }
    
    func sendto(byte: [UInt8], address: String? = nil, port: Int32? = nil, time: TimeInterval = 0) throws {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        let address = address ?? (isBroadcast ? "255.255.255.255" : self.address)
        let port    = port ?? self.port
        
        let time_f  = modf(time)
        let sec     = Int32(time_f.0)
        let usec    = Int32(time_f.1 * 1000000)
        let length = Int32(byte.count)
        let w_size = c_socket_sendto_t(socket: socket, buffer: byte, length: length, address: address, port: port, sec: sec, usec: usec)
        try SocketError.try(w_size)
    }
    func sendto(text: String, address: String? = nil, port: Int32? = nil, time: TimeInterval = 0) throws {
        guard let socket = self.socket else {
            throw SocketError.socket
        }
        let address = address ?? (isBroadcast ? "255.255.255.255" : self.address)
        let port    = port ?? self.port
        
        let time_f  = modf(time)
        let sec     = Int32(time_f.0)
        let usec    = Int32(time_f.1 * 1000000)
        let length = Int32(text.count)
        //let length = Int32(text.characters.count)
        let w_size = c_socket_sendto_t(socket: socket, buffer: text, length: length, address: address, port: port, sec: sec, usec: usec)
        try SocketError.try(w_size)
    }
    func sendto(data: Data, address: String? = nil, port: Int32? = nil, time: TimeInterval = 0) throws {
        try sendto(byte: data.map({ return $0 }), address: address, port: port, time: time)
    }
    
    
}

// MARK: - Socket Tools

extension Socket {
    
    class func host() -> String {
        return String(cString: c_socket_host_address())
    }
    
}


