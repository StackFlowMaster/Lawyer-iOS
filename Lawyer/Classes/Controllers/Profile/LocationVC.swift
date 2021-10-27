//
//  LocationVC.swift
//  Lawyer
//
//  Created by Admin on 3/14/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class LocationVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getAddressFromLocation(location: CLLocation(latitude: 40.714224, longitude: -73.961452))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tapDoneButton(_ sender: Any) {
    }
    
    func getAddressFromLocation(location: CLLocation) {
//        https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=YOUR_API_KEY
        
        let request = getRequest(urlString: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(location.coordinate.latitude),\(location.coordinate.longitude)&key=\(G.GoogleMapAPIKey)")
        
        Alamofire.Session.default.request(request)
        .responseJSON(completionHandler: { (response) in
            guard let result = response.data else {
                self.log(String(describing: response.error))
                return
            }

            do {
                let json = try JSON(data: result)
                self.log(json)
            } catch {
                // json parsing error
            }
        })
    }
    
    func getLocationFromAddress(address: String) {
//        https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=YOUR_API_KEY
        
    }

    func getRequest(urlString: String) -> URLRequest {
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = HTTPMethod.get.rawValue
        
        return request
    }
    
    func log(_ response:Any) {
        print("------------------------------------------------")
        print(
            "RESULT:", "\(response)",
            separator: "\n")
        print("------------------------------------------------")
    }
}
