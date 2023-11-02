//
//  FeedImageCell+TestHelper.swift
//  ListSampleAppTests
//
//  Created by Pallavi on 02.11.23.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell {
   
    func simulateRetryActions() {
        feedImageRetryButton.simulateToTap()
    }
    var discrText:String? {
        return discrptionLabel.text
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var isShowinglocation: Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator:Bool {
        return feedImageContainer.isShimmering
    }
    
    var renderImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool? {
        return !feedImageRetryButton.isHidden
    }
   
}
