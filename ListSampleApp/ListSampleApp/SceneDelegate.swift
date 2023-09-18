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
              
               let remoteFeedloader = RemoteFeedLoader(url: remoteURL, client: httpClient)
                let RemoteImageloader = RemoteFeedImageDataLoader(client: httpClient)
//               let feedViewController = FeedUIComposer.createFeedView(feedloader: remoteFeedloader, imageLoader: RemoteImageloader)
//               self.window?.rootViewController = feedViewController
        
       
       //  let localFeedLoder = LocalFeedLoader(store: store, currentDate: Date.init)
         let localImageLoder = LocalFeedImageDataLoader(store: store)
         let feedview = FeedUIComposer.createFeedView(
             feedloader: FeedLoaderWithFallbackComposite(
                 primary: FeedLoaderCacheDecorator(
                     decoratee: remoteFeedloader,
                     cache: localFeedLoder),
                 fallback: localFeedLoder),
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
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error>
    {
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        
        return Deferred {
            Future  { completion in
                remoteFeedLoader.load(completion: completion)
            }
        }.eraseToAnyPublisher() // Used when we wants to hide Publisher
    }

}


