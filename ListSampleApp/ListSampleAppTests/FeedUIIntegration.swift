//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Pallavi on 16.05.23.
//

import UIKit
import XCTest
import EssentialFeed
import EssentialFeediOS
import ListSampleApp
import Combine


class FeedUIIntegration: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
       
        sut.simulateAppearance()
      
        XCTAssertEqual(sut.title,  feedTitle)
    }
    
    func test_imageSelection_notifiesHandler() {
        let image0 = makeImage()
        let image1 = makeImage()
        var selectedImages = [FeedImage]()
        let (sut, loader) = makeSUT(selection: { selectedImages.append($0) })
        
        sut.simulateAppearance()
        loader.completeFeedloading(with: [image0, image1], at: 0)
        
        sut.simulateTapOnFeedImage(at: 0)
        XCTAssertEqual(selectedImages, [image0])
        
        sut.simulateTapOnFeedImage(at: 1)
        XCTAssertEqual(selectedImages, [image0, image1])
    }
    
    func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
            let (sut, loader) = makeSUT()
            
            sut.simulateAppearance()
            XCTAssertEqual(sut.errorMessage, nil)

            loader.completeFeedLoadingWithError(at: 0)
            XCTAssertEqual(sut.errorMessage,loadError)

            sut.simulateUserInitiatedReload()
            XCTAssertEqual(sut.errorMessage, nil)
        }
    
    
    
    func test_loadFeedActions_requestFeedFromLoader(){
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
   
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
    
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected no request until previous completes")
        
        loader.completeFeedloading(at: 0)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
        
        loader.completeFeedloading(at: 1)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3,"Expected yet another loading request once user initiates another reload")
        
    }
    
    func test_tapOnLoadMoreErrorView_loadsMore() {
            let (sut, loader) = makeSUT()
            sut.simulateAppearance()
            loader.completeFeedloading()

            sut.simulateLoadMoreFeedAction()
            XCTAssertEqual(loader.loadMoreCallCount, 1)

            sut.simulateTapOnLoadMoreFeedError()
            XCTAssertEqual(loader.loadMoreCallCount, 1)

            loader.completeLoadMoreWithError()
            sut.simulateTapOnLoadMoreFeedError()
            XCTAssertEqual(loader.loadMoreCallCount, 2)
        }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingloadingIndicator, "Expected loading indicator once view is loaded")
        
      
        loader.completeFeedloading(at: 0)
        XCTAssertFalse(sut.isShowingloadingIndicator,"Expected no loading indicator once loading is completed")
   
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingloadingIndicator,"Expected loading indicator once user initiates a reload")
        
        loader.completeFeedloading(at: 1)
         XCTAssertFalse(sut.isShowingloadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }
    
    func test_loadFeedCompletions_renderSuccessfullyLoaded()
    {
        let imageO  = makeImage(description: "first item", location: "Berlin")
        let image1  = makeImage(description: nil, location: "Berlin")
        let image2  = makeImage(description: "first item", location: nil)
        let image3  = makeImage(description: nil, location: nil)
        
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: []) // Check the count(0) only there is no values
        
        loader.completeFeedloading(with: [imageO, image1], at: 0)
        assertThat(sut, isRendering: [imageO, image1])
        
        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [imageO, image1, image2, image3], at: 0)
        assertThat(sut, isRendering: [imageO, image1, image2, image3])
        
