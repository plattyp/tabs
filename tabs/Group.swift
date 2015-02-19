//
//  Group.swift
//  tabs
//
//  Created by Andrew Platkin on 2/18/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import Foundation
import CoreData

class Group: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var dayswatched: Int
    @NSManaged var watchtexts: Bool
    @NSManaged var watchcalls: Bool
    @NSManaged var watchfacetimes: Bool
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, name: String, dayswatched: Int, watchtexts: Bool, watchcalls: Bool, watchfacetimes: Bool) -> Group {
        let newGroup = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: moc) as Group
        
        newGroup.name = name
        newGroup.dayswatched = dayswatched
        newGroup.watchtexts = watchtexts
        newGroup.watchcalls = watchcalls
        newGroup.watchfacetimes = watchfacetimes
        
        return newGroup
    }

}