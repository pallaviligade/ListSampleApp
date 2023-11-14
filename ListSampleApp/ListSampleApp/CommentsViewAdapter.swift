//
//  CommentsViewAdapter.swift
//  ListSampleApp
//
//  Created by Pallavi on 14.11.23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public class CommentsViewAdapter: ResourceView {
    public typealias ResourceViewModel = ImageCommentsViewModel

    private weak var controller: ListViewController?

    init(controller: ListViewController) {
        self.controller = controller
    }

    public func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comment.map {
            CellController(id: $0, ImageCommentCellController(model: $0))
        })
    }
}

