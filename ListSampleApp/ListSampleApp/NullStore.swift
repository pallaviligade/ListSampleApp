//
//  NullStore.swift
//  ListSampleApp
//
//  Created by Pallavi on 16.11.23.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }

    func insert(_ data: Data, for url: URL, completionHandler completion: @escaping (InsertionResult) -> Void) {
        completion(.success(()))
    }

    func retrieve(dataForUrl url: URL, completionHandler completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
