//
//  LawyerTypesVC.swift
//  Lawyer
//
//  Created by Admin on 1/11/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class LawyerTypesVC: UIViewController {
    
    @IBOutlet weak var typesTableView: UITableView!
    
    var unwindSegueIdentifier: String?
    
    var selectedIndex: Int = -1
    var selectedLawyerType: LawyerType?
    var lawyerTypes = [LawyerType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
        
        getLawyersType()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

        
    // MARK: - Main functions
    
    func initUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapDoneButon))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc func tapDoneButon() {
        selectedLawyerType = self.lawyerTypes[self.selectedIndex]
        
//        self.performSegue(withIdentifier: "UnwindToLawyerSignupVCWithType", sender: nil)
        self.performSegue(withIdentifier: unwindSegueIdentifier!, sender: nil)
    }
    
    
    // MARK: - API functions
    
    func getLawyersType() {
        SVProgressHUD.show()
        AppWebClient.GetLawyersType { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetLawyersType api in LawyerTypesVC.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            guard let typeList = response[G.response].array else {
                return
            }
            
            self.lawyerTypes = [LawyerType]()
            for jsonType in typeList {
                guard let type = Mapper<LawyerType>().map(JSON: jsonType.dictionaryObject!) else {
                    return
                }
                
                self.lawyerTypes.append(type)
            }
            
            self.typesTableView.reloadData()
        }
    }
}


extension LawyerTypesVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lawyerTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LawyerTypeCell", for: indexPath)

        // Configure the cell...
        let type = self.lawyerTypes[indexPath.row]
        cell.textLabel?.text = type.type
        cell.accessoryType = indexPath.row == self.selectedIndex ? .checkmark : .none

        return cell
    }
}

extension LawyerTypesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        tableView.reloadData()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
