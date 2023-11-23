//
//  FeedImageDataLoaderCacheDecorator.swift
//  ListSampleApp
//
//  Created by Pallavi on 28.08.23.
//

import Foundation
import EssentialFeed

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
   
    
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    
  public  init (decorate: FeedImageDataLoader, cache: FeedImageDataCache) {
        decoratee = decorate
        self.cache = cache
        
    }
    public func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completionHandler(result.map { data in
                       try? self?.cache.save(data, for: url) 
                        return data
                    })
                }
    }
    
    
}
