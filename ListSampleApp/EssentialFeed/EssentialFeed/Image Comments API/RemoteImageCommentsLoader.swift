//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 25.09.23.
//

import Foundation

public final class RemoteImageCommentsLoader: FeedLoader {
    
    private let url: URL
    private let httpClient: Httpclient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    
    init(url: URL, client: Httpclient) {
        self.url = url
        self.httpClient = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        
        httpClient.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(RemoteImageCommentsLoader.map_(data, from: response))
                break
            case .failure:
                break
            }
        }
    }
    
    private static func map_(_ data: Data, from response: HTTPURLResponse) -> Result {
        do{
            let item = try ImageCommentMapper.map(data, response: response)
            return .success(item.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map({ FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) })
    }
}

final class ImageCommentMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws ->  [RemoteFeedItem] {
         guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
           throw RemoteFeedLoader.Error.invaildData
        }
        return root.items
    }
    
}


