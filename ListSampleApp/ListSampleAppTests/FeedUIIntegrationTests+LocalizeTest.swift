//
//  FeedViewControllerTest+LocalizeTest.swift
//  EssentialFeediOSTests
//
//  Created by Pallavi on 30.06.23.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegration {
    
    private class Dummy: ResourceView {
        func display(_ viewModel: Any) { }
    }
    
    var loadError: String {
        LoadResourcePresenter<Any,Dummy>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
    
}
