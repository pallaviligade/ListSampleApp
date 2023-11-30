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
        store.completeRetrieval(with: anyError())
        sut.validateCache { _ in }
        
      
        XCTAssertEqual(store.recivedMessages, [.retrival,.deleteCachedFeed])
        
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()
        sut.validateCache { _ in }
      
        
        XCTAssertEqual(store.recivedMessages, [.retrival])
    }
    
    
        func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let lessThanSevenDaysOldTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
            store.completeRetrival(with: feed.localitems, timestamp: lessThanSevenDaysOldTimestamp)
            sut.validateCache {_ in  }
            

            XCTAssertEqual(store.recivedMessages, [.retrival])
        }
    
    func test_validateCache_deletesCacheOnExpiration() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrival(with: feed.localitems, timestamp: expirationTimestamp)

            sut.validateCache { _ in }

            XCTAssertEqual(store.recivedMessages, [.retrival, .deleteCachedFeed])
        }
    
    func test_validateCache_deletesExpiredCache() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrival(with: feed.localitems, timestamp: expiredTimestamp)

            sut.validateCache { _ in }

            XCTAssertEqual(store.recivedMessages, [.retrival, .deleteCachedFeed])
        }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
            let (sut, store) = makeSUT()
            let deletionError = anyNSError()
            
            expect(sut, toCompleteWith: .failure(deletionError), when: {
                store.completeRetrieval(with: anyNSError())
                store.completeDeletion(with: deletionError)
            })
        }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
            let (sut, store) = makeSUT()
            
            expect(sut, toCompleteWith: .success(()), when: {
                store.completeRetrieval(with: anyNSError())
                store.completeDeletionSuccessFully()
            })
        }
        
        func test_validateCache_succeedsOnEmptyCache() {
            let (sut, store) = makeSUT()
            
            expect(sut, toCompleteWith: .success(()), when: {
                store.completeRetrievalWithEmptyCache()
            })
        }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
            
            expect(sut, toCompleteWith: .success(()), when: {
                store.completeRetrival(with: feed.localitems, timestamp: nonExpiredTimestamp)
            })
        }
    
    func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
            let deletionError = anyNSError()
            
            expect(sut, toCompleteWith: .failure(deletionError), when: {
                store.completeRetrival(with: feed.localitems, timestamp:  expiredTimestamp)
                store.completeDeletion(with: deletionError)
            })
        }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
            
            expect(sut, toCompleteWith: .success(()), when: {
                store.completeRetrival(with: feed.localitems, timestamp: expiredTimestamp)
                store.completeDeletionSuccessFully()
            })
        }
    
//    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
//            let store = feedStoreSpy()
//            var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
//            
//            var receivedResults = [LocalFeedLoader.loadResult]()
//            sut?.load { receivedResults.append($0) }
//            
//            sut = nil
//            store.completeRetrievalWithEmptyCache()
//            
//            XCTAssertTrue(receivedResults.isEmpty)
//        }

    private func makeSUT(currentDate:@escaping() -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store:feedStoreSpy)
    {
        let store = feedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate:currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")
            action()

            sut.validateCache { receivedResult in
                switch (receivedResult, expectedResult) {
                case (.success, .success):
                    break
                    
                case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                    
                default:
                    XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                }
                
                exp.fulfill()
            }

            wait(for: [exp], timeout: 1.0)
        }
}
