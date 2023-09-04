//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Pallavi on 24.08.23.
//

import Foundation

public protocol FeedCache {
     typealias saveResult = Result<Void, Error>
    
     func save(_ item: [FeedImage], completion: @escaping (saveResult) -> Void)
}
