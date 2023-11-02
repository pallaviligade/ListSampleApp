//
//  ListViewController+TestHelper.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 02.11.23.
//

import UIKit
import EssentialFeediOS

public extension ListViewController {
    
     override func loadViewIfNeeded() {
            super.loadViewIfNeeded()

            tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
    
    func simulateUserInitiatedFeedReload() {
            refreshControl?.simulatePullToRefresh()
        }
    
    var isShowingloadingIndicator:Bool {
        return refreshControl?.isRefreshing == true
    }
    
    @discardableResult
    func simulateFeedImageViewVisiable(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
        func simulateFeedImageBecomingVisibleAgain(at row: Int) -> FeedImageCell? {
            let view = simulateFeedImageViewNotVisible(at: row)

            let delegate = tableView.delegate
            let index = IndexPath(row: row, section: feedImagesSection)
            delegate?.tableView?(tableView, willDisplay: view!, forRowAt: index)

            return view
        }
    
    func numberOfRenderFeedImageView() ->  Int {
       // return tableView.numberOfSections > feedImageNumberOfSections() ? tableView.numberOfRows(inSection: feedImageNumberOfSections()) : 0
       // return tableView.numberOfRows(inSection: feedImageNumberOfSections())
        numberOfRows(in: feedImagesSection)
    }
    private var feedImagesSection: Int { 0 }

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
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageNumberOfSections())
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    @discardableResult
    func simulateFeedImageViewNotVisible(at row:Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisiable(at: row)
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageNumberOfSections())
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view
        
    }
    
    func simulateErrorViewTap() {
           errorView.simulateToTap()
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
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderImage
    }
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
}
