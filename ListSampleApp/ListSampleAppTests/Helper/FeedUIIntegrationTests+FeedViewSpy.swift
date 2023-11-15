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
        
        private var feedRequests = [PassthroughSubject<Paginated <FeedImage>, Error>] ()
        
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeFeedloading(with feedImage: [FeedImage] = [], at index:Int = 0) {
            feedRequests[index].send(Paginated(items: feedImage))
        }
        
        
        func completeFeedLoadingWithError(at index:Int) {
            let error = NSError(domain: "any error", code: 1)
            feedRequests[index].send(completion:.failure(error))
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
            let error = NSError(domain: "AnyError", code: 0)
            imageRequest[index].completions(.failure(error))
        }
    }
    
}

