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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let localStoreURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite")
    private lazy var httpClient: Httpclient = {
         URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
         try! CoreDataFeedStore(storeURL: localStoreURL)
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
               let remoteClient = makeRemoteClient()
               let RemoteImageloader = RemoteFeedImageDataLoader(client: remoteClient)
               let remoteFeedloader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
//               let feedViewController = FeedUIComposer.createFeedView(feedloader: remoteFeedloader, imageLoader: RemoteImageloader)
//               self.window?.rootViewController = feedViewController
        
       
         let localFeedLoder = LocalFeedLoader(store: store, currentDate: Date.init)
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
    func makeRemoteClient() -> Httpclient{
        return httpClient
    }
     

    


}


