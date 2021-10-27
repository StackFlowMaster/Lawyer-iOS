//
//  MessageCell.swift
//  Lawyer
//
//  Created by Admin on 11/5/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messageWrapper: UIView!
    @IBOutlet weak var messageBgView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    
    @IBOutlet weak var messageWrapperWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if (self.userImageView != nil) {
            self.userImageView.layer.borderWidth = 0.5
            self.userImageView.layer.borderColor = UIColor.green.cgColor
            self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class IncomingMessageCell: MessageCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.messageWrapper.layer.cornerRadius = 15
        self.messageWrapper.layer.maskedCorners = [.layerMinXMaxYCorner]
        
        self.messageBgView.layer.cornerRadius = 25
        self.messageBgView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class OutgoingMessageCell: MessageCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.messageWrapper.layer.cornerRadius = 15
        self.messageWrapper.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        self.messageBgView.layer.cornerRadius = 25
        self.messageBgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class TypingNowCell: MessageCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.messageWrapper.layer.cornerRadius = 15
        self.messageWrapper.layer.maskedCorners = [.layerMinXMaxYCorner]
        
        self.messageBgView.layer.cornerRadius = 25
        self.messageBgView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class NotificationMessageCell: MessageCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
