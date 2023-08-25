//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 24.08.23.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
   
    
    private let feedImageDataLoder: FeedImageDataLoader
    
    init (decoratee: FeedImageDataLoader) {
        self.feedImageDataLoder = decoratee
    }
    func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        self.feedImageDataLoder.loadImageData(from: url, completionHandler: completionHandler)
    }
    
    
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    
    func test_init_doesNotloadImageData() {
       
        let (_,loaderSpy) = makeSUT()
        XCTAssertTrue(loaderSpy.loadedURLs.isEmpty, "Expected no loaded URLs")
        
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: LoaderSpy) {
            let loader = LoaderSpy()
            let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
            trackForMemoryLeaks(loader, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, loader)
        }
    
    private class LoaderSpy: FeedImageDataLoader {
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
        
        
    }
    
}
