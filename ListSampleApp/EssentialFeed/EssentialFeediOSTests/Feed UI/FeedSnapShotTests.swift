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
        
        record(snapShot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_FeedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        record(snapShot: sut.snapshot(), named: "FEED_WITH_CONTENT")
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
    
    private func feedWithContent() -> [ImageStub] {
        
        let stub = [ImageStub(description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                              location: "East Side Gallery\nMemorial in Berlin, Germany",
                              image: UIImage.make(withColor: .systemPink)),
            ImageStub(description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.", location: "East Side Gallery\nMemorial in Berlin, Germany", image: UIImage.make(withColor: .systemPink))]
        
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
