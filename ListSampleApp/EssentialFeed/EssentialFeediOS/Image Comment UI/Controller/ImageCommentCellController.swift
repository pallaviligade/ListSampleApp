//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 26.10.23.
//

import EssentialFeed
import UIKit

public class ImageCommentCellController: CellController {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(at tableView: UITableView) -> UITableViewCell {
        
        let cell: ImageCommentCell = tableView.dequeReuableCell()
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        cell.usernameLabel.text = model.username
       return cell
    }
    
    public func preload() {
        
    }
    
    public func cancelLoad() {
        
    }
    
    
  
    
}
