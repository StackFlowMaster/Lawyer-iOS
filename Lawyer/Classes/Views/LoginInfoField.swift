//
//  LoginInfoField.swift
//  Lawyer
//
//  Created by Admin on 10/28/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class LoginInfoField: UIView {

    @IBOutlet weak var shadowImageView: UIImageView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoField: UITextField!
    @IBOutlet weak var borderLabel: UILabel!
    @IBOutlet weak var infoImageViewLeading: NSLayoutConstraint!
    
    var imageName: String?
    var placeholder: String?
    var attrPlaceholder: NSAttributedString?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func initInfoField(fieldName: String, placeholder: String, imageName: String) {
        self.imageName = imageName
        self.placeholder = placeholder
        self.attrPlaceholder = NSAttributedString.init(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        self.infoLabel.text = fieldName
        self.infoField.placeholder = self.placeholder
        self.infoField.attributedPlaceholder = self.attrPlaceholder
        
        self.highlightInfoField(highlight: false, animated: false)
    }
    
    func highlightInfoField(highlight: Bool, animated: Bool) {
        let duration = animated ? 0.2 : 0.0
        UIView.animate(withDuration: duration, animations: {
            self.shadowImageView.alpha = highlight ? 1.0 : 0.0
            self.bgImageView.alpha = highlight ? 1.0 : 0.0
            self.infoLabel.alpha = highlight ? 1.0 : 0.0
            self.borderLabel.alpha = highlight ? 0.0 : 1.0
            self.infoField.placeholder = highlight ? "" : self.placeholder
            self.infoField.attributedPlaceholder = highlight ? NSAttributedString.init() : self.attrPlaceholder
            self.infoImageView.image = UIImage(named: highlight ? "\(self.imageName!)_selected" : "\(self.imageName!)_normal")
            self.infoImageViewLeading.constant = highlight ? 10.0 : 5.0
            self.layoutIfNeeded()
        }) { (completed) in
            
        }
    }
}
