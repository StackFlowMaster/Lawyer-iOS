//
//  ConversationCell.swift
//  Lawyer
//
//  Created by Admin on 11/5/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var cellViewHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.userImageView.layer.borderWidth = 0.5
        self.userImageView.layer.borderColor = UIColor.green.cgColor
        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        
        self.statusImageView.layer.borderWidth = 1.5
        self.statusImageView.layer.borderColor = UIColor.white.cgColor
        self.statusImageView.layer.cornerRadius = self.statusImageView.frame.height / 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
