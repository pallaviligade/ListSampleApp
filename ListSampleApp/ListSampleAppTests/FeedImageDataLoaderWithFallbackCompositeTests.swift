//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 16.08.23.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
   
    private let imageDataloader: FeedImageDataLoader
    private let fallback : FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        imageDataloader = primary
        self.fallback = fallback
    }
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
       _ = imageDataloader.loadImageData(from: url) { [weak self] result in
           switch result {
           case .success:
               break
           case .failure:
              _ = self?.fallback.loadImageData(from: url) { _ in }
               break
           }
           
       }
        return Task()
    }
    
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryloderFirst() {
        let url = anyUrls()
       
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        
      _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURLs,[url], "Expected loads urls from primary loads")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadsImageData_lodsFromFallbackOnPrimaryloderFailour() {
        let urls = anyUrls()
        
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        
       _ = sut.loadImageData(from: urls) { _ in }
        
        primaryLoader.complete(with: anyError())
        
        XCTAssertEqual(primaryLoader.loadedURLs,[urls], "Expected loads urls from primary loads ")
        XCTAssertEqual(fallbackLoader.loadedURLs,[urls], "Expected loads urls from fallback loads ")
    }
    
    //MARK: - Helpers
    
    private func anyUrls() -> URL {
        return URL(string: "http://any-urls.com")!
    }
    
    private func anyError() -> Error {
        return NSError(domain: "any Error", code: 0)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:FeedImageDataLoaderWithFallbackComposite,primaryLoader: LoaderSpy,fallbackLoader: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
            addTeardownBlock { [weak instance] in
                XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
            }
        }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion:(FeedImageDataLoader.Result) -> Void)] ()
        
        var loadedURLs:[URL]  {
            return messages.map { $0.url}
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
            messages.append((url,completionHandler))
            
            return Task()
        }
        
        func complete(with error: Error, index: Int = 0)  {
            return messages[index].completion(.failure(error))
        }
        
    }
}
