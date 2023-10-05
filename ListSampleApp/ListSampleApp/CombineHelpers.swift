//
//  CombineHelpers.swift
//  ListSampleApp
//
//  Created by Pallavi on 21.09.23.
//

import Foundation
import Combine
import EssentialFeed
import EssentialFeediOS


public extension Httpclient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>

    func getPublisher(url: URL) -> Publisher {
        var task: HTTPClientTask?

        return Deferred {
            Future { completion in
                task = self.get(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

public extension FeedImageDataLoader {
    
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPubliser(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?
        
        return Deferred{
            Future { completion in
                task = self.loadImageData(from: url, completionHandler: completion)
            }
        }
        .handleEvents(receiveCancel: {task?.cancel() }) // we are using side effect after recving effect that is cancel
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, url: url)
        }).eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    
    func saveIgnoringResult(_ data: Data, url: URL) {
        save(data, for: url) { _ in }
    }
}

public extension LocalFeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    func loadPublisher() -> Publisher {
        Deferred {
            Future(self.load(completion:))
        }.eraseToAnyPublisher()
    }
}


extension Publisher where Output == [FeedImage] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {

        handleEvents(receiveOutput: { feed in
           cache.save(feed, completion: { _ in })
        }).eraseToAnyPublisher()
        
        //        map { feed in
        //            cache.save(feed, completion: { _ in })
        //            return feed
        //        }.eraseToAnyPublisher()
    }
}

extension Publisher {
    
    func fallback(to fallbackPubliser: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch{ _ in fallbackPubliser() }.eraseToAnyPublisher()
    }
    
}
extension Publisher {
    
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    
    static var immediateWhenOnMainQueueScheduler: InmediatesWhenOnMainQueueSchduler {
        InmediatesWhenOnMainQueueSchduler.shared
    }
    struct InmediatesWhenOnMainQueueSchduler: Scheduler {
        var now: DispatchQueue.SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        static let shared = Self()
        
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }
        
        private func isMainQueue() -> Bool {
            DispatchQueue.getSpecific(key: Self.key) == Self.value
        }
        
        func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue() else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            action()
        }
        
        func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action) as! Cancellable
        }
        
        func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
    }
}

