//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 04.07.23.
//

import EssentialFeed
import UIKit
import EssentialFeediOS


final class  FeedViewAdapter: ResourceView {
    
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
            
            let adapter = LoadResourcePresentionAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageloader] in
                
                imageloader(model.imageURL)
                
            })
            
            let view = FeedImageCellController(
                            viewModel: FeedImagePresenter<FeedImageCellController, UIImage>.map(model),
                            delegate: adapter)

                        adapter.presenter = LoadResourcePresenter(
                            resourceView: WeakRefVirtualProxy(view),
                            loadingView: WeakRefVirtualProxy(view),
                            errorView: WeakRefVirtualProxy(view),
                            mapper: { data in
                                guard let image = UIImage(data: data) else {
                                    throw InvalidImageData()
                                }
                                return image
                            })
              //          let view = FeedImageCellController(delegate: adapter)

                //        adapter.presenter = FeedImagePresenter(
                  //          view: WeakRefVirtualProxy(view),
                    //        imageTransformer: UIImage.init)

                        return view
        })
    }

    private struct InvalidImageData: Error {}
}





