//
//  SceneDelegate.swift
//  ListSampleApp
//
//  Created by Pallavi on 15.08.23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private lazy var httpClient: Httpclient = {
         URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
         try! CoreDataFeedStore(storeURL: NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite"))
    }()
    
    private lazy var localFeedLoder: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: Httpclient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
        
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
     
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    func configureWindow() {
        
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
              // let localStoreUrl = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
              
             //  let remoteFeedloader = RemoteFeedLoader(url: remoteURL, client: httpClient)
                let RemoteImageloader = RemoteFeedImageDataLoader(client: httpClient)
//               let feedViewController = FeedUIComposer.createFeedView(feedloader: remoteFeedloader, imageLoader: RemoteImageloader)
//               self.window?.rootViewController = feedViewController
        
       
       //  let localFeedLoder = LocalFeedLoader(store: store, currentDate: Date.init)
         let localImageLoder = LocalFeedImageDataLoader(store: store)
         let feedview = FeedUIComposer.createFeedView(
             feedloader: makeRemoteFeedLoaderWithLocalFallback,
             imageLoader: FeedImageDataLoaderWithFallbackComposite(
                 primary: localImageLoder,
                 fallback: FeedImageDataLoaderCacheDecorator(
                     decorate: RemoteImageloader,
                     cache: localImageLoder)))
         
                self.window?.rootViewController = UINavigationController(rootViewController: feedview) 

    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoder.validateCache(completion: {_ in })
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher
    {
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
       return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoder)
            .fallback(to: localFeedLoder.loadPublisher)
            
            
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
        .handleEvents(receiveCancel: {task?.cancel() }) // we are  using side effect after recving effect that is cancel
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL, completionHandler:@escaping() -> Void) -> AnyPublisher<Output, Failure> {
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

public extension FeedLoader {
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
