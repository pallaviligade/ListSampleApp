//
//  FeedLoaderCacheDecorator.swift
//  ListSampleApp
//
//  Created by Pallavi on 24.08.23.
//

import EssentialFeed
import Combine



public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    
   public init(decoratee: FeedLoader, cache: FeedCache ) {
        self.decoratee = decoratee
        self.cache = cache
        
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
//            if let feed = try? result.get() {
//                self?.cache.save(feed, completion: { _ in
//                    completion(result)
//                })
//            } we can also write above code in below also
            completion(result.map{ feed in
                self?.cache.save(feed, completion: { _ in })
                return feed
            })
        }
    }
    
    
}
