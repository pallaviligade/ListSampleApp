//
//  UIRefreshControl+TestHelper.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 09.11.23.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
