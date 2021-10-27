//
//  ChatNotificationCell.swift
//  Lawyer
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatNotificationCell: ChatCell {
    
    @IBOutlet weak var notificationLabel: UILabel!
    
    override class func layoutModel() -> ChatCellLayoutModel {
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.avatarSize = .zero
        defaultLayoutModel.containerMarginTop = 5.0
        
        return defaultLayoutModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        notificationLabel.backgroundColor = .clear
    }
}
