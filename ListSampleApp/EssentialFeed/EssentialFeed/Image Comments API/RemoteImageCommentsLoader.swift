//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 25.09.23.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: Httpclient) {
        self.init(url: url, client: client, mapper: ImageCommentMapper.map(_:response:))
    }
}

/*public final class RemoteImageCommentsLoader {
    
    private let url: URL
    private let httpClient: Httpclient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[ImageComment], Swift.Error>
    
    
   public init(url: URL, client: Httpclient) {
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
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}
*/
