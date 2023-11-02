//
//  UIRefreshController+TestHelper.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 02.11.23.
//

import UIKit
extension UIRefreshControl {
    func simulatePullToRefresh() {
      allTargets.forEach { target in
                    actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                        (target as NSObject).perform(Selector($0))
                    }
                }
    }
}
