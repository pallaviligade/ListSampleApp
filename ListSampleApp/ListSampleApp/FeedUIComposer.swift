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
    
    private typealias FeedPresentationAdapoter = LoadResourcePresentionAdapter<[FeedImage], FeedViewAdapter>
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader:  @escaping (URL) ->  FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void = { _ in }
    ) -> ListViewController {
        let presentionAdapter = FeedPresentationAdapoter(loader: feedLoader)
        
        let feedViewController = makeFeedViewController( title: FeedPresenter.title)
        feedViewController.onRefresh = presentionAdapter.loadResource

        
        presentionAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(controller: feedViewController,
            loader: imageLoader,
            selection: selection),
            loadingView: WeakRefVirtualProxy(feedViewController),
           errorView: WeakRefVirtualProxy(feedViewController),
            mapper: FeedPresenter.map)
        
      
        return feedViewController
    }
    
    private static func makeFeedViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! ListViewController
      
        feedViewController.title = FeedPresenter.title
        return feedViewController
        
        
    }
    
}


