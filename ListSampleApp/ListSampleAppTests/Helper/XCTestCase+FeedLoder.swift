//
//  XCTestCase+FeedLoder.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 24.08.23.
//

import XCTest
import EssentialFeed

protocol FeedLoderTestCase: XCTestCase {}

extension FeedLoderTestCase {
    
     func expect(sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line ) {
        let exp = expectation(description: "wait until done")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
           
            case let (.success(recivedFeed), .success(expectedFeed)):
                XCTAssertEqual(recivedFeed, expectedFeed, file: file,line: line)
            case  (.failure, .failure): break
            
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
        
    }
    
}
