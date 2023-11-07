//
//  ListSampleAppTests.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 15.08.23.
//

import XCTest
import EssentialFeed
import ListSampleApp



class FeedLoaderWithFallbackCompositeTests: XCTestCase,  FeedLoderTestCase {

    func test_load_deliveryRemoteFeedOnRemoteSucess(){
        
        let primaryFeed = createuniqueFeedImage()
        let fallbackFeed = createuniqueFeedImage()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        expect(sut: sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_load_deliversFallbackFeedOnPrimaryFailure() {
        
        let fallbackFeed = createuniqueFeedImage()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut: sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        
        let fallbackFeed = createuniqueFeedImage()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut: sut, toCompleteWith:.failure(anyNSError()))
    }
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let primaryloader = FeedLoderStub(result: primaryResult)
        let fallbackloader = FeedLoderStub(result: fallbackResult)
        trackForMemoryLeaks(primaryloader,file: file, line: line)
        trackForMemoryLeaks(fallbackloader,file: file, line: line)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryloader, fallback: fallbackloader)
        return sut
    }
    
   
}
