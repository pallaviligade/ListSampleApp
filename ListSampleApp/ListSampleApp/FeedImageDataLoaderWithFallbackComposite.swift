//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  ListSampleApp
//
//  Created by Pallavi on 18.08.23.
//

import Foundation
import EssentialFeed

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
   
    private let imageDataloader: FeedImageDataLoader
    private let fallback : FeedImageDataLoader
    
   public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        imageDataloader = primary
        self.fallback = fallback
    }
    
    private struct TaskWrapper: FeedImageDataLoaderTask {
        var wrapper: FeedImageDataLoaderTask?
        func cancel() {
            wrapper?.cancel()
        }
    }
    
   public func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
      
        var task = TaskWrapper()
        task.wrapper = imageDataloader.loadImageData(from: url) { [weak self] result in
           switch result {
           case .success:
               completionHandler(result)
               break
           case .failure:
               task.wrapper = self?.fallback.loadImageData(from: url, completionHandler: completionHandler)
           }
           
       }
        return task
    }
    
}
