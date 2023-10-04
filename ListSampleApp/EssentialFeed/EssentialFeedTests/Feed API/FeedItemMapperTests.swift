//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 21.04.23.
//

import XCTest
import EssentialFeed


final class FeedItemMapperTests: XCTestCase {
    
    
    
    func test_map_ThrowsErrorOnNon200HTTPResponse() throws {
            let json = makeItemsJSON([])

            let samples = [199, 201, 300, 400, 500]

            try samples.forEach {  code in
                XCTAssertThrowsError(
               try FeedItemMapper.map(json, from: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
               )
            }
        }
    
    func test_map_throwsErrorOn200HTTPResponsesWithInvalidJson() {
        let invalidJson = Data("invalid json".utf8)
        
       XCTAssertThrowsError(
       try FeedItemMapper.map(invalidJson, from: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
       )
    }
    
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws  {
        let emptyJson = Data("{\"items\": []}".utf8)
        
        let result = try FeedItemMapper.map(emptyJson, from: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        
        XCTAssertEqual(result, [])
       
    }
    
    
    func test_loaditemAfter_Recvied200Response() throws
    {
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)
        
        
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
        
        
        
      
        
        let item = [item1.model, item2.model]
        let json = makeItemsJSON([item1.json, item2.json])
        
        let result = try FeedItemMapper.map(json, from: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        
        XCTAssertEqual(result, item)
        
       
        
    }
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
            let url = URL(string: "http://any-url.com")!
            let client = HTTPClientSpy()
            var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

            var capturedResults = [RemoteFeedLoader.Result]()
            sut?.load { capturedResults.append($0) }

            sut = nil
            client.complete(withstatusCode: 200, data: makeItemsJSON([]))

            XCTAssertTrue(capturedResults.isEmpty)
        }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
            let json = ["items": items]
            return try! JSONSerialization.data(withJSONObject: json)
        }
    
    
   /*
    func test_deliery_ErrorOn200HttpResponseError() {
        let (sut,  client) = makeSUT()
        [199,400, 101, 300].enumerated().forEach { index,statusCode in
            expact(sut, toCompleteWithResult: failure(.invalidData)) {
                let jsondata = makeItemsJSON([])
                client.complete(withstatusCode: statusCode, data: jsondata, at: index)
            }
        }
    }
    
   
    func test_deliery_ErrorOnClientError() {
        let (sut,  client) = makeSUT()
        
        expact(sut, toCompleteWithResult: failure(.connectivity)) {
            let error =  NSError(domain: "Test", code: 0) // This is client error
            client.complete(with:error)
        }
    }
    
    func test_doesNotRequestDataFromUrl() {
        
        let (_,client)  = makeSUT()
        XCTAssertTrue(client.requestUrls.isEmpty)
        
    }
    
    func test_load_RequestsDataFromUrl() {
        let url = URL(string: "https://a-given-uel.com")!
        
        let (sut,client)  = makeSUT(url: url)
        
        sut.load { _ in  }
        
        XCTAssertEqual(client.requestUrls, [url])
        
    }
    
    func test_loadTwice_RequestsDataTwiceFromUrl() {
        let url = URL(string: "https://a-given-uel.com")!
        
        let (sut,client)  = makeSUT(url: url)
        
        sut.load { _ in  }
        sut.load { _ in  }
        
        XCTAssertEqual(client.requestUrls,[url, url])
        
    }
    // MARK: - Helper
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    */
    
  
    
    
   
    private func makeItem(id:  UUID, description: String? = nil, location: String? = nil,imageURL: URL ) -> (model: FeedImage, json: [String:Any])
    {
        let item = FeedImage(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues{  $0 }
        return (item, json)
        
    }
    
   /* private func expact(_ sut:RemoteFeedLoader, toCompleteWithResult  expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
       // var captureError = [RemoteFeedLoader.Result]()
        
//        sut.load { error in
//            captureError.append(error)
//        }
        // below is pattern matching exmaple
        
        let exp = expectation(description: "wait for load completion")
        
        sut.load { recvivedResult in
            switch (recvivedResult, expectedResult) {
                
            case let (.success(recvivedItem),  .success(expectItems)):
                XCTAssertEqual(recvivedItem, expectItems, file: file,line: line)
                
            case let (.failure(recvivedError), .failure(expectedError)):
                XCTAssertEqual(recvivedError as! RemoteFeedLoader.Error, expectedError as! RemoteFeedLoader.Error, file: file,line: line)
                
            default:
                XCTFail("Expected \(expectedResult) and got \(recvivedResult) instead",file: file,line: line)
                
            }
            exp.fulfill()
            
        }
        action()
       
        wait(for: [exp], timeout: 1.0)
    }*/
    
    
   
   /* private func makeSUT(url: URL = URL(string: "https://some-uel.com")!, file: StaticString = #file, line: UInt = #line ) -> (sut:RemoteFeedLoader, client:HTTPClientSpy)
    {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
       trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
   
    private class HTTPClientSpy: Httpclient {
        
        private var messages = [(urls: URL, complection: (Httpclient.Result) -> Void)]()
        
        private struct Task: HTTPClientTask {
            func cancel() {   }
        }
        var requestUrls :[URL] {
            return messages.map { $0.urls }
        }
        
        func get(from url: URL, completion: @escaping (Httpclient.Result) -> Void) ->  HTTPClientTask {
            messages.append((url, completion))
            return Task()
        }
        
        func complete(with error:Error,at index:Int = 0) {
            messages[index].complection(.failure(error))
        }
        
        func complete(withstatusCode code:Int,data:Data,at index:Int = 0) {
            let response = HTTPURLResponse(url: requestUrls[index],
                                           statusCode: code,
                                           httpVersion: nil, headerFields: nil)!
            messages[index].complection(.success((data, response)))
            
        }
    }*/
    
}

private extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
}
