//
//  Group.swift
//  tabs
//
//  Created by Andrew Platkin on 2/18/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import Foundation
import CoreData
import AddressBook

class Group: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var dayswatched: Int
    @NSManaged var watchtexts: Bool
    @NSManaged var watchcalls: Bool
    @NSManaged var watchfacetimes: Bool
    @NSManaged var interval: String
    @NSManaged var groupRel: NSSet
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, name: String, dayswatched: Int, watchtexts: Bool, watchcalls: Bool, watchfacetimes: Bool, interval: String) -> Group {
        let newGroup = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: moc) as Group
        
        newGroup.name = name
        newGroup.dayswatched = dayswatched
        newGroup.watchtexts = watchtexts
        newGroup.watchcalls = watchcalls
        newGroup.watchfacetimes = watchfacetimes
        newGroup.interval = interval
        
        return newGroup
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    class func initGroup(context: NSManagedObjectContext?) -> Group {
        let entity = NSEntityDescription.entityForName("Group", inManagedObjectContext: context!)!
        
        let group = Group(entity: entity, insertIntoManagedObjectContext: context)
        
        return group
    }
    
    //Used to retrieve the latest groups
    class func fetchGroups(moc: NSManagedObjectContext) -> [Group] {
        let fetchRequest = NSFetchRequest(entityName: "Group")
        
        // Create a sort descriptor object that sorts on the "name of the group"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var groups = [Group]()
        
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Group] {
            groups = fetchResults
        }
        
        return groups
    }

    //Used to retrieve the latest from TimersDefined and Insert the results into the timers array
    class func fetchGroup(moc: NSManagedObjectContext, objectID: NSManagedObjectID) -> Group {
        let fetchRequest = NSFetchRequest(entityName: "Group")
            
        fetchRequest.predicate = NSPredicate(format: "self == %@", objectID)
        
        var groups = [Group]()
        
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Group] {
            groups = fetchResults
        }
        
        return groups[0]
    }
    
    //Returns the permissions for a given group in an array of strings
    func fetchGroupPermissions() -> [String] {
        
        var permissions = [String]()
        
        if self.watchcalls {
            permissions.append("call")
        }
        
        if self.watchtexts {
            permissions.append("text")
        }
        
        if self.watchfacetimes {
            permissions.append("facetime")
        }
        
        return permissions
    }
    
    //Used to retrieve the latest from Contact and Insert the results into the contacts array
    func fetchContacts() -> [Contact] {
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        
        // Create a sort descriptor object that sorts on the "timerName"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "recordid", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.predicate = NSPredicate(format: "groupRel == %@", self)
        
        var contactResults = [Contact]()
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Contact] {
            contactResults = fetchResults
        }
        
        return contactResults
    }
    
    //Used to retrieve the latest from Contact and Insert the results into the contacts array
    func fetchContactsRecordIDS() -> [ABRecordID] {
        var contacts = fetchContacts()
        
        var records = [ABRecordID]()
        
        for contact in contacts {
            let recordid = contact.recordid.intValue as ABRecordID
            records.append(recordid)
        }
        
        return records
    }

}
