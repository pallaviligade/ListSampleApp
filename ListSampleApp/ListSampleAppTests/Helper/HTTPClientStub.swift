//
//  HTTPClientStub.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 08.09.23.
//

import EssentialFeediOS
import EssentialFeed

public class HTTPClientStub: Httpclient {
    private class Task: HTTPClientTask {
        func cancel() {}
    }

    private let stub: (URL) -> Httpclient.Result

    init(stub: @escaping (URL) -> Httpclient.Result) {
        self.stub = stub
    }

    public func get(from url: URL, completion: @escaping (Httpclient.Result) -> Void) -> HTTPClientTask {
        completion(stub(url))
        return Task()
    }

    static var offline: HTTPClientStub {
        HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
    }

    static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        HTTPClientStub { url in .success(stub(url)) }
    }
}
