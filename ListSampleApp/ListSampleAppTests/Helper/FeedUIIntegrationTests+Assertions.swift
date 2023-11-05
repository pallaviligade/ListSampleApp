//
//  FeedUIIntegrationTests+Assertions.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 05.11.23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegration {
    
     func assertThat(_ sut: ListViewController, isRendering feed: [FeedImage],file: StaticString = #file, line: UInt = #line ) {

        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        guard sut.numberOfRenderFeedImageView() == feed.count else {
            XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderFeedImageView()) instead.", file: file, line: line)
            return
        }
        
        feed.enumerated().forEach { index, item  in
            assertThat(sut, hasViewConfiguredFor: item, at: index,file: file,line: line)
        }
        executeRunLoopToCleanUpReferences()
    }

    
     func assertThat(_ sut: ListViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
            let view = sut.feedImageView(at: index)

            guard let cell = view as? FeedImageCell else {
                return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
            }

            let shouldLocationBeVisible = (image.location != nil)
            XCTAssertEqual(cell.isShowinglocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)

            XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image  view at index (\(index))", file: file, line: line)

            XCTAssertEqual(cell.discrText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
        }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
}



