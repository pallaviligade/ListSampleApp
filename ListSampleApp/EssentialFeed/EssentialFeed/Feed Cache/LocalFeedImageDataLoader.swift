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
    
    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            self.completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
        
    public func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void ) -> FeedImageDataLoaderTask {
        
        
        let task = LoadImageDataTask(completion: completionHandler)
        
        task.complete(
                    with: Swift.Result {
                        try store.retrieve(dataForURL: url)
                    }
                    .mapError { _ in loadError.failed }
                    .flatMap { data in
                        data.map { .success($0) } ?? .failure(loadError.notFound)
                    })
        return task
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
