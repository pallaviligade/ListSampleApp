//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Pallavi on 28.04.23.
//

import Foundation

public final class FeedItemMapper
{
    private struct Root:Decodable {
       private var items: [RemoteFeedItem]
        
        private struct RemoteFeedItem:Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
        
        var images: [FeedImage] {
            items.map({ FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) })
        }
    }
   
    public enum Error: Swift.Error {
        case invaildData
    }
        
    public static func map(_ data:Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.statusCode == 200,
        let json = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invaildData
        }
        return json.images
    }
}

