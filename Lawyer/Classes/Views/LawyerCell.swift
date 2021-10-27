//
//  LawyerCell.swift
//  Lawyer
//
//  Created by Admin on 11/2/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Cosmos

class LawyerCell: UITableViewCell {

    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var cellViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profileImageView.layer.borderWidth = 0.5
        self.profileImageView.layer.borderColor = UIColor.green.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        
        self.statusImageView.layer.borderWidth = 1.5
        self.statusImageView.layer.borderColor = UIColor.white.cgColor
        self.statusImageView.layer.cornerRadius = self.statusImageView.frame.height / 2
        
        self.ratingView.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        if selected {
            self.cellView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        }
        else {
            self.cellView.backgroundColor = UIColor.white
        }
    }
}
