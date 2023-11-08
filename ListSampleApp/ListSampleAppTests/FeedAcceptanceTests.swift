//
//  FeedAcceptanceTests.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 06.09.23.
//

import EssentialFeed
import EssentialFeediOS
@testable import ListSampleApp
import XCTest

class FeedAcceptanceTest: XCTestCase
{
    
    
   /* func test_onLaunch_displaysFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(response), store: .empty)

        XCTAssertEqual(feed.numberOfRenderFeedImageView(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
    }*/
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        
        let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        onlineFeed.simulateLoadMoreFeedAction()
        onlineFeed.simulateFeedImageViewVisible(at: 2)
        
        let offlineFeed = launch(httpClient: .offline, store: sharedStore)
        
        XCTAssertEqual(offlineFeed.numberOfRenderFeedImageView(), 3)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 2), makeImageData())
    }

        func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
            let feed = launch(httpClient: .online(response), store: .empty)
            XCTAssertEqual(feed.numberOfRenderFeedImageView(),0)
        }
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
            let store = InMemoryFeedStore.withExpiredFeedCache

            enterBackground(with: store)

            XCTAssertNil(store.feedCache, "Expected to delete expired cache")
        }

        func test_onEnteringBackground_keepsNonExpiredFeedCache() {
            let store = InMemoryFeedStore.withNonExpiredFeedCache

            enterBackground(with: store)

            XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
        }
    
    func test_onFeedImageSelection_displaysComments() {
            let comments = showCommentsForFirstImage()

            XCTAssertEqual(comments.numberOfRenderedComments(), 1)
            XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
        }
    
    private func showCommentsForFirstImage() -> ListViewController {
            let feed = launch(httpClient: .online(response), store: .empty)

            feed.simulateTapOnFeedImage(at: 0)
            RunLoop.current.run(until: Date())

            let nav = feed.navigationController
        let vc = nav?.topViewController as! ListViewController
        vc.simulateAppearance()
        return vc
    }
    
    private func enterBackground(with store: InMemoryFeedStore) {
            let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store, scheduler:
                    .immediateOnMainQueue)
            sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
        }
    // MARK: - Helpers
        private func launch(
            httpClient: HTTPClientStub = .offline,
            store: InMemoryFeedStore = .empty
        ) -> ListViewController {
            let sut = SceneDelegate(httpClient: httpClient, store: store, scheduler: .immediateOnMainQueue)
            sut.window = UIWindow()
            sut.configureWindow()

            let nav = sut.window?.rootViewController as? UINavigationController
            let vc = nav?.topViewController as! ListViewController
            vc.simulateAppearance()
            return vc
        }

       

  
        private func response(for url: URL) -> (Data, HTTPURLResponse) {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (makeData(for: url), response)
        }

    private func makeData(for url: URL) -> Data {
        switch url.path {
        case "/image-0": return makeImageData0()
        case "/image-1": return makeImageData1()
        case "/image-2": return makeImageData2()
            
        case "/essential-feed/v1/feed" where url.query?.contains("after_id") == false:
            return makeFirstFeedPageData()
            
        case "/essential-feed/v1/feed" where url.query?.contains("after_id=A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A") == true:
            return makeSecondFeedPageData()
            
        case "/essential-feed/v1/feed" where url.query?.contains("after_id=166FCDD7-C9F4-420A-B2D6-CE2EAFA3D82F") == true:
            return makeLastEmptyFeedPageData()
            
        case "/essential-feed/v1/image/2AB2AE66-A4B7-4A16-B374-51BBAC8DB086/comments":
            return makeCommentsData()
            
        default:
            return Data()
        }
    }
    
    private func makeCommentsData() -> Data {
            return try! JSONSerialization.data(withJSONObject: ["items": [
                [
                    "id": UUID().uuidString,
                    "message": makeCommentMessage(),
                    "created_at": "2020-05-20T11:24:59+0000",
                    "author": [
                        "username": "a username"
                    ]
                ],
            ]])
        }

        private func makeCommentMessage() -> String {
            "a message"
        }

    private func makeImageData0() -> Data { UIImage.make(withColor: .red).pngData()! }
    private func makeImageData1() -> Data { UIImage.make(withColor: .green).pngData()! }
    private func makeImageData2() -> Data { UIImage.make(withColor: .blue).pngData()! }
    
        private func makeImageData() -> Data {
            return UIImage.make(withColor: .red).pngData()!
        }

        private func makeFeedData() -> Data {
            return try! JSONSerialization.data(withJSONObject: ["items": [
                ["id": UUID().uuidString, "image": "http://image.com"],
                ["id": UUID().uuidString, "image": "http://image.com"]
            ]])
        }
    
    private func makeFirstFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086", "image": "http://feed.com/image-0"],
            ["id": "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A", "image": "http://feed.com/image-1"]
        ]])
    }
    
    private func makeSecondFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "166FCDD7-C9F4-420A-B2D6-CE2EAFA3D82F", "image": "http://feed.com/image-2"],
        ]])
    }
    
    private func makeLastEmptyFeedPageData() -> Data {
        try! JSONSerialization.data(withJSONObject: ["items": [[String: Any]]()])
    }
    
}
