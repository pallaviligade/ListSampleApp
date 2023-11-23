//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 03.08.23.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    public enum loadError: Swift.Error {
        case failed
        case notFound
    }
    
    public func loadImageData(from url: URL) throws -> Data {
        do {
                    if let imageData = try store.retrieve(dataForURL: url) {
                        return imageData
                    }
                } catch {
                    throw loadError.failed
                }
        throw loadError.notFound
    }
        
    
    
}



extension LocalFeedImageDataLoader: FeedImageDataCache {
     //Result <Void, Swift.Error>
    
    public enum SaveError: Error {
        case failure
    }
    
    public func save(_ data: Data, for url: URL) throws {
            do {
                try store.insert(data, for: url)
            } catch {
                throw SaveError.failure
            }
    }
}
