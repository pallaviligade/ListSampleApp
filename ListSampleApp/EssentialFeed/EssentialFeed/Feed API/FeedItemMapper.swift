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
       private var items: [RemoteFeedItem]
        
        var images: [FeedImage] {
            items.map({ FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) })
        }
        
        private struct RemoteFeedItem:Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
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

