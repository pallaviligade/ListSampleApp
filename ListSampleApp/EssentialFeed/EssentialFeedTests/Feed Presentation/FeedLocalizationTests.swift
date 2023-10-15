//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Pallavi on 02.07.23.
//

import EssentialFeed
import XCTest

final class FeedLocalizationTests: XCTestCase
{
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let presentationBundles = Bundle(for: FeedPresenter.self)
        assertLocalizedKeyAndValuesExist(in: presentationBundles, table)
    }
    
    //MARK: - Helpers
   // All helper moved to SharedLocalizationTestHelpers files
    
}
