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

final class LoadResourcePresentionAdapter<Resource, View: ResourceView> {
    var presenter: LoadResourcePresenter<Resource, View>?
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    
    init( loader:@escaping() -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader().dispatchOnMainQueue().sink(receiveCompletion:  { [weak self] completion in
            switch completion {
            case .finished: break
            
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
                break
            }
            
        }, receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoading(with: feed)
        })    
    }
    
}



extension LoadResourcePresentionAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
    
    
}
