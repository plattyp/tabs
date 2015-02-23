//
//  Contacts.swift
//  tabs
//
//  Created by Andrew Platkin on 2/14/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import Foundation
import CoreData

class Contact: NSManagedObject {

    @NSManaged var recordid: NSNumber
    @NSManaged var groupRel: Group
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, recordid: Int, group: Group) -> Contact {
        let newContact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: moc) as Contact
        newContact.recordid = recordid
        newContact.groupRel = group
        
        return newContact
    }

}
