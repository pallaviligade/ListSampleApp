//
//  XCTestCase+FeedStoreSepcs.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 15.05.23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpec where Self: XCTestCase
{
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetive: .success(.none), file: file, line: line)
        }
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
        }
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueItems().localitems
            let timestamp = Date()

            insert((feed, timestamp), to: sut)

        expect(sut, toRetive: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
        }
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let feed = uniqueItems().localitems
            let timestamp = Date()

            insert((feed, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
        }
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let insertionError = insert((uniqueItems().localitems, Date()), to: sut)

            XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
        }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueItems().localitems, Date()), to: sut)

            let insertionError = insert((uniqueItems().localitems, Date()), to: sut)

            XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
        }
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueItems().localitems, Date()), to: sut)

            let latestFeed = uniqueItems().localitems
            let latestTimestamp = Date()
            insert((latestFeed, latestTimestamp), to: sut)

        expect(sut, toRetive: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
        }
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let deletionError = deleteCache(from: sut)

            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
        }
    
  

        func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            deleteCache(from: sut)

            expect(sut, toRetive: .success(.none), file: file, line: line)
        }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueItems().localitems, Date()), to: sut)

            let deletionError = deleteCache(from: sut)

            XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
        }

        func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueItems().localitems, Date()), to: sut)

            deleteCache(from: sut)

            expect(sut, toRetive:  .success(.none), file: file, line: line)
        }

    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        
        do {
            try sut.deleteCachedFeed()
            return nil
        } catch {
            return error
        }
    }
    
    @discardableResult
     func insert(_ cache:(feed: [LocalFeedImage], timespam: Date), to sut:FeedStore) ->  Error?
    {
        do {
            try sut.insert(cache.feed, timestamp: cache.timespam)
            return nil
        } catch {
            return error
        }
        
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrivalsResult, file: StaticString = #file, line: UInt = #line) {
         expect(sut, toRetive: expectedResult, file: file, line: line)
         expect(sut, toRetive: expectedResult, file: file, line: line)
        }
    
    func expect(_ sut:FeedStore, toRetive expectedResult:FeedStore.RetrivalsResult ,file: StaticString = #file, line: UInt = #line) {
        let retrievedResult = Result { try sut.retrieve() }
        
        switch (expectedResult, retrievedResult) {
        case (.success(.none), .success(.none)),
            (.failure, .failure):
            break
            
        case let (.success(.some(expected)), .success(.some(retrieved))):
            XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
            XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
            
        default:
            XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
        }
        
    }
  
}
