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
    private let currentFeed: [FeedImage: CellController]
    
    init(currentFeed: [FeedImage: CellController] = [:],controller: ListViewController, loader:@escaping(URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
        self.currentFeed = currentFeed
        self.controller = controller
        self.imageloader = loader
        self.selection = selection
    }
    
    func display(_ viewmodel: Paginated<FeedImage>) {
        guard let controller = controller else { return }
        var currentFeed = self.currentFeed
        
        let feed: [CellController] = viewmodel.items.map { model in
            if let controller = currentFeed[model] {
                return controller
            }
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
            let controller = CellController(id: model, view)
            currentFeed[model] = controller
                return controller
        }
        guard let loadMorePublisher = viewmodel.loadMorePublisher else {
                   controller.display(feed)
                   return
               }
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                            currentFeed: currentFeed,
                            controller: controller,
                            loader: imageloader,
                            selection: selection
                        ),
                    loadingView: WeakRefVirtualProxy(loadMore),
                    errorView: WeakRefVirtualProxy(loadMore))
        let loadMoreSection = [CellController(id: UUID(), loadMore)]

        controller.display(feed, loadMoreSection)
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




