//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 09.05.23.
//

import Foundation
import EssentialFeed

class feedStoreSpy: FeedStore {
   
     
     enum RecivedMessage: Equatable {
          case deleteCachedFeed
          case insert([LocalFeedImage], Date)
          case retrival
     }
     
     var insertCallCount = 0
     
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<CachedFeed?, Error>?
     
     private(set) var recivedMessages = [RecivedMessage]()
     
     
     func deleteCachedFeed() throws {
         recivedMessages.append(.deleteCachedFeed)
         try deletionResult?.get()
     }
     
     func completeDeletion(with error:Error)  {
         deletionResult = .success(())
        
     }
     func completeDeletionSuccessFully() {
         deletionResult = .success(())
     }
     
     func insert(_ item: [LocalFeedImage], timestamp: Date) throws {
        
         recivedMessages.append(.insert(item, timestamp))
         try insertionResult?.get()
     }
     
     func completeInsertion(with error:Error)  {
         insertionResult = .failure(error)
     }
     func completeInsertionSuccessfully() {
         insertionResult = .success(())
     }
    
    func retrieve() throws -> CachedFeed? {
            recivedMessages.append(.retrival)
            return try retrievalResult?.get()
        }
    
    func completeRetrieval(with error: Error){
        retrievalResult = .failure(error)
    }
    
//    func completeRetrievalSuccessfully(at index: Int = 0) {
//        retrivalCompletions[index](.failure(error))
//    }
    
    func completeRetrievalWithEmptyCache() {
        retrievalResult = .success(.none)
    }
    
    func completeRetrival(with feed:[LocalFeedImage], timestamp: Date)
    {
        retrievalResult = .success(CachedFeed(feed: feed, timestamp: timestamp))
    }
   
    
 }
