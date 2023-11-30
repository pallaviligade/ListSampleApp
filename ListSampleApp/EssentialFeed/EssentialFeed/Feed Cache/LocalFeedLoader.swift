//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 05.05.23.
// it can be called controller or controller boundery or interacter || model controller

import Foundation

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
   
    
    public init(store: FeedStore,currentDate:@escaping () -> Date )  {
        self.store = store
        self.currentDate = currentDate
    }
 
}

extension LocalFeedLoader: FeedCache {
   //    public typealias saveResult = FeedCache.Result
    
    public func save(_ item: [FeedImage]) throws {
                    try store.deleteCachedFeed()
                    try store.insert(item.toLocal(), timestamp: currentDate())
    }
//    private func cache(_  item:[FeedImage],with completion:@escaping (saveResult) -> Void)
//    {
//        store.insert(item.toLocal(), timestamp: self.currentDate()) { [weak self] result in
//            guard self != nil else { return }
//            completion(result)
//        }
//    }
}

extension LocalFeedLoader {
    
    public func load() throws -> [FeedImage] {
            if let cache = try store.retrieve(), FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                return cache.feed.toModels()
            }
            return []
        }
//    public typealias loadResult = FeedLoader.Result
//    
//    public func load(completion completionHandler:@escaping (loadResult) -> Void){
//        completionHandler(loadResult {
//            if let cache = try store.retrieve(), FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
//                return cache.feed.toModels()
//            }
//            return []
//        })
//    }
}
extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    private struct InvalidCache: Error {}
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        completion(ValidationResult {
            do {
                if let cache = try store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                    throw InvalidCache()
                }
            } catch {
                try store.deleteCachedFeed()
            }
        })
    }
}

private extension Array where Element == FeedImage {
    
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    }
    
}
private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}
