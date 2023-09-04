//
//  FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 15.05.23.
//

import Foundation
import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self:XCTestCase {
    
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            deleteCache(from: sut)

        expect(sut, toRetive: .success(.empty), file: file, line: line)
        }
  
}
