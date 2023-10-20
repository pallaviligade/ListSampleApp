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
    
    func test_mapCreatesViewModel() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let local = Locale(identifier: "en_US_POSIX")
        
        let comments = [ImageComment(id: UUID(),
                                     message: "a message",
                                     createdAt: now.adding(minutes: -5),
                                     username: "a username"),
                        ImageComment(id: UUID(),
                                     message: "a another message",
                                     createdAt: now.adding(days: -1),
                                     username: "another username")
        ]
        
        let viewModel = ImageCommentPresenter.map(comments, currentDate: now, calendar: calendar, locale: local)
        
        XCTAssertEqual(viewModel.comment, [
            ImageCommentViewModel(
                message: "a message",
                date: "5 minutes ago",
                username: "a username"
            ),
            ImageCommentViewModel(
                message: "a another message",
                date: "1 day ago",
                username: "another username"
            )])
    }
}
