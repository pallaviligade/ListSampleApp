//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 07.06.23.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: NSObject {
  
    
    
    public typealias ResourceViewModel = UIImage
    
    //public typealias Image = UIImage
   
    private let viewModel: FeedImageViewModel
    
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    private let selection: () -> Void
    public init(viewModel:FeedImageViewModel ,delegate: FeedImageCellControllerDelegate, selection: @escaping () -> Void) {
        self.delegate = delegate
        self.viewModel = viewModel
        self.selection = selection
    }
   
}

extension FeedImageCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        delegate.didRequestImage()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       cell = tableView.dequeReuableCell()
       //cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as? FeedImageCell
       cell?.locationContainer.isHidden = !viewModel.hasLocation
       cell?.locationLabel.text = viewModel.location
       cell?.discrptionLabel.text = viewModel.description
       cell?.feedImageView.image = nil
        cell?.feedImageContainer.isShimmering = true
        cell?.feedImageRetryButton.isHidden = true
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestImage()
        }
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        delegate.didRequestImage()
       return cell!
   }
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            self.cell = cell as? FeedImageCell
            delegate.didRequestImage()
        }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection()
    }
 
    private func cancelLoad() {
         releaseCellForReuse()
         delegate.didCancelImageRequest()
     }
     
     private func releaseCellForReuse() {
         cell?.onReuse = nil
         cell = nil
     }
}

extension FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView{
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setAnimatedImage(viewModel)
    }
    
    public func display(_ viewModel: EssentialFeed.ResourceLoadingViewModel) {
        cell?.feedImageView.isShimmering  = viewModel.isLoading
    }
    
    public func display(_ viewModel: EssentialFeed.ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
    }
    
}


/*public final class FeedImageCellController {
    
    private let viewModel: FeedImageCellViewModel<UIImage>
  
    init(ViewModel: FeedImageCellViewModel<UIImage>) {
        viewModel = ViewModel
    }
    
    public  func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }
   
    public func preload() {
        viewModel.loadImageData()
    }
    
    public func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.discrptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak  cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.OnImageLoadingStateChange = { [weak cell] isLoading  in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryStateloadImageChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
}
*/
