//
//  CommentCell.swift
//  Lawyer
//
//  Created by Admin on 11/8/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Cosmos

class CommentCell: UITableViewCell {

    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.userImageView.layer.borderWidth = 0.5
        self.userImageView.layer.borderColor = UIColor.green.cgColor
        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        
        self.ratingView.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
