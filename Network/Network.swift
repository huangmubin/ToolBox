//
//  Network.swift
//  NetworkTestProject
//
//  Created by 黄穆斌 on 2017/3/16.
//  Copyright © 2017年 MuBinHuang. All rights reserved.
//
/**
 import ~/Protocols/QueueProtocol.swift
 import ~/Network/SessionDelegate.swift
 */
import UIKit

// MARK: - Network
/**
 A Network Tools
 */
public class Network: NSObject {
    
    // MARK: - Network Data
    
    // MARK: Object
    
    /** network object identifier, use to print message. */
    public var identifier: String = ""
    
    public override var description: String {
        return "Network \(identifier), task = \(String(describing: tasks.current)), waiting number = \(tasks.datas.count), first in first out is \(tasks.isSequence), feedbackThread = \(String(describing: feedbackThread));"
    }
    
    /** print the message or not */
    public var isLogOpen: Bool = false
    
    fileprivate func logMessage(value: String) {
        if isLogOpen {
            print("Network \(identifier): " + value)
        }
    }
    
    // MARK: URLSession
    
    /** network session */
    private var session: URLSession?
    
    /** current running data task. */
    fileprivate var current: URLSessionDataTask?
    
    /** the session delegate object, weak the delegate. */
    private var sessionDelegate = SessionDelegateObject()
    
    // MARK: Thread
    
    /** operation queue */
    fileprivate let thread: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    /** The feedback queue */
    public var feedbackThread: DispatchQueue?
    
    // MARK: Tasks Queue
    
    /** A QueueControl<Network.Task>, control the tasks */
    fileprivate var tasks = QueueControl<Network.Task>()
    
    // MARK: - Init
    
