//
//  ContactInfo.swift
//  tabs
//
//  Created by Andrew Platkin on 2/18/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import Foundation

class ContactInfo {
    
    var personName: String
    var lastContactDate: String
    var daysLastContacted: Int
    
    init() {
        self.personName = ""
        self.lastContactDate = ""
        self.daysLastContacted = 0
    }
    
    init(personName: String, lastContactDate: String, daysLastContacted: Int) {
        self.personName = personName
        self.lastContactDate = lastContactDate
        self.daysLastContacted = daysLastContacted
    }
    
}