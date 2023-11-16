//
//  FeedUIIntegrationTests+FeedViewSpy.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 07.11.23.
//

import Foundation
import Combine
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegration {
    
    class LoaderSpy: FeedImageDataLoader{
        
        private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            feedRequests[index].send(completion: .failure(anyNSError()))
        }
        
        func completeFeedloading(with feedImage: [FeedImage] = [], at index:Int = 0) {
            feedRequests[index].send(Paginated(items: feedImage, loadMorePublisher: { [weak self] in
                self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
            }))
        }
        
        // MARK: - LoadMoreFeedLoader
        private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        
        var loadMoreCallCount: Int {
            return loadMoreRequests.count
        }
        
        func loadMorePublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            loadMoreRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        
        func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) {
            loadMoreRequests[index].send(Paginated(
                items: feed,
                loadMorePublisher: lastPage ? nil : { [weak self] in
                    self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
                }))
        }
        
        func completeLoadMoreWithError(at index: Int = 0) {
            loadMoreRequests[index].send(completion: .failure(anyNSError()))
        }
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallBack: () -> Void
            func cancel() {
                cancelCallBack()
            }
        }
        
        // MARK: - Helpers  FeedImageDataLoader
        
        private  var imageRequest = [(url: URL, completions:(FeedImageDataLoader.Result) -> Void)]()
        
        var loadedImageUrls:  [URL] {
            return imageRequest.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequest.append((url, completionHandler))
            return TaskSpy { [weak self]  in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func compeletImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequest[index].completions(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            imageRequest[index].completions(.failure(anyNSError()))
        }
    }
    
}