    /**
     Initialize a network object.
     - parameter identifier: object identifier, default "".
     - returns: Network object
     */
    init(identifier: String = "", isLog: Bool = false) {
        super.init()
        self.identifier = identifier
        self.session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: thread)
        self.sessionDelegate.network = self
        self.isLogOpen = isLog
        self.logMessage(value: "Init")
    }
    
    /**
     Clear the session.
     */
    deinit {
        session?.invalidateAndCancel()
        self.logMessage(value: "Deinit")
    }
    
    
    // MARK: - Runing Loop
    
    /**
     Use the task queue to start the network.
     */
    fileprivate func loop() {
        thread.addOperation {
            self.logMessage(value: "loop next; tasks = \(self.tasks.datas.count); current = \(String(describing: self.tasks.current?.id));")
            if self.tasks.next() {
                if let request = self.tasks.current?.request {
                    let dataTask = self.session?.dataTask(with: request)
                    dataTask?.taskDescription = self.tasks.current?.id
                    self.current = dataTask
                    self.logMessage(value: "resume the \(String(describing: self.tasks.current?.id)); \(String(describing: request.httpMethod)) : \(String(describing: request.url?.absoluteString)); headers = \(String(describing: request.allHTTPHeaderFields))")
                    self.current?.resume()
                }
                else {
                    self.loop()
                }
            }
        }
    }
    
    // MARK: - Task Methods
    
    
    /** Suspend the current task */
    public func suspend() {
        self.current?.suspend()
        self.logMessage(value: "suspend the \(String(describing: self.current?.taskDescription))")
    }
    
    /** Resume the current task */
    public func resume() {
        self.current?.resume()
        self.logMessage(value: "resume the \(String(describing: self.current?.taskDescription))")
    }
    
    /**
     Cancel the task with the id.
     - parameter id: The task id, if nil, is current.
     */
    public func cancel(id: String? = nil) {
        thread.addOperation {
            self.logMessage(value: "cancel the \(String(describing: id))")
            guard let id = id else {
                self.current?.cancel()
                return
            }
            self.tasks.remove(where: { $0.id == id })
        }
    }
    
    /**
     Clear all task.
     - parameter cancelCurrent: if true, will cancel the current task.
     */
    public func clear(cancelCurrent: Bool = false) {
        thread.addOperation {
            self.logMessage(value: "clear tasks, current = \(cancelCurrent)")
            self.tasks.removeAll()
            if cancelCurrent {
                self.current?.cancel()
            }
        }
    }
    
    /**
     Find the task.
     - parameter id: task id
     - parameter task: feedback the task, or nil
     */
    public func find(id: String, task: @escaping (Task?) -> Void) {
        thread.addOperation {
            if let data = self.tasks.find(where: { $0.id == id }) {
                self.logMessage(value: "find \(id) true.")
                task(data)
            }
            else {
                self.logMessage(value: "find \(id) false.")
                task(nil)
            }
        }
    }
    
    /**
     Let the assign task to the next task.
     
     - parameter id: task id
     */
    public func advanceToNext(id: String) {
        thread.addOperation {
            self.logMessage(value: "advanceToNext \(id).")
            self.tasks.advanceToNext(where: { $0.id == id })
        }
    }
    
    // MARK: - Network Interface
    
    /**
     Create a task and append to task queue.
     
     - parameter id: the Task identifier, must unique.
     - parameter url: URL
     - parameter method: httpMethod
     - parameter header: allHTTPHeaderFields
     - parameter body: httpBody
     - parameter timeout: timeoutInterval
     - parameter other: custom infos
     - parameter data: the all ready has data
     - parameter receiveResponse: feedback
     - parameter receiceData: feedback
     - parameter receiveComplete: feedback
     */
    private func createTask(
        id: String,
        url: String,
        method: String,
        header: [String: String]? = nil,
        body: Data? = nil,
        timeout: TimeInterval? = nil,
        other: Any? = nil,
        data: Data? = nil,
        receiveResponse: ((Network.Task) -> Void)? = nil,
        receiceData: ((Network.Task, Data) -> Void)? = nil,
        receiveComplete: ((Network.Task, Error?) -> Void)? = nil
        ) {
        thread.addOperation {
            // Check
            if self.tasks.contains(where: { $0.id == id }) {
                self.logMessage(value: "create task error, \(id)")
                return
            }
            
            // Create
            let task = Task()
            task.id = id
            task.request = Network.request(
                url: url,
                method: method,
                header: header,
                body: body,
                timeout: timeout
            )
            task.other = other
            task.data  = data
            task.receiveResponse = receiveResponse
            task.receiceData = receiceData
            task.receiveComplete = receiveComplete
            
            if task.request == nil {
                if let feedback = self.feedbackThread {
                    feedback.async {
                        self.logMessage(value: "create task error \(id); (request error) url = \(url); method = \(method); body = \(String(describing: body)); timeout = \(String(describing: timeout));")
                        task.receiveComplete?(task, NSError(domain: id, code: 0, userInfo: ["url": url, "method": method, "body": String(describing: body), "timeout":String(describing: timeout)]) as Error)
                    }
                }
                else {
                    self.logMessage(value: "create task error \(id); (request error) url = \(url); method = \(method); body = \(String(describing: body)); timeout = \(String(describing: timeout));")
                    task.receiveComplete?(task, NSError(domain: id, code: 0, userInfo: ["url": url, "method": method, "body": String(describing: body), "timeout":String(describing: timeout)]) as Error)
                }
            }
            else {
                self.tasks.push(task)
                self.logMessage(value: "create task success \(id)")
            }
        }
    }
    
    // MARK: GET PUT POST DELETE
    
    public func get(
        id: String = "",
        url: String,
        header: [String: String]? = nil,
        timeout: TimeInterval? = nil,
        other: Any? = nil,
        data: Data? = nil,
        receiveResponse: ((Network.Task) -> Void)? = nil,
        receiceData: ((Network.Task, Data) -> Void)? = nil,
        receiveComplete: ((Network.Task, Error?) -> Void)? = nil
        ) {
        createTask(
            id: id.isEmpty ? url : id,
            url: url,
            method: "GET",
            header: header,
            body: nil,
            timeout: timeout,
            other: other,
            data: data,
            receiveResponse: receiveResponse,
            receiceData: receiceData,
            receiveComplete: receiveComplete
        )
        loop()
    }
    
    public func put(
        id: String = "",
        url: String,
        header: [String: String]? = nil,
        body: Data? = nil,
        timeout: TimeInterval? = nil,
        other: Any? = nil,
        data: Data? = nil,
        receiveResponse: ((Network.Task) -> Void)? = nil,
        receiceData: ((Network.Task, Data) -> Void)? = nil,
        receiveComplete: ((Network.Task, Error?) -> Void)? = nil
        ) {
        createTask(
            id: id.isEmpty ? url : id,
            url: url,
            method: "PUT",
            header: header,
            body: body,
            timeout: timeout,
            other: other,
            data: data,
            receiveResponse: receiveResponse,
            receiceData: receiceData,
            receiveComplete: receiveComplete
        )
        loop()
    }
    
    public func post(
        id: String = "",
        url: String,
        header: [String: String]? = nil,
        body: Data? = nil,
        timeout: TimeInterval? = nil,
        other: Any? = nil,
        data: Data? = nil,
        receiveResponse: ((Network.Task) -> Void)? = nil,
        receiceData: ((Network.Task, Data) -> Void)? = nil,
        receiveComplete: ((Network.Task, Error?) -> Void)? = nil
        ) {
        createTask(
            id: id.isEmpty ? url : id,
            url: url,
            method: "POST",
            header: header,
            body: body,
            timeout: timeout,
            other: other,
            data: data,
            receiveResponse: receiveResponse,
            receiceData: receiceData,
            receiveComplete: receiveComplete
        )
        loop()
    }
    
    public func delete(
        id: String = "",
        url: String,
        header: [String: String]? = nil,
        body: Data? = nil,
        timeout: TimeInterval? = nil,
        other: Any? = nil,
        data: Data? = nil,
        receiveResponse: ((Network.Task) -> Void)? = nil,
        receiceData: ((Network.Task, Data) -> Void)? = nil,
        receiveComplete: ((Network.Task, Error?) -> Void)? = nil
        ) {
        createTask(
            id: id.isEmpty ? url : id,
            url: url,
            method: "Delete",
            header: header,
            body: body,
            timeout: timeout,
            other: other,
            data: data,
            receiveResponse: receiveResponse,
            receiceData: receiceData,
            receiveComplete: receiveComplete
        )
        loop()
    }
    
}

