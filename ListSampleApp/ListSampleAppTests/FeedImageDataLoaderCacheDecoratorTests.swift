//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 24.08.23.
//
/*
import XCTest
import EssentialFeed
import ListSampleApp




class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    
    func test_init_doesNotloadImageData() {
       
        let (_,loaderSpy) = makeSUT()
        XCTAssertTrue(loaderSpy.loadedURLs.isEmpty, "Expected no loaded URLs")
        
    }
    
    func test_loadImageData_loadsFromLoader() {
        let (sut,loaderSpy) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loaderSpy.loadedURLs,[url], "Expected to load URL from loader")
    }
    
    func test_cancelLoadImageData_cancelLoderTask() {
        let (sut,loaderSpy) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loaderSpy.canceledUrls, [url],"Expected to cancel URL loading from loader")
        
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
    /*   let imageData = anyData()
        let (sut, loader) = makeSUT()
        
        var expectedResult: FeedImageDataLoader.Result = .success(imageData)
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
              print("receivedFeed:", receivedFeed)
              print("expectedFeed:", expectedFeed)
                XCTAssertEqual(receivedFeed, expectedFeed)
            break
            case (.failure, .failure): break
            default: break
            }
            exp.fulfill()
            loader.complete(with: imageData)
        }
        wait(for: [exp], timeout: 1.0)*/
        
        let imageData = anyData()
                let (sut, loader) = makeSUT()
                
                expect(sut, toCompleteWith: .success(imageData), when: {
                    loader.complete(with: imageData)
                })
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
            let (sut, loader) = makeSUT()
            
            expect(sut, toCompleteWith: .failure(anyNSError()), when: {
                loader.complete(with: anyNSError())
            })
        }
    
    func test_loadImageData_doesNotCacheDataOnLoaderFailure() {
            let cache = CacheSpy()
            let url = anyURL()
            let (sut, loader) = makeSUT(cache: cache)

            _ = sut.loadImageData(from: url) { _ in }
            loader.complete(with:anyNSError())

            XCTAssertTrue(cache.message.isEmpty, "Expected not to cache image data on load error")
        }
    
    private func makeSUT(cache: CacheSpy = .init() ,file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoderSpy) {
            let loader = FeedImageDataLoderSpy()
            let sut = FeedImageDataLoaderCacheDecorator(decorate: loader, cache: cache)
            trackForMemoryLeaks(loader, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, loader)
        }
    
    private class CacheSpy: FeedImageDataCache {
        private(set) var message = [Messages]()
        
        enum Messages: Equatable {
            case save(data: Data,url: URL )
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            message.append(.save(data: data, url: url))
            completion(.success(()))
        }
        
    }
}
*/
