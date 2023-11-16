//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Pallavi on 28.08.23.
//

import Foundation
public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL) throws
}
