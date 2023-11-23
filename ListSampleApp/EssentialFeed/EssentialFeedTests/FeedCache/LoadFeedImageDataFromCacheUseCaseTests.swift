//
//  LoadFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 28.07.23.
//

import XCTest
import EssentialFeed


class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
    func test_initdoesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.recivedMessage.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoreDataForUrl() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        _ = try? sut.loadImageData(from: url)
        
        XCTAssertEqual(store.recivedMessage, [.retrieve(dataForUrl: url)])
    }
    
    func test_loadImageFromData_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith:.failure(LocalFeedImageDataLoader.loadError.failed) , when: {
                    let retrievalError = anyNSError()
                    store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_loadImageFromData_deliversNotFoundErrorOnNotFound()  {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound()) {
            store.completeRetrieval(with: .none)
        }
    }
    func test_loadImageFromData_deliversStoredDataOnFoundData()  {
    let (sut, store) = makeSUT()
    let foundData = anyData()
        
        expect(sut, toCompleteWith: .success(foundData)) {
        
            store.completeRetrieval(with: foundData)
        }
        
    }
    
//    func test_loadImageDataFromUrl_doesNotDeliverResultAfterCancelTask() {
//        let (sut, store) = makeSUT()
//
//                                var recivedResult = [FeedImageDataLoader.Result]()
//                                let task = sut.loadImageData(from: anyURL()) { recivedResult.append($0) }
//                                task.cancel()
//                                
//                                store.completeRetrieval(with: anyData())
//                                store.completeRetrieval(with: .none)
//                                store.completeRetrieval(with: anyError())
//                                
//                                XCTAssertTrue(recivedResult.isEmpty, "Expected No Result after canceling all  task")
//    }
//    
//    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
//        let store = FeedImageDataStoreSpy()
//        
//        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
//        var recivedResult = [FeedImageDataLoader.Result]()
//        
//        _ = sut?.loadImageData(from: anyURL()) { recivedResult.append($0) }
//        
//        sut = nil
//        store.completeRetrieval(with: anyData())
//        
//        XCTAssertTrue(recivedResult.isEmpty,"expected no  result after instance has been deallocated")
//        
//        
//        
//    }
    
    private func failed() -> Result<Data, Error> {
            return .failure(LocalFeedImageDataLoader.loadError.failed)
        }
    
    private func notFound() -> Result<Data, Error> {
        return .failure(LocalFeedImageDataLoader.loadError.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Data, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        action()
        let receivedResult = Result { try sut.loadImageData(from: anyURL()) }
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            
        case (.failure(let receivedError as LocalFeedImageDataLoader.loadError),
              .failure(let expectedError as LocalFeedImageDataLoader.loadError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:LocalFeedImageDataLoader, store:FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
        
    }
    
    
    
}
