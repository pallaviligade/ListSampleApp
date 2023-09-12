//
//  FeedSnapShotTests.swift
//  EssentialFeediOSTests
//
//  Created by Pallavi on 11.09.23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class FeedSnapShotTests: XCTestCase {
    
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        assert(snapShot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_FeedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapShot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }
    
    func test_FeedWithError() {
        let sut = makeSUT()
        sut.display(.error(message: "This is a\n Muti line \n Error Message"))
        
        assert(snapShot: sut.snapshot(), named: "Feed_WITH_ERROR")
    }
    
    func test_FeedWithFailedImageLoading() {
        
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapShot: sut.snapshot(), named: "FEED_WITH_FAILED_IMAGE_LOADING")
        
    }
    
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyBorad = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyBorad.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController]{
        return []
    }
    
    private func assert(snapShot: UIImage, named: String, file: StaticString = #file, line: UInt = #line) {
        
        guard let snapShotData = snapShot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapShots")
            .appendingPathComponent("\(named).png")
        
        guard let storedSnapShotsData =  try? Data(contentsOf: snapshotURL)  else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        
        if snapShotData != storedSnapShotsData {
            let temporarySnapshotURL = URL(filePath: NSTemporaryDirectory()).appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapShotData.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
        
    }
    private func feedWithContent() -> [ImageStub] {
        
        let stub = [ImageStub(description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                              location: "East Side Gallery\nMemorial in Berlin, Germany",
                              image: UIImage.make(withColor: .systemPink)),
            ImageStub(description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.", location: "East Side Gallery\nMemorial in Berlin, Germany", image: UIImage.make(withColor: .systemPink))]
        
        return stub
     }
    
    private func feedWithFailedImageLoading() -> [ImageStub]{
        
        let stub = [ImageStub(description: nil, location: "Pune", image: nil), ImageStub(description: nil, location: "Berlin", image: nil)]
        return stub
    }
    
    private func record(snapShot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        
        guard let snapShotData = snapShot.pngData() else {
            return XCTFail("can not load snap shot png data")
        }
        // create path
        let snapShotURL = URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapShots")
            .appendingPathComponent("\(name).png")
        
        // create Folder
        do {
            try FileManager.default.createDirectory(at: snapShotURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try snapShotData.write(to: snapShotURL)
        }
        catch {
            XCTFail("Fail to record snapshots error, \(error)", file: file, line: line)
        }
        
        
        
    }
    
}

extension UIViewController {
    func snapshot() -> UIImage {
        let render = UIGraphicsImageRenderer(bounds: view.bounds)
        return render.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map({ stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        })
        
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
   
    weak var controller: FeedImageCellController?
    let viewModel:  FeedImageViewModel<UIImage>
    
    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedImageViewModel(description: description,
                                       location: location,
                                       image: image,
                                       isLoading: false,
                                       shouldRetry: image == nil)
        
    }
    
    
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {
        
    }
    
    
}
