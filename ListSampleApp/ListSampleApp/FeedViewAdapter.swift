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
    
    private typealias FeedPresentatioAdapter =  LoadResourcePresentionAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    private typealias LoadMorePresentationAdapter = LoadResourcePresentionAdapter<Paginated<FeedImage>, FeedViewAdapter>
    private weak var controller : ListViewController?
    private let selection:  (FeedImage) -> Void
    private let imageloader:(URL) -> FeedImageDataLoader.Publisher
    
    init(controller: ListViewController, loader:@escaping(URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
        self.controller = controller
        self.imageloader = loader
        self.selection = selection
    }
    
    func display(_ viewmodel: Paginated<FeedImage>) {
        let feed: [CellController] = viewmodel.items.map { model in
            
            let adapter = FeedPresentatioAdapter (loader: { [imageloader] in
                imageloader(model.imageURL)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                })
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake)
            return CellController(id: model, view)
        }
        guard let loadMorePublisher = viewmodel.loadMorePublisher else {
                   controller?.display(feed)
                   return
               }
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        loadMoreAdapter.presenter = LoadResourcePresenter(
                    resourceView: self,
                    loadingView: WeakRefVirtualProxy(loadMore),
                    errorView: WeakRefVirtualProxy(loadMore))
        let loadMoreSection = [CellController(id: UUID(), loadMore)]

        controller?.display(feed, loadMoreSection)
    }
}
    

extension UIImage {
     struct InvalidImageData: Error {}
    
    static func tryMake(data: Data) throws -> UIImage {
     
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}




