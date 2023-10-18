//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Pallavi on 14.07.23.
//

import Foundation



public protocol FeedView {
    func display(_ viewmodel: FeedViewModel)
}

public final class FeedPresenter {
    private let errorView: ResourceErrorView
    private let loadingView: ResourceLoadingView
    private let feedview: FeedView
    private var feedLoadError: String {
            return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                tableName: "Shared",
                bundle: Bundle(for: FeedPresenter.self),
                comment: "Error message displayed when we can't load the image feed from the server")
        }
    public static var title: String {
            return NSLocalizedString("FEED_VIEW_TITLE",
                tableName: "Feed",
                bundle: Bundle(for: FeedPresenter.self),
                comment: "Title for the feed view")
        }
    
    public  init(feedview: FeedView,errorView: ResourceErrorView, loadingview: ResourceLoadingView) {
        self.errorView = errorView
        self.loadingView = loadingview
        self.feedview = feedview
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(_ feed: [FeedImage])  {
        feedview.display(FeedViewModel(feed: feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
        
    }
     
}
