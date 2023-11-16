//
//  SceneDelegate.swift
//  ListSampleApp
//
//  Created by Pallavi on 15.08.23.
//
import os
import UIKit
import CoreData
import Combine
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private lazy var httpClient: HTTPClient = {
         URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    

    
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
    }()

    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()

    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments))

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
     
        guard let _ = (scene as? UIWindowScene) else { return }
        
         configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }

    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)

        let commentsLoader = makeRemoteImageCommentsLoader(url: url)
        let commentsViewController = CommentsUIComposer.commentsComposedWith(commentsLoader: commentsLoader)

        navigationController.pushViewController(commentsViewController, animated: true)
    }

    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        let url = FeedEndpoint.get().url(baseURL: baseURL)

        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map { items in
                Paginated(items: items, loadMorePublisher: self.makeRemoteLoadMoreLoader(items: items, last: items.last))
            }
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?) -> (() -> AnyPublisher<Paginated<FeedImage>, Error>)? {
           last.map { lastItem in
               let url = FeedEndpoint.get(after: lastItem).url(baseURL: baseURL)

               return { [httpClient, localFeedLoader] in
                   httpClient
                       .getPublisher(url: url)
                       .tryMap(FeedItemMapper.map)
                       .map { newItems in
                           let allItems = items + newItems
                           return Paginated(items: allItems, loadMorePublisher: self.makeRemoteLoadMoreLoader(items: allItems, last: newItems.last))
                       }.caching(to: localFeedLoader)
               }
           }
       }

    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            })
    }

    private func makeRemoteImageCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        { [httpClient] in
            httpClient
                .getPublisher(url: url)
                .tryMap(ImageCommentMapper.map)
                .eraseToAnyPublisher()
        }
    }
}
