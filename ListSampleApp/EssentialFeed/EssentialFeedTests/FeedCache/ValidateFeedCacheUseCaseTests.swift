//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 10.05.23.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreations() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.recivedMessages, [])
        
        
    }
    
    func test_validateCache_deleteCacheOnRetrivals() {
        let (sut, store) = makeSUT()
        sut.validateCache { _ in }
        
        store.completeRetrieval(with: anyError())
        XCTAssertEqual(store.recivedMessages, [.retrival,.deleteCachedFeed])
        
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recivedMessages, [.retrival])
    }
    
    
        func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let lessThanSevenDaysOldTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

            sut.validateCache {_ in  }
            store.completeRetrival(with: feed.localitems, timestamp: lessThanSevenDaysOldTimestamp)

            XCTAssertEqual(store.recivedMessages, [.retrival])
        }
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
            let store = feedStoreSpy()
            var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
            
            var receivedResults = [LocalFeedLoader.loadResult]()
            sut?.load { receivedResults.append($0) }
            
            sut = nil
            store.completeRetrievalWithEmptyCache()
            
            XCTAssertTrue(receivedResults.isEmpty)
        }

    private func makeSUT(currentDate:@escaping() -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store:feedStoreSpy)
    {
        let store = feedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate:currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
}
