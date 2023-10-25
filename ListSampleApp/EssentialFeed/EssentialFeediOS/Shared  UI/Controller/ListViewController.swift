//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 16.05.23.
//

import UIKit
import EssentialFeed



public protocol CellController {
    func view(at tableView: UITableView) -> UITableViewCell // This func creates view for each cell
    func preload() 
    func cancelLoad()
}

public final  class ListViewController: UITableViewController,UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView
{
   
    @IBOutlet private(set) public var errorView: ErrorView?
    public var onRefresh: (() -> Void)?
    private var loadingController = [IndexPath: CellController]()
    private var tableModel = [CellController]() {
        didSet { tableView.reloadData() }
    }
    
  
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = FeedPresenter.title
        refresh()
    }
    
    @IBAction func refresh()
    {
        onRefresh?()
        
    }
    
    public var errorMessage: String? {
        return errorView?.message
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    // Every time we get new model we so reseting it loadingController
    public func display(_ cellController: [CellController]) {
        loadingController = [:]
        tableModel = cellController
    }
    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        }else {
            refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        if let message = viewModel.message {
            errorView?.show(message: message)
        } else {
            errorView?.hideMessage()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(at: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       cancelCellControllerLoads(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoads)
        
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        //return tableModel[indexPath.row]
        
        let controller = tableModel[indexPath.row]
        loadingController[indexPath] = controller
        return controller
    }
    
    private func cancelCellControllerLoads(forRowAt indexPath: IndexPath) {
        loadingController[indexPath]?.cancelLoad()
        loadingController[indexPath] = nil
       // cellController(forRowAt: indexPath).cancelLoad()
    }
}