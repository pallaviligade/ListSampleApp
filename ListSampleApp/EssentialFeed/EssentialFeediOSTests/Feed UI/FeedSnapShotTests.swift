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
    
    
    
    func test_FeedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        //assert(snapShot: sut.snapshot(), named: "FEED_WITH_CONTENT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")
    }
    
    
    
    func test_FeedWithFailedImageLoading() {
        
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
       // assert(snapShot: sut.snapshot(), named: "FEED_WITH_FAILED_IMAGE_LOADING")
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
        
    }
    
    func test_feedWithLoadMoreIndicator() {
        let sut = makeSUT()
        
        sut.display(feedWithLoadMoreIndicator())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
    }
    
    func test_feedWithLoadMoreError() {
        let sut = makeSUT()
        
        sut.display(feedWithLoadMoreError())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_LOAD_MORE_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_LOAD_MORE_ERROR_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_LOAD_MORE_ERROR_extraExtraExtraLarge")
    }
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyBorad = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyBorad.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
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
    
    private func feedWithFailedImageLoading() -> [ImageStub]{
        
        let stub = [ImageStub(description: nil, location: "Pune", image: nil), ImageStub(description: nil, location: "Berlin", image: nil)]
        return stub
    }
    
    private func feedWithLoadMoreIndicator() -> [CellController] {
        
        
        let loadMore = LoadMoreCellController()
        loadMore.display(ResourceLoadingViewModel(isLoading: true))
        return feedWith(loadMore: loadMore)
    }
    
    private func feedWithLoadMoreError() -> [CellController] {
        
        let loadMore = LoadMoreCellController()
        loadMore.display(ResourceErrorViewModel(message: "This is a multiline\nerror message"))
        return feedWith(loadMore: loadMore)
    }
    
    private func feedWith(loadMore: LoadMoreCellController) ->  [CellController] {
        let stub = feedWithContent().last!
        let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
        stub.controller = cellController
        return [
            CellController(id: UUID(), cellController),
            CellController(id: UUID(), loadMore)
         ]
    }
    
    /* private func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
         
          let snapShotData = makeSnapshotData(for: snapshot, file: file, line: line)
         
          let snapshotURL = makeSnapshotURL(name: name)
         
         guard let storedSnapShotsData =  try? Data(contentsOf: snapshotURL)  else {
             XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
             return
         }
         
         if snapShotData != storedSnapShotsData {
             let temporarySnapshotURL = URL(filePath: NSTemporaryDirectory()).appendingPathComponent(snapshotURL.lastPathComponent)
             
             try? snapShotData?.write(to: temporarySnapshotURL)
             
             XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
         }
         
     }*/
    
    /*private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        
         let snapShotData = makeSnapshotData(for: snapshot, file: file, line: line)
        // create path
        let snapShotURL = makeSnapshotURL(name: name)
        
        // create Folder
        do {
            try FileManager.default.createDirectory(at: snapShotURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try snapShotData?.write(to: snapShotURL)
        }
        catch {
            XCTFail("Fail to record snapshots error, \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(name: String,file: StaticString = #file, line: UInt = #line ) -> URL {
        // create path
        let snapShotURL = URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapShots")
            .appendingPathComponent("\(name).png")
        
        return snapShotURL
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let snapShotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        return snapShotData
    }*/
    
}

extension UIViewController {
   
    
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
            return SnapshotWindow(configuration: configuration, root: self).snapshot()
        }
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellController] = stubs.map({ stub in
            let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
            stub.controller = cellController
            return CellController(id: UUID(), cellController)
        })
        
        display(cells)
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection

    static func iPhone(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 390, height: 844),
            safeAreaInsets: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
            layoutMargins: UIEdgeInsets(top: 55, left: 8, bottom: 42, right: 8),
            traitCollection: UITraitCollection(traitsFrom: [
                .init(forceTouchCapability: .unavailable),
                .init(layoutDirection: .leftToRight),
                .init(preferredContentSizeCategory: contentSize),
                .init(userInterfaceIdiom: .phone),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(displayScale: 3),
                .init(accessibilityContrast: .normal),
                .init(displayGamut: .P3),
                .init(userInterfaceStyle: style)
            ]))
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone(style: .light)

    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }

    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }

    override var traitCollection: UITraitCollection {
        return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }
    func snapshot() -> UIImage {
        let render = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return render.image { action in
            layer.render(in: action.cgContext)
        }
    }
    
}

private class ImageStub: FeedImageCellControllerDelegate {
   
    weak var controller: FeedImageCellController?
    let viewModel:  FeedImageViewModel
    let image:  UIImage?
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(description: description,
                                       location: location)
        self.image = image
        
    }
    
    
    
    func didRequestImage() {
        controller?.display(ResourceLoadingViewModel(isLoading: false))

                if let image = image {
                    controller?.display(image)
                    controller?.display(ResourceErrorViewModel(message: .none))
                } else {
                    controller?.display(ResourceErrorViewModel(message: "any"))
                }
    }
    
    func didCancelImageRequest() {
        
    }
    
    
}
