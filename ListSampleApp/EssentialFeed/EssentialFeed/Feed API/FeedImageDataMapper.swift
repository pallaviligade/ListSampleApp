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

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOk: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
