//
//  NotificationCell.swift
//  Lawyer
//
//  Created by Admin on 11/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.userImageView.layer.borderWidth = 0.5
        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        
        self.shadowView.shadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
