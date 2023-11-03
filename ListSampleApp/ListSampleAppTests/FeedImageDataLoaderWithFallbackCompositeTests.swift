//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 16.08.23.
//

/*import XCTest
import EssentialFeed
import ListSampleApp


class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let primaryLoader = FeedImageDataLoderSpy()
        let fallbackLoader = FeedImageDataLoderSpy()
        _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryloderFirst() {
        let url = anyUrls()
       
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        
      _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURLs,[url], "Expected loads urls from primary loads")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadsImageData_lodsFromFallbackOnPrimaryloderFailour() {
        let urls = anyUrls()
        
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        
       _ = sut.loadImageData(from: urls) { _ in }
        
        primaryLoader.complete(with: anyError())
        
        XCTAssertEqual(primaryLoader.loadedURLs,[urls], "Expected loads urls from primary loads ")
        XCTAssertEqual(fallbackLoader.loadedURLs,[urls], "Expected loads urls from fallback loads ")
    }
    
    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
        let urls = anyUrls()
        
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        
        let task = sut.loadImageData(from: urls) { _ in }
        task.cancel()
        
        XCTAssertEqual(primaryLoader.loadedURLs,[urls], "Expected to cancel URL loading from primary loader ")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected to cancel URL loading from fallback loader ")
    }
    
    func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
            let url = anyUrls()
            let (sut, primaryLoader, fallbackLoader) = makeSUT()

            let task = sut.loadImageData(from: url) { _ in }
            primaryLoader.complete(with: anyError())
            task.cancel()

            XCTAssertTrue(primaryLoader.canceledUrls.isEmpty, "Expected no cancelled URLs in the primary loader")
            XCTAssertEqual(fallbackLoader.canceledUrls, [url], "Expected to cancel URL loading from fallback loader")
        }
    
  /*  func test_loadImageData_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
            let (sut, primaryLoader, fallbackLoader) = makeSUT()

            expect(sut, toCompleteWith: .failure(anyNSError()), when: {
                primaryLoader.complete(with: anyNSError())
                fallbackLoader.complete(with: anyNSError())
            })
        }
//    func test_loadImageData_deliversFallbackDataOnFallbackLoaderSuccess() {
//            let fallbackData = anyData()
//            let (sut, primaryLoader, fallbackLoader) = makeSUT()
//
//            expect(sut, toCompleteWith: .success(fallbackData), when: {
//                primaryLoader.complete(with: anyNSError())
//                fallbackLoader.complete(with: fallbackData)
//            })
//        }
  //  func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
//        let primaryData = anyData()
//        let (sut, primaryLoader, _) = makeSUT()
//        let task =  sut.loadImageData(from: anyUrls()) { _ in }
//        let recivedFeed = primaryLoader.complete(with: primaryData)
//
//        XCTAssertTrue(primaryLoader, "Expected no cancelled URLs in the primary loader")
//        XCTAssertEqual(fallbackLoader., "Expected to cancel URL loading from fallback loader")
//    }
    
//    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
//            let exp = expectation(description: "Wait for load completion")
//
//            _ = sut.loadImageData(from: anyURL()) { receivedResult in
//                switch (receivedResult, expectedResult) {
//                case let (.success(receivedFeed), .success(expectedFeed)):
//                    XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
//
//                case (.failure, .failure):
//                    break
//
//                default:
//                    XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
//                }
//
//                exp.fulfill()
//            }
//
//            action()
//
//            wait(for: [exp], timeout: 1.0)
//        } */
    
    //MARK: - Helpers
    
  
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:FeedImageDataLoaderWithFallbackComposite,primaryLoader: FeedImageDataLoderSpy,fallbackLoader: FeedImageDataLoderSpy) {
        let primaryLoader = FeedImageDataLoderSpy()
        let fallbackLoader = FeedImageDataLoderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    
    
  /*  private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion:(FeedImageDataLoader.Result) -> Void)] ()
        
        private(set) var cancelledURLs = [URL]()
        
        var loadedURLs:[URL]  {
            return messages.map { $0.url}
        }
        
        private struct Task: FeedImageDataLoaderTask {
            var callback : () -> Void
            
            func cancel() {
                callback()
            }
        }
        
        func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
            messages.append((url,completionHandler))
            
            return Task { [weak self] in
                    self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with error: Error, index: Int = 0)  {
            return messages[index].completion(.failure(error))
        }
        
        func complete(with data: Data, index: Int = 0) {
            messages[index].completion(.success(data))
        }
        
    }
}
   */*/
