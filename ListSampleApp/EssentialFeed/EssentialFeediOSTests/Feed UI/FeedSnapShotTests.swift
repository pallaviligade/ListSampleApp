//
//  FeedSnapShotTests.swift
//  EssentialFeediOSTests
//
//  Created by Pallavi on 11.09.23.
//

import XCTest
import EssentialFeediOS

class FeedSnapShotTests: XCTestCase {
    
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(snapShot: sut.snapshot(), named: "EMPTY_FEED")
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
