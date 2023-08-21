//
//  SharedtestHelper.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 18.08.23.
//

import Foundation
import EssentialFeed

 func createuniqueFeedImage() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "any", location: nil, imageURL: URL(string: "http://any-url")!)]
}

 func anyError() -> Error {
    return NSError(domain: "any error", code: 0)
}

 func anyUrls() -> URL {
    return URL(string: "http://any-urls.com")!
}

 func anyData() -> Data {
    return Data(count: 100)
}
