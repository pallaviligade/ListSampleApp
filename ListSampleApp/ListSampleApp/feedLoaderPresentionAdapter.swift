//
//  feedLoaderPresentionAdapter.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 04.07.23.
//

import Foundation
import Combine
import EssentialFeed
import EssentialFeediOS

final class feedLoaderPresentionAdapter: FeedViewControllerDelegate  {
   var presenter: FeedPresenter?
    private let feedloader: () -> FeedLoader.Publisher
    private var cancellable: Cancellable?
    
    init( loader:@escaping() -> FeedLoader.Publisher) {
        self.feedloader = loader
    }
    
    func didRefershFeedRequest() {
        presenter?.didStartLoadingFeed()
        
        cancellable = feedloader().dispatchOnMainQueue().sink(receiveCompletion:  { [weak self] completion in
            switch completion {
            case .finished: break
            
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
                break
            }
            
        }, receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoadingFeed(feed)
        })

        
        
        
      /*  feedloader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(feed)
                break
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
                break
            }
          
        }*/
        
    }
    
}
