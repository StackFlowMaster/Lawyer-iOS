//
//  ChatOutgoingCell.swift
//  Lawyer
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatOutgoingCell: ChatCell {
    
    override class func layoutModel() -> ChatCellLayoutModel {
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.avatarSize = .zero
        defaultLayoutModel.containerMarginTop = 5.0
        defaultLayoutModel.containerMarginRight = 15.0
        defaultLayoutModel.messageMarginLeft = 20.0
        
        return defaultLayoutModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let messageContainer = messageContainer {
            messageContainer.layer.cornerRadius = 15
            messageContainer.layer.maskedCorners = [.layerMaxXMaxYCorner]
        }
        
        if let messageBgImageView = messageBgImageView {
            messageBgImageView.layer.cornerRadius = 25
            messageBgImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
    }
}
