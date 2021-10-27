//
//  ChatAttachmentIncomingCell.swift
//  Lawyer
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatAttachmentIncomingCell: ChatAttachmentCell {
    
    override class func layoutModel() -> ChatCellLayoutModel {
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.avatarSize = CGSize(width: 30.0, height: 30.0)
        defaultLayoutModel.containerMarginTop = 40.0
        defaultLayoutModel.containerMarginLeft = 30.0
        return defaultLayoutModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let messageContainer = messageContainer {
            messageContainer.layer.cornerRadius = 15
            messageContainer.layer.maskedCorners = [.layerMinXMaxYCorner]
        }
        
        if let messageBgImageView = messageBgImageView {
            messageBgImageView.layer.cornerRadius = 25
            messageBgImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }
}
