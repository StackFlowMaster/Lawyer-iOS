//
//  ZoomedAttachmentVC.swift
//  Lawyer
//
//  Created by Admin on 2/7/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class ZoomedAttachmentVC: UIViewController {
    
    // MARK: - Properties
    let zoomImageView = UIImageView()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .black
        zoomImageView.frame = view.frame
        zoomImageView.contentMode = .scaleAspectFit
        view.addSubview(zoomImageView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goBackAction(_ :)))
        view.addGestureRecognizer(tapGesture)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Actions
    @objc private func goBackAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
