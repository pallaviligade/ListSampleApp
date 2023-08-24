//
//  FeedLoaderCacheDecoratorTests.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 23.08.23.
//

import XCTest
import EssentialFeed



final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    
    init(decoratee: FeedLoader, cache: FeedCache ) {
        self.decoratee = decoratee
        self.cache = cache
        
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
//            if let feed = try? result.get() {
//                self?.cache.save(feed, completion: { _ in
//                    completion(result)
//                })
//            } we can also write above code in below also
            completion(result.map{ feed in
                self?.cache.save(feed, completion: { _ in })
                return feed
            })
        }
    }
    
    
}

class FeedLoaderCacheDecoratorTests: XCTestCase ,FeedLoderTestCase {
    
    
    func test_load_deliversFeedOnSucessloaded() {
        
        let feed = createuniqueFeedImage()
        let sut = makeSUT(loaderResult: .success(feed))
        expect(sut: sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversFeedOnFailourloaded() {
       let sut = makeSUT(loaderResult: .failure(anyError()))
        expect(sut: sut, toCompleteWith: .failure(anyError()))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = createuniqueFeedImage()
        let sut = makeSUT(loaderResult: .success(feed),cacheSpy: cache)
        
        sut.load { _ in }
            
        
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected cached loaded feed on a sucess")
    }
    
    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyError()), cacheSpy: cache)
        XCTAssertTrue(cache.messages.isEmpty, "Does not cache feed on error")
    }
    
    private func makeSUT(loaderResult: FeedLoader.Result, cacheSpy: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line ) -> FeedLoader  {
        
        let loderStub = FeedLoderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loderStub, cache: cacheSpy)
        return sut
    }
    
    private class CacheSpy: FeedCache {
       
        
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(_ item: [EssentialFeed.FeedImage], completion: @escaping (saveResult) -> Void) {
            messages.append(.save(item))
            completion(.success(()))
        }
    
    }
  
}
