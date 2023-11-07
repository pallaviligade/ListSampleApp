//
//  ListViewController+TestHelper.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 02.11.23.
//

import UIKit
import EssentialFeediOS


//MARK: - Shared
public extension ListViewController {
    
    override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingloadingIndicator:Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateErrorViewTap() {
        errorView.simulateToTap()
    }
    
    var errorMessage: String? {
        return errorView.message
    }
    
}

extension ListViewController {
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderImage
    }
    
    @discardableResult
    func simulateFeedImageBecomingVisibleAgain(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewNotVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, willDisplay: view!, forRowAt: index)
        
        return view
    }
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
        
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    
    
  
    
    func numberOfRenderFeedImageView() ->  Int {
        numberOfRows(in: feedImagesSection)
    }
    private var feedImagesSection: Int { 0 }
    private var feedLoadMoreSection: Int { 1 }
    
    private func feedImageNumberOfSections() -> Int {
        return 0
    }
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section)  : 0
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row:Int) -> UITableViewCell? {
//        guard numberOfRenderedFeedImageViews() > row else {
//            return nil
//        }
//        let ds = tableView.dataSource
//        let index = IndexPath(row: row, section: feedImageNumberOfSections())
//        return ds?.tableView(tableView, cellForRowAt: index)
        cell(row: row, section: feedImagesSection)
    }
    @discardableResult
    func simulateFeedImageViewNotVisible(at row:Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageNumberOfSections())
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view
        
    }
    
    private func loadMoreFeedCell() -> LoadMoreCell? {
        cell(row: 0, section: feedLoadMoreSection) as? LoadMoreCell
    }
    
    
    
    func simulateLoadMoreFeedAction() {
        guard let view = loadMoreFeedCell() else { return }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: feedLoadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
    }
    
    func simulateFeedImagViewNearVisiable(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageNumberOfSections())
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisiable(at row: Int) {
        simulateFeedImagViewNearVisiable(at: row)
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageNumberOfSections())
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
   
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

//MARK: - Image comment shared 
extension ListViewController {
    func numberOfRenderedComments() -> Int {
        tableView.numberOfSections == 0 ? 0 :  tableView.numberOfRows(inSection: commentsSection)
    }
    
    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }
    
    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }
    
    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }
    
    private func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedComments() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
    }
    
    private var commentsSection: Int {
        return 0
    }
}