// MARK: - Netowrk Extension - SessionDelegate

extension Network: SessionDelegate {
    
    @objc(urlSession:dataTask:didReceiveResponse:)
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceiveResponse response: URLResponse) {
        self.tasks.current?.response = response
        if let http = response as? HTTPURLResponse {
            let length = http.allHeaderFields["Content-Length"] as? String
            self.tasks.current?.size = Int(length ?? "0") ?? 0
        }
        if let receive = self.tasks.current?.receiveResponse, let task = self.tasks.current {
            if let feedback = feedbackThread {
                feedback.async { [task = task, receive = receive] in
                    self.logMessage(value: "didReceiveResponse - \(task.id); code = \(task.code)")
                    receive(task)
                }
            }
            else {
                self.logMessage(value: "didReceiveResponse - \(task.id); code = \(task.code)")
                receive(task)
            }
        }
        else {
            self.logMessage(value: "didReceiveResponse - \(String(describing: dataTask.taskDescription));")
        }
    }
    
    @objc(urlSession:dataTask:didReceiveData:)
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data) {
        guard let task = self.tasks.current else {
            return
        }
        
        // Data
        if task.data == nil {
            task.data = data
        }
        else {
            task.data?.append(data)
        }
        
        // Feedback
        if let receive = task.receiceData {
            if let feedback = feedbackThread {
                feedback.async { [task = task, data = data, receive = receive] in
                    receive(task, data)
                }
            }
            else {
                receive(task, data)
            }
        }
    }
    
    @objc(urlSession:task:didCompleteWithError:)
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            // Clear
            self.tasks.done()
            self.current = nil
            self.loop()
        }
        
        // Feedback
        if let receive = self.tasks.current?.receiveComplete,
            let task = self.tasks.current {
            if let feedback = feedbackThread {
                feedback.async { [task = task, error = error, receive = receive] in
                    self.logMessage(value: "didCompleteWithError - \(task.id); error = \(String(describing: error));")
                    receive(task, error)
                }
            }
            else {
                self.logMessage(value: "didCompleteWithError - \(task.id); error = \(String(describing: error));")
                receive(task, error)
            }
        }
        else {
            self.logMessage(value: "didCompleteWithError - \(String(describing: task.taskDescription)); error = \(String(describing: error));")
        }
    }
    
}

