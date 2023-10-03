//
//  RemoteLoder.swift
//  EssentialFeed
//
//  Created by Pallavi on 30.09.23.
//

import Foundation

public final class RemoteLoader<Resource>: FeedLoader {
    private let url: URL
    private let client: Httpclient
    private let mapper: Mapper

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    public typealias Result = FeedLoader.Result

    public init(url: URL, client: Httpclient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)):
                completion(RemoteLoader.map(data, from: response))

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(Error.invalidData)
        }
    }
}

