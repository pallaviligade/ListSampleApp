//
//  FeedImageDataLoderSpy.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 25.08.23.
//

import EssentialFeed

 class FeedImageDataLoderSpy: FeedImageDataLoader {
    private(set) var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    private(set) var canceledUrls = [URL]()
    
    var loadedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    struct Task: FeedImageDataLoaderTask {
        let callback: () ->  Void
        func cancel() {
            callback()
        }
    }
    
    func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        messages.append((url,completionHandler))
        return Task { [weak self] in
            self?.canceledUrls.append(url)
        }
    }
    
    func complete(with data: Data,at index: Int = 0) {
        messages[index].completion(.success(data))
    }
    
    func complete(with error: Error,at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
}
