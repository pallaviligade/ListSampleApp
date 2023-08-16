//
//  ListSampleAppTests.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 15.08.23.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite: FeedLoader {
    private let feedloader: FeedLoader
    private let fallbackloader: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.feedloader = primary
        self.fallbackloader = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedloader.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallbackloader.load(completion: completion)
            }
        }
    }
    
}


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
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let primaryloader = LoaderStub(result: primaryResult)
        let fallbackloader = LoaderStub(result: fallbackResult)
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
   
    private func createuniqueFeedImage() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: nil, imageURL: URL(string: "http://any-url")!)]
    }
    
    private func anyError() -> Error {
        return NSError(domain: "any error", code: 0)
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
