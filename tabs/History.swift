//
//  History.swift
//  tabs
//
//  Created by Andrew Platkin on 2/23/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import Foundation
import CoreData

class History: NSManagedObject {

    @NSManaged var type: String
    @NSManaged var date: NSDate
    @NSManaged var contactRel: Contact

    class func createInManagedObjectContext(moc: NSManagedObjectContext, type: String, date: NSDate, contact: Contact) -> History {
        let newHistory = NSEntityDescription.insertNewObjectForEntityForName("History", inManagedObjectContext: moc) as History
        
        newHistory.type = type
        newHistory.date = date
        newHistory.contactRel = contact
        
        return newHistory
    }
}
