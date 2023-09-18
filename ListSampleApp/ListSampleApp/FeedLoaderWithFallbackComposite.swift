//
//  FeedLoaderWithFallbackComposite.swift
//  ListSampleApp
//
//  Created by Pallavi on 16.08.23.
//

import Foundation
import EssentialFeed
import Combine


public class FeedLoaderWithFallbackComposite: FeedLoader {
    private let feedloader: FeedLoader
    private let fallbackloader: FeedLoader
    
   public init(primary: FeedLoader, fallback: FeedLoader) {
        self.feedloader = primary
        self.fallbackloader = fallback
    }
    
   public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedloader.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallbackloader.load(completion: completion)
            }
        }
    }
    
}
