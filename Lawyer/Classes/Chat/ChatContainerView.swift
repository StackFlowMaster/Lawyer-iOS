//
//  ChatContainerView.swift
//  Lawyer
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

/**
 *  Customisable chat container view.
 */
class ChatContainerView: UIView {
    
    lazy var bubbleImageView: UIImageView = {
        let bubbleImageView = UIImageView()
        return bubbleImageView
    }()
    
    var image: UIImage? {
        didSet {
            bubbleImageView.image = image
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        bubbleImageView.alpha = 0.0
        
        isOpaque = true
    }
}
