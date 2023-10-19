//
//  ImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Pallavi on 19.10.23.
//

import Foundation


public struct ImageCommentsViewModel {
    public let comment: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Equatable {
    
    public let message: String
    public let date: String
    public let username: String
    
    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
    
}

public class ImageCommentPresenter {
    
    static public var title: String {
        
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the image comments view")
        
    }
    
    public static func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        
        return ImageCommentsViewModel(comment: comments.map { comment in
            ImageCommentViewModel(message: comment.message, date: formatter.localizedString(for: comment.createdAt, relativeTo: Date()), username: comment.username)
        })
        
    }
}
