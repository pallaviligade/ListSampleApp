//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Pallavi on 06.10.23.
//

import Foundation

public final class FeedImageDataMapper {
    
    public enum Error: Swift.Error {
        case invalidate
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.isOk, !data.isEmpty else {
            throw Error.invalidate
        }
        
        return data
    }
    
}

