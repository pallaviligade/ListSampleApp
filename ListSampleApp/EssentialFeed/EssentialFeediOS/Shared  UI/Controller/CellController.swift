//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 29.10.23.
//

import UIKit

public struct CellController  {
        let delgate: UITableViewDelegate?
        let dataSourcePrefetch:UITableViewDataSourcePrefetching?
        let dataSource: UITableViewDataSource
    
   public init(dataSourceAll:  UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching ) {
        self.delgate = dataSourceAll
        self.dataSourcePrefetch = dataSourceAll
        self.dataSource = dataSourceAll
    }
    
    init(_ dataSource: UITableViewDataSource) {
        self.dataSource = dataSource
        self.dataSourcePrefetch = nil
        self.delgate = nil
    }
}
