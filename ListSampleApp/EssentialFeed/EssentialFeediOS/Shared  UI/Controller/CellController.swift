//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 29.10.23.
//

import UIKit

public struct CellController  {
        let id: AnyHashable
        let delegate: UITableViewDelegate?
        let dataSourcePrefetching:UITableViewDataSourcePrefetching?
        let dataSource: UITableViewDataSource
    
   public init(id: AnyHashable,dataSourceAll:  UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching ) {
       self.id = id
        self.delegate = dataSourceAll
        self.dataSourcePrefetching = dataSourceAll
        self.dataSource = dataSourceAll
    }
    
    public init(id: AnyHashable,_ dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        self.dataSourcePrefetching = nil
        self.delegate = nil
       
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
