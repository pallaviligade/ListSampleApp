//
//  ListSampleAppUIAcceptanceTests.swift
//  ListSampleAppUIAcceptanceTests
//
//  Created by Pallavi on 28.08.23.
//

import XCTest

final class ListSampleAppUIAcceptanceTests: XCTestCase {

    func test_OnLaunchDisplayRemoteFeedWhenCustomerHasFeed() {
        
        let app = XCUIApplication()
        
        app.launch()
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)
        
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
        
    }
  
}
