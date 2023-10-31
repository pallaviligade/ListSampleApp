//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Pallavi on 26.10.23.
//

import XCTest
import EssentialFeed
@testable import EssentialFeediOS

class ImageCommentsSnapshotTests: XCTestCase {
    
    func test_listwWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_light_extraExtraExtraLarge")
    }
    
    // MARK: - Helpers
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController]{
        return []
    }
    
    private func comments() -> [CellController] {
        return commentsController().map { CellController($0) }
        
    }
    private func commentsController() -> [ImageCommentCellController] {
        
        let stub = [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "user name long long long a name"
                )
            ),
            ImageCommentCellController(model: ImageCommentViewModel(
                message: "located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                date: "10 day ago",
                username: "second user name"
            )),
            ImageCommentCellController(model: ImageCommentViewModel(
                message: "located near the centre of Berlin heritage-protected landmark.",
                date: "1 day ago",
                username: "3 user name"
            ))
            
        ]
        
        return stub
     }
    
    
}
