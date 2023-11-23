//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 19.07.23.
//

import Foundation


public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
