//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 14.10.23.
//

import XCTest
import EssentialFeed

class SharedLocalizationTests:  XCTestCase {
    
    
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let presentationBundles = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValuesExist(in: presentationBundles, table)
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {
            
        }
    }
    //MARK: - Helpers in Shared Locationzation helper files
}