//        sut.simulateLoadMoreFeedAction()
//        loader.completeFeedloading(with: [imageO], at: 0)
//        assertThat(sut, isRendering: [imageO]) // Check the count (1)only there is  values too
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedloading(with: [imageO,image1], at: 1) // Check the count(4) only there is  values too
        assertThat(sut, isRendering: [imageO,image1])
        
        
        
    }
    
    
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        
        let image0  = makeImage()
        let image1  = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedloading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedloading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut,loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedloading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 0)
        assertThat(sut, isRendering: [image0])

        
    }
    
    func test_loadMoreCompletion_rendersErrorMessageOnError() {
            let (sut, loader) = makeSUT()
            sut.simulateAppearance()
            loader.completeFeedloading()

            sut.simulateLoadMoreFeedAction()
            XCTAssertEqual(sut.loadMoreFeedErrorMessage, nil)

            loader.completeLoadMoreWithError()
            XCTAssertEqual(sut.loadMoreFeedErrorMessage, loadError)

            sut.simulateLoadMoreFeedAction()
            XCTAssertEqual(sut.loadMoreFeedErrorMessage, nil)
        }
    
   
   //MARk: - Image view tests
    
    func test_feedImageView_loadsImageUrlsWhenVisiable() {
        let image0 = makeImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedloading(with: [image0, image1])
        
        XCTAssertEqual(loader.loadedImageUrls, [], "Expcted no image Urls until  view become visiable")
        
        sut.simulateFeedImageViewVisible(at: 0) // 0 is row number
        XCTAssertEqual(loader.loadedImageUrls,[image0.imageURL], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageUrls,[image0.imageURL, image1.imageURL], "Expected second image URL request once second view also becomes visible")

    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisiableAnyMore() {
        let image0 = makeImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedloading(with: [image0, image1])
        
        XCTAssertEqual(loader.cancelledImageURLs,[] ,"Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0) // 0 is row number
        XCTAssertEqual(loader.cancelledImageURLs,[image0.imageURL], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1) // 0 is row number
        XCTAssertEqual(loader.cancelledImageURLs,[image0.imageURL, image1.imageURL], "Expected one cancelled image URL request once first image is not visible anymore")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
      
        let (sut,  loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedloading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true,"Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true,"Expected loading indicator for second view while loading second image")
        
        loader.compeletImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
        
        view1?.simulateRetryActions()
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator state change for second view on retry action")
    }
    
    // MARK: - Load More Tests
        
        func test_loadMoreActions_requestMoreFromLoader() {
            let (sut, loader) = makeSUT()
            sut.simulateAppearance()
            loader.completeFeedloading()

            XCTAssertEqual(loader.loadMoreCallCount, 0, "Expected no requests before until load more action")

            sut.simulateLoadMoreFeedAction()
            XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected load more request")

            sut.simulateLoadMoreFeedAction()
            XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected no request while loading more")

            loader.completeLoadMore(lastPage: false, at: 0)
            sut.simulateLoadMoreFeedAction()
            XCTAssertEqual(loader.loadMoreCallCount, 2, "Expected request after load more completed with more pages")

            loader.completeLoadMoreWithError(at: 1)
            sut.simulateLoadMoreFeedAction()
            XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected request after load more failure")

            loader.completeLoadMore(lastPage: true, at: 2)
            sut.simulateLoadMoreFeedAction()
            XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected no request after loading all pages")
        }
    
    func test_loadingMoreIndicator_isVisibleWhileLoadingMore() {
            let (sut, loader) = makeSUT()

            sut.simulateAppearance()
            XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once view is loaded")

            loader.completeFeedloading(at: 0)
            XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once loading completes successfully")

            sut.simulateLoadMoreFeedAction()
            XCTAssertTrue(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on load more action")

            loader.completeLoadMore(at: 0)
            XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once user initiated loading completes successfully")

            sut.simulateLoadMoreFeedAction()
            XCTAssertTrue(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on second load more action")

            loader.completeLoadMoreWithError(at: 1)
            XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once user initiated loading completes with error")
        }
    
    func test_loadMoreCompletion_dispatchesFromBackgroundToMainThread() {
            let (sut, loader) = makeSUT()
            sut.simulateAppearance()
            loader.completeFeedloading(at: 0)
            sut.simulateLoadMoreFeedAction()

            let exp = expectation(description: "Wait for background queue")
            DispatchQueue.global().async {
                loader.completeLoadMore()
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
        }
    
   /* func test_feedImageView_RenderLoadedImageFromURL() {
       
        let (sut,  loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedloading(with: [makeFeedImage(), makeFeedImage()])
        let view0 = sut.simulateFeedImageViewVisiable(at: 0)
        let view1 = sut.simulateFeedImageViewVisiable(at: 1)
        
        XCTAssertEqual(view0?.renderImage, .none, "Expected no image for firstView whileloading first image")
        XCTAssertEqual(view1?.renderImage, .none, "Expected no image for firstView whileloading first image")

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.compeletImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderImage, imageData0,"Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
         loader.compeletImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
         XCTAssertEqual(view1?.renderImage, imageData1, "Expected image for second view once second image loading completes successfully")
        
        
    }*/
    
    func test_tapOnErrorView_hidesErrorMessage() {
            let (sut, loader) = makeSUT()

            sut.simulateAppearance()
            XCTAssertEqual(sut.errorMessage, nil)

            loader.completeFeedLoadingWithError(at: 0)
            XCTAssertEqual(sut.errorMessage, loadError)

            sut.simulateErrorViewTap()
            XCTAssertEqual(sut.errorMessage, nil)
        }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let image0 = makeImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedloading(with: [image0, image1])

            let view0 = sut.simulateFeedImageViewVisible(at: 0)
            let view1 = sut.simulateFeedImageViewVisible(at: 1)
            XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
            XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")

            let imageData = UIImage.make(withColor: .red).pngData()!
            loader.compeletImageLoading(with: imageData, at: 0)
            XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
            XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")

            loader.completeImageLoadingWithError(at: 1)
            XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
            XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
        }
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
     
        let (sut,  loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedloading(with: [makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invlidaImage = Data("wrong data".utf8)
        loader.compeletImageLoading(with: invlidaImage,at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
        
     }
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedloading(with: [image0, image1])
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL, image1.imageURL],"Expected 2 image URL request for 2 visable views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL, image1.imageURL],"Expected 2 image URL requests before retry actions")
        
        view0?.simulateRetryActions()
        XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL, image1.imageURL, image0.imageURL],"Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryActions()
        XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL, image1.imageURL, image0.imageURL, image1.imageURL],"Expected fourth imageURL request after second view retry action")
        
        
    }
    
    func test_feedImageView_doesNotShowDataFromPreviousRequestWhenCellIsReused() throws {
            let (sut, loader) = makeSUT()

            sut.simulateAppearance()
            loader.completeFeedloading(with: [makeImage(), makeImage()])

            let view0 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
            view0.prepareForReuse()

            let imageData0 = UIImage.make(withColor: .red).pngData()!
            loader.compeletImageLoading(with: imageData0, at: 0)

            XCTAssertEqual(view0.renderImage, .none, "Expected no image state change for reused view once image loading completes successfully")
        }
    
    func test_feedImageView_PreloadsImageURLWhenNearVisiable() {
        let image0 = makeImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedloading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageUrls, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL], "Expected first image URL request once first image is near visible")

       sut.simulateFeedImageViewVisible(at: 1)
       XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL, image1.imageURL], "Expected second image URL request once second image is near visible")
        
    }
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedloading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL, image1.imageURL], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
   
  
    func test_feedImageView_doesNotLoadImageAgainUntilPreviousRequestCompletes() {
            let image = makeImage(imgurl: URL(string: "http://url-0.com")!)
            let (sut, loader) = makeSUT()
            sut.simulateAppearance()
            loader.completeFeedloading(with: [image])

            sut.simulateFeedImageViewNearVisible(at: 0)
            XCTAssertEqual(loader.loadedImageUrls, [image.imageURL], "Expected first request when near visible")

            sut.simulateFeedImageViewVisible(at: 0)
            XCTAssertEqual(loader.loadedImageUrls, [image.imageURL], "Expected no request until previous completes")

            loader.compeletImageLoading(at: 0)
            sut.simulateFeedImageViewVisible(at: 0)
            XCTAssertEqual(loader.loadedImageUrls, [image.imageURL, image.imageURL], "Expected second request when visible after previous complete")

            sut.simulateFeedImageViewNotVisible(at: 0)
            sut.simulateFeedImageViewVisible(at: 0)
            XCTAssertEqual(loader.loadedImageUrls, [image.imageURL, image.imageURL, image.imageURL], "Expected third request when visible after canceling previous complete")
        
        sut.simulateLoadMoreFeedAction()
                loader.completeLoadMore(with: [image, makeImage()])
                sut.simulateFeedImageViewVisible(at: 0)
                XCTAssertEqual(loader.loadedImageUrls, [image.imageURL, image.imageURL, image.imageURL], "Expected no request until previous completes")
        }
    
    
    
    func makeSUT(
        selection: @escaping (FeedImage) -> Void = {  _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut:ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut  = FeedUIComposer.feedComposedWith(
            feedLoader: loader.loadPublisher,
            imageLoader: loader.loadImageDataPublisher,
            selection: selection
        )
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    func makeImage(description:String? = nil, location:String? = nil, imgurl: URL = URL(string: "http://any-url.com")!) ->  FeedImage
    {
         FeedImage(id: UUID(), description: description, location: location, imageURL:imgurl)
        
    }
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
            let (sut, loader) = makeSUT()
            sut.simulateAppearance()
        loader.completeFeedloading(with: [makeImage()])

            let view = sut.simulateFeedImageViewNotVisible(at: 0)
            loader.compeletImageLoading(with: anyImageData())

            XCTAssertNil(view?.renderImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
        }
    
    func test_loadFeedCompletion_dispatchFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        let exp =  expectation(description: "Wait for background queue")
        
        DispatchQueue.global().async {
            loader.completeFeedloading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
            
    }
    
    func test_loadFeedActions_runsAutomaticallyOnlyOnFirstAppearance() {
            let (sut, loader) = makeSUT()
            XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view appears")

            sut.simulateAppearance()
            XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view appears")

            sut.simulateAppearance()
            XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected no loading request the second time view appears")
        }
    
    func test_loadFeedImagesCompletion_dispatchFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        loader.completeFeedloading(with: [makeImage()])
        _ = sut.simulateFeedImageViewVisible(at: 0)
        
        let exp =  expectation(description: "Wait for background queue")
        
        DispatchQueue.global().async {
            loader.compeletImageLoading(with: self.anyImageData(),at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
    }
    private func anyImageData() -> Data {
            return UIImage.make(withColor: .red).pngData()!
        }
   
    //MARK: - Helpers
    
}








