//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 26.09.23.
//

import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    
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
    

    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(RemoteImageCommentsLoader.Error.invalidData), when: {
                let json = makeItemJSON(item: [])
                client.complete(withstatusCode: code, data: json, at: index)
            })
        }
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
        
        let item1 = makeItem(
                    id: UUID(),
                    imageURL: URL(string: "http://a-url.com")!)

                let item2 = makeItem(
                    id: UUID(),
                    description: "a description", location: "a location",
                    imageURL: URL(string: "http://another-url.com")!)

        let itemsJSON = ["items":
        [item1.json, item2.json]]
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withstatusCode: 200,data: json)
        })
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
            return .failure(error)
        }
    
    private func makeItem(id:  UUID, description: String? = nil, location: String? = nil,imageURL: URL ) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = ["id":  id.uuidString,
                    "description": description,
                    "location":  location,
                    "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
        
        
    }
    
    private func makeItemJSON(item: [[String: Any]]) -> Data {
        let json = ["items": item]
        
        return try! JSONSerialization.data(withJSONObject: json)
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

            wait(for: [exp], timeout: 1.0)
        }
    
}

