//
//  SceneDelegate.swift
//  ListSampleApp
//
//  Created by Pallavi on 15.08.23.
//
import os
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
    
    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.essentialdeveloper.infra.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    
    private lazy var store: FeedStore & FeedImageDataStore = {
         try! CoreDataFeedStore(storeURL: NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite"))
    }()
    
    private lazy var localFeedLoder: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private var baseURL: URL {
        return URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    }
    
    private lazy var remoteFeedLoader = RemoteLoader(url:baseURL , client: httpClient, mapper: FeedItemMapper.map(_:from:))

    private lazy var navigationController = UINavigationController(
            rootViewController: FeedUIComposer.createFeedView(
                feedloader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: makeImageFeedLoaderWithLocalFallBack,
                selection: showComments))
    
    convenience init(httpClient: Httpclient, store: FeedStore & FeedImageDataStore, scheduler: AnyDispatchQueueScheduler) {
        self.init()
        self.httpClient = httpClient
        self.store = store
        self.scheduler = scheduler
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
     
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    func configureWindow() {
      
       /* let feedview = FeedUIComposer.createFeedView(
            feedloader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeImageFeedLoaderWithLocalFallBack)*/
        
        self.window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoder.validateCache(completion: {_ in })
    }
    
    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
           let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
           navigationController.pushViewController(comments, animated: true)
       }

       private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
           return { [httpClient] in
               return httpClient
                   .getPublisher(url: url)
                   .tryMap(ImageCommentMapper.map)
                   .eraseToAnyPublisher()
           }
       }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error>
    {
       
        let url = FeedEndpoint.get.url(baseURL: baseURL)
       //  lazy var remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)

       // let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemMapper.map)
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

extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: Httpclient) {
        self.init(url: url, client: client, mapper: ImageCommentMapper.map(_:response:))
    }
}

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: Httpclient) {
        self.init(url: url, client: client, mapper: FeedItemMapper.map(_:from:))
    }
}
