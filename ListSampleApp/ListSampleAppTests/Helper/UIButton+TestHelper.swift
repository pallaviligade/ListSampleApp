//
//  UIButton+TestHelper.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 02.11.23.
//

import UIKit

extension UIButton {
    func simulateToTap() {
        allTargets.forEach { target in
                      actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                          (target as NSObject).perform(Selector($0))
                      }
                  }
    }
}


