//
//  FeedLoderStub.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 24.08.23.
//

import EssentialFeed

class FeedLoderStub: FeedLoader {
   
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(self.result)
    }
    
    
}
