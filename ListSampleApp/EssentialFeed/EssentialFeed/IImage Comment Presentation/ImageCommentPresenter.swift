//
//  ImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Pallavi on 19.10.23.
//

import Foundation

public class ImageCommentPresenter {
    
    static public var title: String {
        
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the image comments view")
        
    }
}
