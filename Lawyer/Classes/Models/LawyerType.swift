//
//  LawyerType.swift
//  Lawyer
//
//  Created by Admin on 1/2/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class LawyerType: Mappable {
    
    var typeId: String?
    var type: String?
    
    init(typeId: String, type: String) {
        self.typeId = typeId
        self.type = type
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.typeId <- map[G.l_id]
        self.type <- map[G.type]
    }
}
