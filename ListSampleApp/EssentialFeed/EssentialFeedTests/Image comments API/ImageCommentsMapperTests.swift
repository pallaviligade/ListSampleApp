//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 26.09.23.
//

import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {
    
    

    
    func test_map_ThrowsErrorOnNon200HTTPResponse() throws {
        let json = makeItemJSON(item: [])
     
        let samples = [199, 300, 400, 500, 150]
        
       try samples.forEach {  code in
            XCTAssertThrowsError(
                try ImageCommentMapper.map(json, response: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
            )
            
            }
        }
    
    
    
  
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)

            let samples = [200, 201, 250, 280, 299]

            try samples.forEach {  code in
                XCTAssertThrowsError(
                    try ImageCommentMapper.map(invalidJSON, response: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
                )
            }
        }

        func test_map_ThrowsNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {

            let Emptyjson = makeItemJSON(item: [])
            let samples = [200, 201, 250, 280, 299]

           try samples.forEach{  code in
                 let result  = try ImageCommentMapper.map(Emptyjson, response: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
               XCTAssertEqual(result, [])
            }
        }
    
    func test_map_ThrowsItemsOn2xxHTTPResponseWithJSONItems() throws{
        
        let item1 = makeItem(id: UUID(),
                             message: "First message",
                             createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                             username: "Dnyanesh")
        
        let item2 = makeItem(id: UUID(),
                             message: "I am working",
                             createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                             username:"Pallavi")
        
        
        let json = makeItemJSON(item: [item1.json, item2.json])
        
        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach {  code in
            let result  = try ImageCommentMapper.map(json, response: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
            XCTAssertEqual(result, [item1.model,item2.model])
        }
    }
    
    
    
    private func makeItem(id:  UUID, message: String, createdAt: (date: Date, isoString: String),username: String ) -> (model: ImageComment, json: [String: Any])
    {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String:Any] = ["id":  id.uuidString,
                    "message": message,
                     "created_at":  createdAt.isoString,
                    "author": [
                        "username": username
                    ]
        ]
        
        return (item, json)
        
        
    }
    
    private func makeItemJSON(item: [[String: Any]]) -> Data {
        let json = ["items": item]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
   /*
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
            let url = URL(string: "http://any-url.com")!
            let client = HTTPClientSpy()
            var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)

            var capturedResults = [RemoteImageCommentsLoader.Result]()
            sut?.load { capturedResults.append($0) }

            sut = nil
            client.complete(withstatusCode: 200,data: makeItemJSON(item: []))

           XCTAssertTrue(capturedResults.isEmpty)
        }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
            return .failure(error)
        }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
            let (sut, client) = makeSUT()

            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let invalidJSON = Data("invalid json".utf8)
                client.complete(withstatusCode: 200, data: invalidJSON)
            })
        }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
           let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
               let emptyListJSON = makeItemJSON(item: [])
               client.complete(withstatusCode: 200, data: emptyListJSON)
           })
       }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(),
                             message: "First message",
                             createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                             username: "Dnyanesh")
        
        let item2 = makeItem(id: UUID(),
                             message: "I am working",
                             createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                             username:"Pallavi")

        let itemsJSON = ["items":
        [item1.json, item2.json]]
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
          //  let json = makeItemJSON(item: [item1.json, item2.json])
            client.complete(withstatusCode: 200,data: json)
        })
    }
    
    func test_init_doesNotRequestDataFromUrl() {
      let (_, client) = makeSUT()
     
        XCTAssertTrue(client.requestUrl.isEmpty)
    }
    
    func test_load_RequestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in  }
        XCTAssertEqual(client.requestUrl,[url])
    }
    
    func test_load_RequestDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in  }
        sut.load { _ in  }
        
        XCTAssertEqual(client.requestUrl,[url, url])
    }
    
    func test_load_deliveryErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line ) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")

            sut.load { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

                case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)

                default:
                    XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
                }

                exp.fulfill()
            }

            action()

            wait(for: [exp], timeout: 1.5)
        }
    */
}

