//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 19.10.23.
//

import Foundation
import XCTest
import EssentialFeed

class ImageCommentsLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentPresenter.self)

        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }

}
