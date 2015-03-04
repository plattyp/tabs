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
    @NSManaged var anchordate: NSDate
    @NSManaged var groupRel: Group
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, recordid: Int, anchordate: NSDate, group: Group) -> Contact {
        let newContact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: moc) as Contact
        newContact.recordid = recordid
        newContact.anchordate = anchordate
        newContact.groupRel = group
        
        return newContact
    }
    
    class func fetchContact(moc: NSManagedObjectContext, recordid: Int, group: Group) -> Contact {
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        
        fetchRequest.predicate = NSPredicate(format: "groupRel == %@ AND recordid == %d", group, recordid)
        
        var contactList = [Contact]()
        
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Contact] {
            contactList = fetchResults
        }
        
        return contactList[0]
    }

}
