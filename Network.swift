//
//  Network.swift
//  NetworkProject
//
//  Created by 黄穆斌 on 2017/3/15.
//  Copyright © 2017年 MuBinHuang. All rights reserved.
//

import Foundation

// MARK: - Network
/**
 A network tools.
 Use URLSession, URLSessionDataDelegate
 */
public class Network: NSObject {
    
    // MARK: - Network Data
    
    // MARK: Object
    
    /** network object identifier, use to print message. */
    public var identifier: String = ""
    
    public override var description: String {
        return "Network \(identifier), task = \(task), waiting number = \(taskQueue.count), first in first out is \(sequential), feedbackThread = \(feedbackThread);"
    }
    
    // MARK: URLSession
    
    /** network session */
    private var session: URLSession!
    
    /** current running data task. */
    fileprivate var current: URLSessionDataTask?
    
    // MARK: Thread
    
    /** operation queue */
    fileprivate let thread: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    /** The feedback queue */
    public var feedbackThread: OperationQueue?
    
    // MARK: Tasks Queue
    
    /** Current running task. */
    fileprivate var task: Task?
    
    /** Waiting task queue. */
    fileprivate var taskQueue: [Task] = []
    
    /** 
     The taskqueue ordar.
     True: first in first out
     False: first in last out
     */
    public var sequential: Bool = true
    
    // MAKR: - Init
    
    /**
     Initialize a network object.
     
     - parameter identifier: object identifier, default "".
     
     - returns: Json object
     */
    init(identifier: String = "") {
        super.init()
        self.identifier = identifier
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: thread)
    }
    
    // MARK: - Runing Loop
    
    /**
     Use the task queue to start the network.
     */
    fileprivate func loop() {
        thread.addOperation {
            if self.task == nil && self.taskQueue.count > 0 {
                // get task
                if self.sequential {
                    self.task = self.taskQueue.removeFirst()
                } else {
                    self.task = self.taskQueue.removeLast()
                }
                
                // network
                if let request = self.task?.request {
                    let sessionTask = self.session.dataTask(with: request)
                    sessionTask.taskDescription = self.task?.id
                    self.current = sessionTask
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
    }
    
    /** Resume the current task */
    public func resume() {
        self.current?.resume()
    }
    
    /**
     Cancel the task with the id.
     
     - parameter id: The task id, if nil, is current.
     */
    public func cancel(id: String? = nil) {
        thread.addOperation {
            guard let id = id else {
                self.current?.cancel()
                return
            }
            
            if let i = self.taskQueue.index(where: { $0.id == id }) {
                self.taskQueue.remove(at: i)
            }
        }
    }
    
    /**
     Clear all task.
     
     - parameter cancelCurrent: if true, will cancel the current task.
     */
    public func clear(cancelCurrent: Bool = false) {
        thread.addOperation {
            self.taskQueue.removeAll()
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
            if self.task?.id == id {
                task(self.task)
            }
            else if let i = self.taskQueue.index(where: { $0.id == id }) {
                task(self.taskQueue[i])
            }
            else {
                task(nil)
            }
        }
    }
    
    /**
     Let the assign task to the next task.
     
     - parameter id: task id
     */
    public func toFirst(id: String) {
        thread.addOperation {
            guard let i = self.taskQueue.index(where: { $0.id == id }) else {
                return
            }
            
            let task = self.taskQueue.remove(at: i)
            if self.sequential {
                self.taskQueue.insert(task, at: 0)
            }
            else {
                self.taskQueue.append(task)
            }
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
        receiveResponse: ((Network.Task) -> Bool)? = nil,
        receiceData: ((Network.Task, Data) -> Void)? = nil,
        receiveComplete: ((Network.Task, Error?) -> Void)? = nil
    ) {
        thread.addOperation {
            // Check
            if self.taskQueue.contains(where: { $0.id == id }) {
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
            
            self.taskQueue.append(task)
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
        receiveResponse: ((Network.Task) -> Bool)? = nil,
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
        receiveResponse: ((Network.Task) -> Bool)? = nil,
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
        receiveResponse: ((Network.Task) -> Bool)? = nil,
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
        receiveResponse: ((Network.Task) -> Bool)? = nil,
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

// MARK: - URLSessionDataDelegate

extension Network: URLSessionDataDelegate {
    
    /** Receive the response */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        guard let task = self.task else {
            completionHandler(.cancel)
            return
        }
        
        // Set Response
        task.response = response
        
        // feedback
        if let receive = task.receiveResponse {
            if let feedback = feedbackThread {
                feedback.addOperation { [task = task, receive = receive] in
                    if receive(task) == false {
                        completionHandler(.cancel)
                    }
                    else {
                        completionHandler(.allow)
                    }
                }
            }
            else {
                if receive(task) == false {
                    completionHandler(.cancel)
                }
                else {
                    completionHandler(.allow)
                }
            }
        }
        else {
            completionHandler(.allow)
        }
    }
    
    /** Receive the data */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = self.task else {
            return
        }
        
        // Data
        if task.data == nil {
            task.data = data
        }
        else {
            task.data?.append(data)
        }
        
        // feedback
        if let receive = task.receiceData {
            if let feedback = feedbackThread {
                feedback.addOperation { [task = task, data = data, receive = receive] in
                    receive(task, data)
                }
            }
            else {
                receive(task, data)
            }
        }
    }
    
    /** Recevie complete */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            // Clear
            self.current = nil
            self.task = nil
            self.loop()
        }
        
        //
        guard let task = self.task else {
            return
        }
        
        // feedback
        if let receive = task.receiveComplete {
            if let feedback = feedbackThread {
                feedback.addOperation { [task = task, error = error, receive = receive] in
                    receive(task, error)
                }
            }
            else {
                receive(task, error)
            }
        }
    }
}

// MARK: - Response

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
        var response: URLResponse?
        /** the task data */
        var data: Data?
        /** the task error */
        var error: Error?
        
        // MARK: - Quick access data
        
        // MARK: Property
        
        /** the http response status code */
        var code: Int {
            return (response as? HTTPURLResponse)?.statusCode ?? 0
        }
        
        // MARK: Method
        
        /** 
         Get the http response header value.
         
         - parameter key: The header key
         
         - returns: key-value, if none will be a nil.
         
         */
        func header<T>(_ key: String) -> T? {
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
        func otherInfo<T>(_ key: String, null: T) -> T {
            if let dic = other as? [String: Any] {
                if let data = dic[key] as? T {
                    return data
                }
            }
            return null
        }
        
        // MARK: - Feedback
        
        /** Call when receive task response. */
        var receiveResponse: ((Network.Task) -> Bool)?
        /** Call when receive datas. */
        var receiceData: ((Network.Task, Data) -> Void)?
        /** Call when receive complete. */
        var receiveComplete: ((Network.Task, Error?) -> Void)?
        
        
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
    
}

