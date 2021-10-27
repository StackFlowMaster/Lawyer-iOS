//
//  AppointmentCell.swift
//  Lawyer
//
//  Created by Admin on 11/4/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class AppointmentCell: UITableViewCell {
    
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
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
