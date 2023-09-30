//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Pallavi on 28.04.23.
//

import Foundation




internal final class FeedItemMapper
{
    private struct Root:Decodable {
        var items: [RemoteFeedItem]
        
        var images: [FeedImage] {
            items.map({ FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) })
        }
    }
    
   

   
  //  static var OK_200: Int { return 200 }
    
   
    
    internal static func map(_ data:Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.statusCode == 200,
        let json = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invaildData
        }
       
        return json.images
       
    }
    
}

