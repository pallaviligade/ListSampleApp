//
//  UIRefreshController+TestHelper.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 02.11.23.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