// MARK: - Network Extension - Task

extension Network {
    /**
     A network response data object.
     Have all network infos.
     */
    public class Task {
        
        // MARK: - Response Datas
        
        // MARK: Object
        
        /** The request identifier. */
        public var id: String = ""
        
        /** The other custom data */
        public var other: Any?
        
        // MARK: Request
        
        /** The task request */
        public var request: URLRequest!
        
        // MARK: Response
        /** The task response */
        public var response: URLResponse?
        /** the task data */
        public var data: Data?
        /** the task error */
        public var error: Error?
        
        public var size: Int = 0
        /**  */
        public var note: String? {
            if let data = data {
                if let text = String(data: data, encoding: String.Encoding.utf8) {
                    return text
                }
            }
            return nil
        }
        
        // MARK: - Quick access data
        
        // MARK: Property
        
        /** the http response status code */
        public var code: Int {
            return (response as? HTTPURLResponse)?.statusCode ?? 0
        }
        
        // MARK: Method
        
        /**
         Get the http response header value.
         - parameter key: The header key
         - returns: key-value, if none will be a nil.
         */
        public func header<T>(_ key: String) -> T? {
            if let headers = (response as? HTTPURLResponse)?.allHeaderFields {
                return (headers[key] as? T)
            }
            return nil
        }
        
        /**
         Get value in other.
         
         - parameter key: The key
         - parameter null: if nill will return
         - returns: key-value, if none will be a nil.
         */
        public func otherInfo<T>(_ key: String, null: T) -> T {
            if let dic = other as? [String: Any] {
                if let data = dic[key] as? T {
                    return data
                }
            }
            return null
        }
        
        // MARK: - Feedback
        
        /** Call when receive task response. */
        public var receiveResponse: ((Network.Task) -> Void)?
        /** Call when receive datas. */
        public var receiceData: ((Network.Task, Data) -> Void)?
        /** Call when receive complete. */
        public var receiveComplete: ((Network.Task, Error?) -> Void)?
        
        init() {
            print("Network task \(self) init")
        }
        deinit {
            print("Network task \(self) deinit\n")
        }
        
    }
}

// MARK: - Network Tools

extension Network {
    
    /**
     Create a request.
     
     - parameter url: URL path
     - parameter method: httpMethod
     - parameter header: allHTTPHeaderFields
     - parameter body: httpBody
     - parameter timeout: timeoutInterval
     
     - returns: URLRequest
     */
    public class func request(
        url: String,
        method: String = "GET",
        header: [String: String]? = nil,
        body: Data? = nil,
        timeout: TimeInterval? = nil
        ) -> URLRequest? {
        guard let url = URL(string: url) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        if body != nil {
            request.httpBody = body
        }
        if header != nil {
            request.allHTTPHeaderFields = header
        }
        if timeout != nil {
            request.timeoutInterval = timeout!
        }
        return request
    }
    
    /**
     Create the request body json data.
     
     - parameter json: dictionary data
     
     - returns: Json Data
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
    
    /**
     Create the new header that append the range.
     
     - parameter values: old header
     - parameter size: size
     
     - returns: new header
     */
    public class func header(_ values: [String: String]?, size: Int) -> [String: String] {
        var header = values ?? [:]
        header["Range"] = "bytes=\(size)-"
        return header
    }
    
    
    /**
     base64
     */
    public class func base64(text: String) -> String? {
        let data = text.data(using: String.Encoding.utf8)
        return data?.base64EncodedString()
    }
    
    
}

