//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 08.06.23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedUIComposer {
    
    private init() {}
    
    public static func createFeedView(feedloader: @escaping () -> FeedLoader.Publisher, imageLoader:  FeedImageDataLoader) -> FeedViewController {
        let presentionAdapter = feedLoaderPresentionAdapter(loader: { feedloader().dispatchOnMainQueue()})
        
        let feedViewController = makeFeedViewController(delegate: presentionAdapter, title: FeedPresenter
            .title)
//        presentionAdapter.presenter = FeedPresenter(
//            feedview: WeakRefVirtualProxy(feedViewController),
//            errorView: FeedViewAdapter(controller: feedViewController, loader: MainQueueDispatchDecorater(decoratee: imageLoader)))
        
        presentionAdapter.presenter = FeedPresenter(feedview: FeedViewAdapter(controller: feedViewController, loader: MainQueueDispatchDecorater(decoratee: imageLoader)),
                                                    errorView: WeakRefVirtualProxy(feedViewController), loadingview: WeakRefVirtualProxy(feedViewController))
      
      
        return feedViewController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
      
        feedViewController.delegate = delegate
        feedViewController.title = FeedPresenter.title
        return feedViewController
        
        
    }
    
}


