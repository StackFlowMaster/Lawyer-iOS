//
//  ProfileInfoVC.swift
//  Lawyer
//
//  Created by Admin on 11/8/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import MapKit

class ProfileInfoVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapper: UIView!
    
    @IBOutlet weak var cardWrapper: UIView!
    @IBOutlet weak var cardLabel: UILabel!
    
    @IBOutlet weak var locationWrapper: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapWrapper: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var firstNameWrapper: UIView!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameWrapper: UIView!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var mobileWrapper: UIView!
    @IBOutlet weak var mobileField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateWrapper()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func initUI() {
        self.title = "Information"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
        
        self.mapWrapper.layer.borderWidth = 0.5
        self.mapWrapper.layer.borderColor = UIColor.white.cgColor
        self.mapWrapper.layer.cornerRadius = 10.0
        
        self.continueButton.shadow()
        
        self.locationLabel.text = "Juffair Raod, Al Khalid Road, Makkah, KSA"
    }
    
    func updateWrapper() {
        self.scrollViewBottom.constant = self.view.frame.width * 100.0 / 375.0 - 20.0
        self.view.layoutIfNeeded()
        
        let scrollViewHeight = self.scrollView.frame.height
        let wrapperHeight = self.view.frame.width * 668.0 / 375.0
        if (wrapperHeight > scrollViewHeight) {
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: wrapperHeight)
        }
    }
    
    @IBAction func tapEditLocationButton(_ sender: UIButton) {
        
    }
    
    @IBAction func tapContinueButton(_ sender: UIButton) {
        guard let firstName = self.firstNameField.text else {
            self.firstNameField.becomeFirstResponder()
            return
        }
        
        guard let lastName = self.lastNameField.text else {
            self.lastNameField.becomeFirstResponder()
            return
        }
        
        guard let mobileNumber = self.mobileField.text else {
            self.mobileField.becomeFirstResponder()
            return
        }
        
        print("\(firstName) \(lastName) \(mobileNumber)")
        
        performSegue(withIdentifier: "ShowVerificationVC", sender: nil)
    }
}
