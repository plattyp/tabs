//
//  ContactTable.swift
//  tabs
//
//  Created by Andrew Platkin on 2/15/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import CoreData

@IBDesignable class ContactTable: UIView, UITableViewDataSource, UITableViewDelegate {

    var view: UIView!
    
    var nibName: String = "ContactTable"
    
    var rowHeight: CGFloat! = 50
    
    var groups: [Int: String] = [1: "Group 1", 2: "Group 2", 3: "Group 3"]

    //Reference to the Address Book
    lazy var addressBook: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil,
            &error).takeRetainedValue() as ABAddressBookRef
        }()
    
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

    var contacts  = [Contact]()
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBInspectable var groupName: String {
        get {
            return groupNameLabel.text!
        }
        set(groupid) {
            if (groupid.isEmpty) {
                groupNameLabel.text = ""
            } else {
                groupNameLabel.text = groups[groupid.toInt()!]
            }
        }
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        refreshTable()
    }
    
    // init
    override init(frame: CGRect) {
        // properties
        super.init(frame: frame)
        
        // Set anything that uses the view or visible bounds
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        // properties
        super.init(coder: aDecoder)
        
        // Setup
        setup()
    }
    
    func setup() {
        view = loadViewFromNib()
        
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        addSubview(view)
        
        //Styling for table
        tableView.layer.borderWidth = 2.0
        var tblView = UIView(frame: CGRectZero)
        //Hide the footer rows
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor.whiteColor()
        
        tableView.registerNib(UINib(nibName: "ContactListCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        //Get Data
        fetchContacts()
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as UIView
        
        return view
    }
    
    //Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var myCell:ContactListCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as ContactListCell
        
        // Get the contact for this index
        let contactItem = contacts[indexPath.row]
        
        myCell.nameLabel.text = retrievePersonInfo(contactItem.recordid.intValue)
        
        // Run this on the last row to trim the size of the table based on rows
        if (indexPath.row == (contacts.count - 1)) {
            setTableHeight()
        }
        
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
    
    func retrievePersonInfo(person: ABRecordID) -> String {
        
        var personName = ""
        
        println("Person ID: \(person)")
        
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
        
        return personName
    }
    
    func setTableHeight() {
        var frame:CGRect = self.tableView.frame
        frame.size.height = self.tableView.contentSize.height
        self.tableView.frame = frame
    }
    
    func refreshTable() {
        tableView.reloadData()
    }

}
