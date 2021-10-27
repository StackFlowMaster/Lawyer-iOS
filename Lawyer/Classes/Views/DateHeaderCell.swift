//
//  DateHeaderCell.swift
//  Lawyer
//
//  Created by Admin on 11/4/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class DateHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var dateButton: UIButton!
    
    override var isSelected: Bool {
        didSet {
            self.dateButton.isSelected = isSelected
        }
    }
}
