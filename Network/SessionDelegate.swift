//
//  SessionDelegate.swift
//  NetworkTestProject
//
//  Created by 黄穆斌 on 2017/3/16.
//  Copyright © 2017年 MuBinHuang. All rights reserved.
//

import UIKit

// MARK: - Session Delegate

@objc public protocol SessionDelegate: class {
    
    /** URLSessionDataDelegate */
    @objc optional func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceiveResponse response: URLResponse)
    @objc optional func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data)
    
    /** URLSessionTaskDelegate */
    @objc optional func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    
}

// MARK: - Session Delegate Object

public class SessionDelegateObject: NSObject {
    
    public weak var network: SessionDelegate?
    
    override init() {
        super.init()
        print("SessionDelegateObject init \(self)")
    }
    
    deinit {
        print("SessionDelegateObject deinit \(self)")
    }
    
}

// MARK: - URLSessionDelegate

extension SessionDelegateObject: URLSessionTaskDelegate {
    
    /** Recevie complete */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        network?.urlSession?(session, task: task, didCompleteWithError: error)
    }
    
}

extension SessionDelegateObject: URLSessionDataDelegate {
    
    /** Receive the response */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        network?.urlSession?(session, dataTask: dataTask, didReceiveResponse: response)
        completionHandler(.allow)
    }
    
    /** Receive the data */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        network?.urlSession?(session, dataTask: dataTask, didReceiveData: data)
    }
    
}
