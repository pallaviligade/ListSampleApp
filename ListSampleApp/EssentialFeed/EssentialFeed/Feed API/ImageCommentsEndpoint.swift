//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Pallavi on 09.11.23.
//

import Foundation

public enum ImageCommentsEndpoint {
    case get

    public func url(baseURL: URL, imageId: UUID) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/image/\(imageId.uuidString)/comments")
        }
    }
}
