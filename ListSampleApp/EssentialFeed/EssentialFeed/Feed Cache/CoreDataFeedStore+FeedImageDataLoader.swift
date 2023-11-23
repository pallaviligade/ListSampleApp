//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 08.08.23.
//

import Foundation


extension CoreDataFeedStore: FeedImageDataStore {

    public func insert(_ data: Data, for url: URL, completionHandler: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        performAsync { context in
                completionHandler(Result {
                    try ManagedFeedImage.first(with: url, in: context)
                                        .map { $0.data = data }
                                        .map(context.save)
                })
            }
        }

    public func retrieve(dataForUrl url: URL, completionHandler completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        performAsync { context in
                    completion(Result {
                        try ManagedFeedImage.data(with: url, in: context)
                    })
                }
    }

}
