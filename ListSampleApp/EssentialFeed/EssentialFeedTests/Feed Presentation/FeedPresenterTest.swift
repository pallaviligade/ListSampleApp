//
//  FeedPresenterTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 12.07.23.
//

import XCTest
import EssentialFeed

class FeedPresenterTest: XCTestCase{
    
    func test_isTitleLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
        
    }
    
    func test_map_createsViewModel() {
        let feed = uniqueItems().models
        let feedViewModel = FeedPresenter.map(feed)
        XCTAssertEqual(feedViewModel.feed, feed)
    }
    //MARK: - Helpers
       
    private func localized(_ key: String,table: String = "Feed", file: StaticString = #file, line: UInt = #line) -> String {
            let bundle = Bundle(for: FeedPresenter.self)
            let value = bundle.localizedString(forKey: key, value: nil, table: table)
            if value == key {
                XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
            }
            return value
        }
}


