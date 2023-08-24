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
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
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
    
    private func makeSUT(loaderResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line ) -> FeedLoader  {
        
        let loderStub = FeedLoderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loderStub)
        return sut
    }
  
}
