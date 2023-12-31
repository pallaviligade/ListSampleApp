//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 23.10.23.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
//    func test_title_isLocalized() {
//        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
//    }
    
    func test_map_createsViewModel() {
            let image = uniqueImage()

            let viewModel = FeedImagePresenter.map(image)

            XCTAssertEqual(viewModel.description, image.description)
            XCTAssertEqual(viewModel.location, image.location)
        }
    
  
 /*
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    private var fail: (Data) -> AnyImage? {
            return { _ in nil }
        }
        
   
        func test_didStartLoadingImageData_displaysLoadingImage() {
            let (sut, view) = makeSUT()
            let image = uniqueImage()
            
            sut.didStartImageLoadingData(for: image)
            
            let message = view.messages.first
            XCTAssertEqual(view.messages.count, 1)
            XCTAssertEqual(message?.description, image.description)
            XCTAssertEqual(message?.location, image.location)
            XCTAssertEqual(message?.isLoading, true)
            XCTAssertEqual(message?.shouldRetry, false)
            XCTAssertNil(message?.image)
        }
        
        func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
            let (sut, view) = makeSUT(imageTransformer: fail)
            let image = uniqueImage()
            
            sut.didFinishLoadingImageData(with: Data(), for: image)
            
            let message = view.messages.first
            XCTAssertEqual(view.messages.count, 1)
            XCTAssertEqual(message?.description, image.description)
            XCTAssertEqual(message?.location, image.location)
            XCTAssertEqual(message?.isLoading, false)
            XCTAssertEqual(message?.shouldRetry, true)
            XCTAssertNil(message?.image)
        }
        
        func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
            let image = uniqueImage()
            let transformedData = AnyImage()
            let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
            
            sut.didFinishLoadingImageData(with: Data(), for: image)
            
            let message = view.messages.first
            XCTAssertEqual(view.messages.count, 1)
            XCTAssertEqual(message?.description, image.description)
            XCTAssertEqual(message?.location, image.location)
            XCTAssertEqual(message?.isLoading, false)
            XCTAssertEqual(message?.shouldRetry, false)
            XCTAssertEqual(message?.image, transformedData)
        }
        
        func test_didFinishLoadingImageDataWithError_displaysRetry() {
            let image = uniqueImage()
            let (sut, view) = makeSUT()
            
            sut.didFinishLoadingImageData(with: anyNSError(), for: image)
            
            let message = view.messages.first
            XCTAssertEqual(view.messages.count, 1)
            XCTAssertEqual(message?.description, image.description)
            XCTAssertEqual(message?.location, image.location)
            XCTAssertEqual(message?.isLoading, false)
            XCTAssertEqual(message?.shouldRetry, true)
            XCTAssertNil(message?.image)
        }
    // MARK: - Helpers
    private func makeSUT(
        imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private func localized(_ key: String, table: String = "Feed", file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    private struct AnyImage: Equatable {}
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
    */
}
                                     
