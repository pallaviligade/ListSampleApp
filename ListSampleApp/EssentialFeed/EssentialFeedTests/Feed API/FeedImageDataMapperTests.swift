//
//  FeedImageDataMapperTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 06.10.23.
//

import XCTest
import EssentialFeed

class FeedImageDataMapperTests:  XCTestCase{
    
    
    func test_map_throwsErrorOnNo200HTTPResponse() throws {
        
        let samples = [199, 201, 300, 400, 500]
        
       try samples.forEach{ code in
           XCTAssertThrowsError(
               try  FeedImageDataMapper.map(anyData(), from: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
           )
        }
        
    }
    
    func test_map_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
            let emptyData = Data()

            XCTAssertThrowsError(
                try FeedImageDataMapper.map(emptyData, from: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
            )
        }

        func test_map_deliversReceivedNonEmptyDataOn200HTTPResponse() throws {
            let nonEmptyData = Data("non-empty data".utf8)

            let result = try FeedImageDataMapper.map(nonEmptyData, from: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)

            XCTAssertEqual(result, nonEmptyData)
        }
}
