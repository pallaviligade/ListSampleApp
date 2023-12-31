//
//  EssentialFeedAPIEndToEndTestTests.swift
//  EssentialFeedAPIEndToEndTestTests
//
//  Created by Pallavi on 03/05/23.
//

import XCTest
import EssentialFeed
import Combine

final class EssentialFeedAPIEndToEndTestTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
       
        
        switch getFeedResult() {
        case let .success(item)?:
            XCTAssertEqual(item.count,8, "Expected 8 items in the test account feed")
            XCTAssertEqual(item[0], expectedItem(at: 0))
            break
        case let .failure(error)?:
            XCTFail("Expected successful feed result got \(error)")
            break
        default:
            XCTFail("Expected success feed result, got no result")
        }
        
    }
    
    //MARK: - helper
    private func getFeedResult() ->  Swift.Result<[FeedImage], Error>? {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5c52cdd0b8a045df091d2fff/1548930512083/feed-case-study-test-api-feed.json")!
        let httpclient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        
        let loader = RemoteLoader(url: url, client: httpclient, mapper: FeedItemMapper.map)
        
        let exp = expectation(description: "wait till result  load")
        var recivedResult:Swift.Result<[FeedImage], Error>?
        
        httpclient.get(from: url, completion: { result in
            recivedResult = result.flatMap({ (data, response) in
                do {
                    return.success(try FeedItemMapper.map(data, from: response))
                } catch {
                    return .failure(error)
                }
            })
            exp.fulfill()
        })
        wait(for: [exp], timeout: 4.0)
        return recivedResult
    }
    
    private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
            let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
            return client
        }
    private func expectedItem(at index:Int) -> FeedImage {
        
        return FeedImage(id: itemID(at: index),
                        description: description(at: index),
                        location: location(at: index),
                        imageURL:imageURL(at: index))
        
    }
    
    
    private func location(at index: Int) -> String? {
            return [
                "Location 1",
                "Location 2",
                nil,
                nil,
                "Location 5",
                "Location 6",
                "Location 7",
                "Location 8"
            ][index]
        }

        private func imageURL(at index: Int) -> URL {
            return URL(string: "https://url-\(index+1).com")!
        }
    
    private func itemID(at index: Int) -> UUID {
            return UUID(uuidString: [
                "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
                "BA298A85-6275-48D3-8315-9C8F7C1CD109",
                "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
                "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
                "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
                "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
                "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
                "F79BD7F8-063F-46E2-8147-A67635C3BB01"
            ][index])!
        }

        private func description(at index: Int) -> String? {
            return [
                "Description 1",
                nil,
                "Description 3",
                nil,
                "Description 5",
                "Description 6",
                "Description 7",
                "Description 8"
            ][index]
        }

}
