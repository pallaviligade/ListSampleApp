//
//  LoadFeedCacheFromCacheUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 09.05.23.
//

import XCTest
import EssentialFeed

final class LoadFeedCacheFromCacheUseCaseTest: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
       
        let ( _,store) = makeSUT()
        
        XCTAssertEqual(store.recivedMessages, [])
        
    }
    
    func test_loadRequestCacheRetrivals() {
        
        let ( sut,store) = makeSUT()
        
       _ = try? sut.load() // When
        
        XCTAssertEqual(store.recivedMessages, [.retrival])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
            store.completeRetrival(with: feed.localitems, timestamp: nonExpiredTimestamp)

        _ = try? sut.load()

            XCTAssertEqual(store.recivedMessages, [.retrival])
        }
    
    func test_load_hasNoSideEffectsOnCacheExpiration() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
           store.completeRetrival(with: feed.localitems, timestamp: expirationTimestamp)

        _ = try? sut.load()

            XCTAssertEqual(store.recivedMessages, [.retrival])
        }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrival(with: feed.localitems, timestamp:  expiredTimestamp)

        _ = try? sut.load()

            XCTAssertEqual(store.recivedMessages, [.retrival])
        }
    
    func test_loadFailsOnretrivalError() {
        
        let ( sut,store) = makeSUT()
        let retrievalError = anyError()
                
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
      
        
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
            let (sut, store) = makeSUT()
            store.completeRetrieval(with: anyNSError())

        _ = try? sut.load()

        XCTAssertEqual(store.recivedMessages, [.retrival])
        }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let ( sut,store) = makeSUT()
        
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
            let (sut, store) = makeSUT()
            store.completeRetrievalWithEmptyCache()

        _ = try? sut.load()

            XCTAssertEqual(store.recivedMessages, [.retrival])
        }
        
        func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
                let feed = uniqueItems()
                let fixedCurrentDate = Date()
                let lessThanSevenDaysOldTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
                let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

            expect(sut, toCompleteWith: .success(feed.models), when: {
                store.completeRetrival(with: feed.localitems, timestamp: lessThanSevenDaysOldTimestamp)
                })
            }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let sevenDaysOldTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
            
        expect(sut, toCompleteWith: .success([]), when: {
                store.completeRetrival(with: feed.localitems, timestamp: sevenDaysOldTimestamp)
            })
        }
    
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
            let feed = uniqueItems()
            let fixedCurrentDate = Date()
            let moreThanSevenDaysOldTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success([]), when: {
                store.completeRetrival(with: feed.localitems, timestamp: moreThanSevenDaysOldTimestamp)
            })
        }

    
    private func makeSUT(currentDate:@escaping() -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store:feedStoreSpy) {
        let store = feedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate:currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
// MARK: - helpers:
    
   
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: Result<[FeedImage], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
            action()

            let receivedResult = Result { try sut.load() }

            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
        }
}

