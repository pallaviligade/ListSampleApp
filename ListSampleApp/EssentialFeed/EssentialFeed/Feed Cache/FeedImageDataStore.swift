//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Pallavi on 28.07.23.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result <Void, Error>
    
    
    func retrieve(dataForUrl url: URL, completionHandler: @escaping (RetrievalResult) -> Void)
    func insert(_ data: Data, for url: URL, completionHandler: @escaping (InsertionResult) -> Void)
}
