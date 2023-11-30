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
    
    func test_save_RequestCacheDeletion() {
       let (sut, store) = makeSUT()
        
        //let items = [uiqureItem(), uiqureItem()]
        sut.save(uniqueItems().models)
        
        XCTAssertEqual(store.recivedMessages, [.deleteCachedFeed])
        
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError () {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        sut.save(uniqueItems().models)
        
        
        XCTAssertEqual(store.recivedMessages, [.deleteCachedFeed])

    }
    

    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items =  uniqueItems()
        let (sut, store) = makeSUT(currentDate: { timestamp })
                store.completeDeletionSuccessFully()
      
        
        sut.save(items.models) { _ in }
        
        XCTAssertEqual(store.recivedMessages, [.deleteCachedFeed, .insert(items.localitems, timestamp)])


    }
    
    func test_save_failsOnDeletionError () {
        let (sut, store) = makeSUT()
        let deletionError = anyError()
        
        let exp = expectation(description: "wait for save completions")
        var recviedError: Error?
        
        sut.save(uniqueItems().models) { result  in
            if case let Result.failure(error)  = result
            {
            recviedError = error
            }
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)// when
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(recviedError as NSError?, deletionError)

    }
    
    func test_save_failsOnInsertionsError () {
        let (sut, store) = makeSUT()
      //  let items = [uiqureItem(), uiqureItem()]
        let insertionError = anyError()
        
        let exp = expectation(description: "wait unti")
        var recviedError: Error?
        
        sut.save(uniqueItems().models) { result  in
            if case let  Result.failure(error) = result
            {
                recviedError = error
            }
            exp.fulfill()
        }
        store.completeDeletionSuccessFully()
        store.completeInsertion(with: insertionError)// when
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(recviedError as NSError?, insertionError)

    }
    
    func test_save_SuccessOnSuccesfullyCacheInsertions () {
        let (sut, store) = makeSUT()
       // let items = [uiqureItem(), uiqureItem()]
        
        let exp = expectation(description: "wait unti")
        var recviedError: Error?
        
        sut.save(uniqueItems().models) { result  in
            if case let Result.failure(error) = result
            {
                recviedError = error
            }
            exp.fulfill()
        }
        store.completeDeletionSuccessFully()
        store.completeInsertionSuccessfully()// when
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNil(recviedError)

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
    
  
}
