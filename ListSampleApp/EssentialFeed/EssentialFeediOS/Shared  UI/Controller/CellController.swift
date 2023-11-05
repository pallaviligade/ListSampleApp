//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 29.10.23.
//

import UIKit

public struct CellController  {
        let id: AnyHashable
        let delgate: UITableViewDelegate?
        let dataSourcePrefetch:UITableViewDataSourcePrefetching?
        let dataSource: UITableViewDataSource
    
   public init(id: AnyHashable,dataSourceAll:  UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching ) {
       self.id = id
        self.delgate = dataSourceAll
        self.dataSourcePrefetch = dataSourceAll
        self.dataSource = dataSourceAll
    }
    
    public init(id: AnyHashable,_ dataSource: UITableViewDataSource) {
        self.dataSource = dataSource
        self.dataSourcePrefetch = nil
        self.delgate = nil
        self.id = id
    }
}

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
