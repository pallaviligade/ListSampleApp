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
        
       /* let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
               let localStoreUrl = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
              
               let remoteFeedloader = RemoteFeedLoader(url: remoteURL, client: httpClient)
                let RemoteImageloader = RemoteFeedImageDataLoader(client: httpClient)
               let feedViewController = FeedUIComposer.createFeedView(feedloader: remoteFeedloader, imageLoader: RemoteImageloader)
               self.window?.rootViewController = feedViewController
        
        let localImageLoder = LocalFeedImageDataLoader(store: store)
         let localFeedLoder = LocalFeedLoader(store: store, currentDate: Date.init)*/
        
        
      
         let feedview = FeedUIComposer.createFeedView(
             feedloader: makeRemoteFeedLoaderWithLocalFallback,
             imageLoader: makeImageFeedLoaderWithLocalFallBack)
         
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
    
    private func makeImageFeedLoaderWithLocalFallBack(url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageloader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoder = LocalFeedImageDataLoader(store: store)
        
        return localImageLoder.loadImageDataPubliser(from: url)
            .fallback (to: { remoteImageloader
                    .loadImageDataPubliser(from: url)
                    .caching(to: localImageLoder, using: url)
            })
    }
}
