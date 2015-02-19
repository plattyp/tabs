//
//  ContactViewController.swift
//  tabs
//
//  Created by Andrew Platkin on 2/15/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import CoreData

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    //Reference to Managed Object Context
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    //Reference to the Address Book
    lazy var addressBook: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil,
            &error).takeRetainedValue() as ABAddressBookRef
        }()
    
    var groups = [Group]()
    var contacts  = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Retrieves all of the groups from CoreData
        fetchGroups()
        
        //Temporarily load contacts here
        fetchContacts()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set the navigation bar
        self.title = "Your Tabs"
        var refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshCells")
        navigationItem.leftBarButtonItem = refreshButton
        var plusButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addGroup")
        navigationItem.rightBarButtonItem = plusButton
        
        //Other Properties
        self.view.backgroundColor = UIColor.lightGrayColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Used to redraw the cells
    func refreshCells() {
        println("Group Count: \(groups.count)")
        
        for group in groups {
            println("\(group.name)")
        }
        
        tableView.reloadData()
    }
    
    func addGroup() {
        performSegueWithIdentifier("addGroupSegue", sender: nil)
    }
    
    //Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var group = groups[section]
        
        //This will need to perform a query to determine actual count based on group
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var myCell:ContactListCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as ContactListCell
        
        var contactItem:Contact = contacts[indexPath.row]
        
        var contactInfo:ContactInfo = retrievePersonInfo(contactItem.recordid.intValue)
        
        myCell.personNameLabel.text = contactInfo.personName
        myCell.daysSinceLastContactedLabel.text = "\(contactInfo.daysLastContacted)"
        myCell.dateLastContactedLabel.text = contactInfo.lastContactDate
        
        return myCell
    }
    
    //Used to retrieve the latest from Contact and Insert the results into the contacts array
    func fetchContacts() -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        
        // Create a sort descriptor object that sorts on the "timerName"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "recordid", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Contact] {
            contacts = fetchResults
        }
        return true
    }
    
    //Used to retrieve the latest from Group and Insert the results into the groups array
    func fetchGroups() -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "Group")
        
        // Create a sort descriptor object that sorts on the "timerName"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Group] {
            groups = fetchResults
        }
        return true
    }
    
    func retrievePersonInfo(person: ABRecordID) -> ContactInfo {
        
        var personName:String = ""
        var lastContactedDate:String = "11/11/1989"
        var daysLastContacted:Int = 22
        
        if (person > 0) {
            let record = ABAddressBookGetPersonWithRecordID(addressBook, person)
            
            var personRef:ABRecordRef = Unmanaged<NSObject>.fromOpaque(record.toOpaque()).takeUnretainedValue() as ABRecordRef
            
            let firstName = ABRecordCopyValue(personRef, kABPersonFirstNameProperty).takeRetainedValue() as String
            
            let lastName  = ABRecordCopyValue(personRef, kABPersonLastNameProperty).takeRetainedValue() as String
            
            personName = firstName + " " + lastName
            
            println("Person's Name: \(personName)")
            
        } else {
            NSLog("Cannot find record")
        }
    
        var contactItem:ContactInfo = ContactInfo.init(personName: personName, lastContactDate: lastContactedDate, daysLastContacted: daysLastContacted)
        
        return contactItem
    }
    
}
