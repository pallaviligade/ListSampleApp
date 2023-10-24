//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Pallavi on 17.07.23.
//

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
   

    public var hasLocation: Bool {
        return location != nil
    }
}
