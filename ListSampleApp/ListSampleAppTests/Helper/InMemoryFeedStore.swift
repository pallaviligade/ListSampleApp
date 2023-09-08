//
//  InMemoryFeedStore.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 08.09.23.
//

import EssentialFeed

public class InMemoryFeedStore {
    private(set) var feedCache: CachedFeed?
    private var feedImageDataCache: [URL: Data] = [:]
    
    init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
}

extension InMemoryFeedStore: FeedStore {
    public func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        feedCache = nil
        completion(.success(()))
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        feedCache = CachedFeed.found(feed: feed, timestamp: timestamp)
        completion(.success(()))
    }
    
    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.success(feedCache))
    }
}


extension InMemoryFeedStore:  FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completionHandler completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        feedImageDataCache[url] = data
        completion(.success(()))
    }
    
    public func retrieve(dataForUrl url: URL, completionHandler completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(feedImageDataCache[url]))
    }
}

extension InMemoryFeedStore  {
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache:CachedFeed.found(feed: [], timestamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed.found(feed: [], timestamp: Date()))
    }
}








