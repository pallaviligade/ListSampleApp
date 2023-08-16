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
        
        let exp = expectation(description: "wait till expection")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed,primaryFeed)
            case .failure:
                XCTFail("Expcted sucessfully load feedresult, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversFallbackFeedOnPrimaryFailure() {
        
        let fallbackFeed = createuniqueFeedImage()
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "wait till expection")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed,fallbackFeed)
            case .failure:
                XCTFail("Expcted sucessfully load feedresult, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let primaryloader = LoaderStub(result: primaryResult)
        let fallbackloader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryloader, fallback: fallbackloader)
        return sut
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
