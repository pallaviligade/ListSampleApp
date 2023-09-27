//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Pallavi on 25.09.23.
//

import Foundation
final class ImageCommentMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws ->  [RemoteFeedItem] {
         guard isOk(response) ,let root = try? JSONDecoder().decode(Root.self, from: data) else {
             throw RemoteImageCommentsLoader.Error.invalidData
        }
        return root.items
    }
    
    private static func isOk(_ reponse: HTTPURLResponse) -> Bool {
        (200...299).contains(reponse.statusCode)
    }
}


