//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 04.07.23.
//

import EssentialFeed
import UIKit
import EssentialFeediOS


final class  FeedViewAdapter: FeedView {
    
    private weak var controller : FeedViewController?
    //private let imageloader: FeedImageDataLoader
    private let imageloader:(URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, loader:@escaping(URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageloader = loader
    }
    
    func display(_ viewmodel: EssentialFeed.FeedViewModel) {
        controller?.display(viewmodel.feed.map { model in
          //  FeedImageCellController(ViewModel: FeedImageCellViewModel(model:model , imageLoader: loader, imageTransfer: UIImage.init) )
            
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageloader)
                        let view = FeedImageCellController(delegate: adapter)

                        adapter.presenter = FeedImagePresenter(
                            view: WeakRefVirtualProxy(view),
                            imageTransformer: UIImage.init)

                        return view
        })
    }

}





