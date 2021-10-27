//
//  CountriesVC.swift
//  Lawyer
//
//  Created by Admin on 2/23/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class CountriesVC: UIViewController {
    
    @IBOutlet weak var countriesTableView: UITableView!

    var selectedCountryIndex = 0
    
    var countries = [Country]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
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
        let appManager = AppManager.shared
        
        countries = appManager.countries
        if (countries.count < 1) {
            appManager.getCountries { (countries) in
                self.countries = countries
                self.countriesTableView.reloadData()
            }
        }
        else {
            countriesTableView.reloadData()
        }
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapDoneButton(_ sender: Any) {
        performSegue(withIdentifier: "UnwindToHomeVCWithCountry", sender: nil)
    }
}


extension CountriesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = countries.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        
        let country = countries[indexPath.row]
        
        cell.textLabel!.text = country.name
        cell.accessoryType = indexPath.row == selectedCountryIndex ? .checkmark : .none
        
        return cell
    }
}


extension CountriesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let country = countries[indexPath.row]
        
        selectedCountryIndex = indexPath.row
        
        tableView.reloadData()
    }
}
