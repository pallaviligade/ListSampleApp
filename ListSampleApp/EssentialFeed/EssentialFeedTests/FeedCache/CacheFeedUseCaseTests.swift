//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 04.05.23.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
       
        let ( _,store) = makeSUT()
        
        XCTAssertEqual(store.recivedMessages, [])
        
    }
    
//    func test_save_RequestCacheDeletion() {
//       let (sut, store) = makeSUT()
//        
//        //let items = [uiqureItem(), uiqureItem()]
//       try? sut.save(uniqueItems().models)
//        
//        XCTAssertEqual(store.recivedMessages, [.deleteCachedFeed])
//        
//    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
            let (sut, store) = makeSUT()
            let deletionError = anyNSError()
            store.completeDeletion(with: deletionError)

            try? sut.save(uniqueItems().models)

            XCTAssertEqual(store.recivedMessages, [.deleteCachedFeed])
        }
    

    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items =  uniqueItems()
        let (sut, store) = makeSUT(currentDate: { timestamp })
                store.completeDeletionSuccessFully()
      
        
       try? sut.save(items.models)
        
        XCTAssertEqual(store.recivedMessages, [.deleteCachedFeed, .insert(items.localitems, timestamp)])


    }
    
    func test_save_failsOnDeletionError() {
            let (sut, store) = makeSUT()
            let deletionError = anyNSError()
            
            expect(sut, toCompleteWithError: deletionError, when: {
                store.completeDeletion(with: deletionError)
            })
        }
    
    func test_save_failsOnInsertionError() {
            let (sut, store) = makeSUT()
            let insertionError = anyNSError()
            
            expect(sut, toCompleteWithError: insertionError, when: {
                store.completeDeletionSuccessFully()
                store.completeInsertion(with: insertionError)
            })
        }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
            let (sut, store) = makeSUT()
            
            expect(sut, toCompleteWithError: nil, when: {
                store.completeDeletionSuccessFully()
                store.completeInsertionSuccessfully()
            })
        }
    
    
    //MARK: - Helpers
    
   
    private func makeSUT(currentDate:@escaping() -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store:feedStoreSpy) {
        let store = feedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate:currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    //MARK: - Heler class
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
            action()

            do {
                try sut.save(uniqueItems().models)
            } catch {
                XCTAssertEqual(error as NSError?, expectedError, file: file, line: line)
            }
        }
}
