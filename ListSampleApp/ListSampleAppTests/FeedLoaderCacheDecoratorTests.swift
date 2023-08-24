//
//  FeedLoaderCacheDecoratorTests.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 23.08.23.
//

import XCTest
import EssentialFeed

protocol FeedCache {
     typealias saveResult = Result<Void, Error>
    
     func save(_ item: [FeedImage], completion: @escaping (saveResult) -> Void)
}

final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    
    init(decoratee: FeedLoader, cache: FeedCache ) {
        self.decoratee = decoratee
        self.cache = cache
        
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.cache.save((try? result.get()) ?? [], completion: { _ in
               completion(result)
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
