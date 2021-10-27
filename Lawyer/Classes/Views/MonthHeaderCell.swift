//
//  MonthHeaderCell.swift
//  Lawyer
//
//  Created by Admin on 11/4/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class MonthHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var monthNameLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            self.monthNameLabel.textColor = isSelected ? UIColor(red: 73/255.0, green: 235/255.0, blue: 185/255.0, alpha: 1.0) : UIColor.darkText
            self.monthNameLabel.font = isSelected ? UIFont.systemFont(ofSize: 20.0) : UIFont.systemFont(ofSize: 18.0, weight: .light)
        }
    }
}
