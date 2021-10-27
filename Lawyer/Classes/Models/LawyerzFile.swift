//
//  LawyerzFile.swift
//  Lawyer
//
//  Created by Admin on 1/10/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class LawyerzFile: NSObject {
    
    var fileName: String?
    var fileKey: String?
    var fileData: Data?
    
    init(name: String, key: String, data: Data) {
        self.fileName = name
        self.fileKey = key
        self.fileData = data
    }
}
