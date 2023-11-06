//
//  SharedTestHelper.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 03.11.23.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}


func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
   return Data(count: 100)
}

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())]
}
func createuniqueFeedImage() -> [FeedImage] {
   return [FeedImage(id: UUID(), description: "any", location: nil, imageURL: URL(string: "http://any-url")!)]
}

private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
}

var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
}

var feedTitle: String {
    FeedPresenter.title
}

var commentsTitle: String {
    ImageCommentPresenter.title
}
