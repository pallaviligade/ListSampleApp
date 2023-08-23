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

class FeedLoaderCacheDecoratorTests:  XCTestCase {
    
    
    func test_load_deliversFeedOnSucessloaded() {
        
        let feed = createuniqueFeedImage()
        let loderStub = LoderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loderStub)
        expect(sut: sut, toCompleteWith: .success(feed))
    }
    
    private func expect(sut:FeedLoaderCacheDecorator, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line ) {
        let exp = expectation(description: "wait until done")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
           
            case let (.success(recivedFeed), .success(expectedFeed)):
                XCTAssertEqual(recivedFeed, expectedFeed, file: file,line: line)
            case  (.failure, .failure): break
            
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
        
    }
    
    private class LoderStub: FeedLoader {
       
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(self.result)
        }
        
        
    }
}
