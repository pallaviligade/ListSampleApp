//
//  ListSampleAppUIAcceptanceTests.swift
//  ListSampleAppUIAcceptanceTests
//
//  Created by Pallavi on 28.08.23.
//

import XCTest

final class ListSampleAppUIAcceptanceTests: XCTestCase {

    func test_OnLaunchDisplayRemoteFeedWhenCustomerHasFeed() {
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-reset", "-connectivity", "online"]
        offlineApp.launch()
        
        let feedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 2)
        
        let firstImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
        
    }
  
//    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
//            let onlineApp = XCUIApplication()
//            onlineApp.launch()
//
//            let offlineApp = XCUIApplication()
//        onlineApp.launchArguments = ["-reset", "-connectivity", "online"]
//            offlineApp.launch()
//
//            let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
//            XCTAssertEqual(cachedFeedCells.count, 2)
//
//            let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
//            XCTAssertTrue(firstCachedImage.exists)
//        }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
            let onlineApp = XCUIApplication()
            onlineApp.launchArguments = ["-reset", "-connectivity", "online"]
            onlineApp.launch()

            let offlineApp = XCUIApplication()
            offlineApp.launchArguments = ["-connectivity", "offline"]
            offlineApp.launch()

            let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
            XCTAssertEqual(cachedFeedCells.count, 2)

            let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
            XCTAssertTrue(firstCachedImage.exists)
        }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
            let app = XCUIApplication()
            app.launchArguments = ["-reset", "-connectivity", "offline"]
            app.launch()

            let feedCells = app.cells.matching(identifier: "feed-image-cell")
            XCTAssertEqual(feedCells.count, 0)
        }
}
