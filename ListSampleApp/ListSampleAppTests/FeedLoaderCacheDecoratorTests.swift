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
        let loderStub = FeedLoderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loderStub)
        expect(sut: sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversFeedOnFailourloaded() {
        
        let loderStub = FeedLoderStub(result: .failure(anyError()))
        let sut = FeedLoaderCacheDecorator(decoratee: loderStub)
        expect(sut: sut, toCompleteWith: .failure(anyError()))
    }
    
   
    
    
}
