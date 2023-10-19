//
//  ImageCommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 19.10.23.
//

import Foundation
import XCTest
import EssentialFeed


class ImageCommentPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    // MARK: - Helpers
        private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
            let table = "ImageComments"
            let bundle = Bundle(for: ImageCommentPresenter.self)
            let value = bundle.localizedString(forKey: key, value: nil, table: table)
            if value == key {
                XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
            }
            return value
        }
}
