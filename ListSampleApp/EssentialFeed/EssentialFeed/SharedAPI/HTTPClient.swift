//
//  Httpclient.swift
//  EssentialFeed
//
//  Created by Pallavi on 28.04.23.
//

import Foundation
public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    
     typealias Result = Swift.Result <(Data,HTTPURLResponse), Error>

     func get(from url: URL,completion:@escaping (Result) -> Void) -> HTTPClientTask
}
