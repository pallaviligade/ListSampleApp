//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 04.08.23.
//

import Foundation
import EssentialFeed

 class FeedImageDataStoreSpy: FeedImageDataStore {
    
    
    enum message: Equatable {
        case retrieve(dataForUrl: URL)
        case insert(data: Data, url: URL)
    }
    
     private var retrievalResult: Result<Data?, Error>?
     private var insertionResult: Result<Void, Error>?
     
    var recivedMessage = [message]()
    
    func retrieve(dataForUrl url: URL) throws -> Data? {
        recivedMessage.append(.retrieve(dataForUrl: url))
        return try retrievalResult?.get()
    }
    
    func insert(_ data: Data, for url: URL) throws {
        recivedMessage.append(.insert(data: data, url: url))
        try insertionResult?.get()
    }
    
    func completeRetrieval(with error: Error){
        retrievalResult = .failure(error)
    }
    
    func completeRetrieval(with data: Data?){
        retrievalResult = .success(data)
    }
     
     func completeInsertion(with error: Error) {
         insertionResult = .failure(error)
     }
     
     func completeInsertionSuccessfully() {
         insertionResult = .success(())
     }
    
}
