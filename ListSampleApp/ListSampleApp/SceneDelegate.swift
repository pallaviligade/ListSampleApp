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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
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
        
       
         let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
         let localFeedLoder = LocalFeedLoader(store: localStore, currentDate: Date.init)
         let localImageLoder = LocalFeedImageDataLoader(store: localStore)
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
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
     

    


}


