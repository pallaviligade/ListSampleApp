//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 16.05.23.
//

import UIKit
import EssentialFeed




//public protocol CellController {
//    func view(at tableView: UITableView) -> UITableViewCell // This func creates view for each cell
//    func preload()
//    func cancelLoad()
//}
//
//public extension CellController {
//    func preload() {}
//    func cancelLoad() {}
//}

public final  class ListViewController: UITableViewController,UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView
{
   
    private(set) public var errorView =  ErrorView()
    public var onRefresh: (() -> Void)?
//    private var loadingController = [IndexPath: CellController]()
//    private var tableModel = [CellController]() {
//        didSet { tableView.reloadData() }
//    }
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
            .init(tableView: tableView) { (tableView, index, controller) in
                print("\(index.row)")
                return controller.dataSource.tableView(tableView, cellForRowAt: index)
               
            }
        }()
  
    public override func viewDidLoad() {
        super.viewDidLoad()
       // title = FeedPresenter.title
        configureErrorView()
        self.tableView.dataSource = dataSource
        refresh()
    }
    
    private func configureErrorView() {
           let container = UIView()
           container.backgroundColor = .clear
           container.addSubview(errorView)

           errorView.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
               container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
               errorView.topAnchor.constraint(equalTo: container.topAnchor),
               container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
           ])

           tableView.tableHeaderView = container

           errorView.onHide = { [weak self] in
               self?.tableView.beginUpdates()
               self?.tableView.sizeTableHeaderToFit()
               self?.tableView.endUpdates()
           }
       }
    public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
            if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
                tableView.reloadData()
            }
        }
    @IBAction func refresh()
    {
        onRefresh?()
        
    }
    
    public var errorMessage: String? {
        return errorView.message
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    public func display(_ sections: [CellController]...) {
            var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
            sections.enumerated().forEach { section, cellControllers in
                snapshot.appendSections([section])
                snapshot.appendItems(cellControllers, toSection: section)
            }

            if #available(iOS 15.0, *) {
                dataSource.applySnapshotUsingReloadData(snapshot)
            } else {
                dataSource.apply(snapshot)
            }
        }
    
    // Every time we get new model we so reseting it loadingController
//    public func display(_ cellController: [CellController]) {
//        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
//                snapshot.appendSections([0])
//                snapshot.appendItems(cellController, toSection: 0)
//                dataSource.apply(snapshot)
//
////        loadingController = [:]
////        tableModel = cellController
//    }
    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        }else {
            refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
//    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return tableModel.count
//    }
//
//    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//       // return cellController(forRowAt: indexPath).view(at: tableView)
//        let ds = cellController(forRowAt: indexPath).dataSource
//        return ds.tableView(tableView, cellForRowAt: indexPath)
//    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      // cancelCellControllerLoads(forRowAt: indexPath)
        let dl = cellController(at: indexPath)?.delgate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetch
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetch
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
        
    }
    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
  /*  private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        //return tableModel[indexPath.row]
        
        let controller = tableModel[indexPath.row]
        loadingController[indexPath] = controller
        return controller
    }
    
    private func removeloadingController(forRowAt indexPath: IndexPath) -> CellController? {
        let controller = loadingController[indexPath]
        loadingController[indexPath] = nil
        return controller
    }*/
}
