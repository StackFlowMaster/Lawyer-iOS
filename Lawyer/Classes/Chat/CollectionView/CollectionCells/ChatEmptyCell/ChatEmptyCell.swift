//
//  ChatEmptyCell.swift
//  Lawyer
//
//  Created by Admin on 2/12/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class ChatEmptyCell: ChatCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override class func layoutModel() -> ChatCellLayoutModel {
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.avatarSize = .zero
        defaultLayoutModel.containerMarginTop = 5.0
        
        return defaultLayoutModel
    }
}
