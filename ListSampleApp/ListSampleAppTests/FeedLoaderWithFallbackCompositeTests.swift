//
//  ListSampleAppTests.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 15.08.23.
//

import XCTest
import EssentialFeed
import ListSampleApp



class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliveryRemoteFeedOnRemoteSucess(){
        
        let primaryFeed = createuniqueFeedImage()
        let fallbackFeed = createuniqueFeedImage()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_load_deliversFallbackFeedOnPrimaryFailure() {
        
        let fallbackFeed = createuniqueFeedImage()
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        
        let fallbackFeed = createuniqueFeedImage()
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .failure(anyError()))
        
        expect(sut, toCompleteWith:.failure(anyError()))
    }
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let primaryloader = LoaderStub(result: primaryResult)
        let fallbackloader = LoaderStub(result: fallbackResult)
        trackForMemoryLeaks(primaryloader,file: file, line: line)
        trackForMemoryLeaks(fallbackloader,file: file, line: line)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryloader, fallback: fallbackloader)
        return sut
    }
    
    private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { Recivedresult in
            switch (Recivedresult,expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed,expectedFeed)
            case (.failure, .failure ):
             
                break
            default:
                XCTFail("Expcted sucessfully load feedresult, got \(Recivedresult) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        
    }
   
    
    private class LoaderStub: FeedLoader {
        
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
           completion(result)
        }
    }

}
