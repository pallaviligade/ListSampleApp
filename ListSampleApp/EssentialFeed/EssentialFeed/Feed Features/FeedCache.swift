//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Pallavi on 24.08.23.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
     func save(_ item: [FeedImage], completion: @escaping (Result) -> Void)
}
