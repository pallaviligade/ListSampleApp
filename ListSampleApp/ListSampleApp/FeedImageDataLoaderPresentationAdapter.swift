//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 04.07.23.
//

import Foundation
import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine


final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
   // private let imageLoader: FeedImageDataLoader
    private let imageLoader:(URL) -> FeedImageDataLoader.Publisher
  //  private var task: FeedImageDataLoaderTask?
    private var cacellable: Cancellable?
    var presenter: FeedImagePresenter<View, Image>?

    init(model: FeedImage, imageLoader:@escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartImageLoadingData(for: model)

        let model = self.model
        cacellable = imageLoader(model.imageURL).sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }, receiveValue: {[weak  self] data in
            self?.presenter?.didFinishLoadingImageData(with: data, for: model)
        })

        
        
       /* task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)

            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }*/
    }

    func didCancelImageRequest() {
       // task?.cancel()
        cacellable?.cancel()
    }
}
