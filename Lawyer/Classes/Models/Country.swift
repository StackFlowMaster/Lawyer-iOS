//
//  Country.swift
//  Lawyer
//
//  Created by Admin on 2/23/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class Country: Mappable {

    private var liveStatus: String?
    
    var countryId: String?
    var name: String?
    var phonecode: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.countryId <- map[G.id]
        self.name <- map[G.name]
        self.phonecode <- map[G.phonecode]
    }
    
    init(countryId: String, name: String, phonecode: String) {
        self.countryId = countryId
        self.name = name
        self.phonecode = phonecode
    }
}
