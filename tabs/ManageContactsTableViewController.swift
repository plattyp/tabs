//
//  ManageContactsTableViewController.swift
//  tabs
//
//  Created by Andrew Platkin on 2/21/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import UIKit
import CoreData
import AddressBook
import AddressBookUI

protocol ManageContactsDelegate{
    func manageContactsDidFinish(controller:ManageContactsTableViewController, contactList:[ABRecordID])
}

class ManageContactsTableViewController: UITableViewController, ABPeoplePickerNavigationControllerDelegate {

    let picker = ABPeoplePickerNavigationController()
    var delegate:ManageContactsDelegate? = nil
    var contacts = [ABRecordID]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: "handleDone")
        navigationItem.leftBarButtonItem = doneButton
        
        var plusButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "peoplePicker")
        navigationItem.rightBarButtonItem = plusButton
        
        self.title = "Manage Contacts"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleDone() {
        if (delegate != nil) {
            delegate!.manageContactsDidFinish(self, contactList: contacts)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return contacts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("nameCell", forIndexPath: indexPath) as NameLabelCell
        
        var contact = contacts[indexPath.row]
        
        var name = retrievePersonInfo(contact)
        
        cell.nameLabel.text = name

        return cell
    }
    
    //For control of the people picker
    func peoplePicker() {
        picker.peoplePickerDelegate = self
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!) {
        let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
        if (ABRecordGetRecordID(person) > 0) {
            let index = 0 as CFIndex
        
            let identifier = ABRecordGetRecordID(person)
            
            if contains(contacts,identifier) == false {
                contacts.append(identifier)
            }
            
            println(contacts)
        } else {
            println("No Record Found")
        }
        
    }
    
    func retrievePersonInfo(person: ABRecordID) -> String {
        
        var personName:String = ""
        
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

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Remove from array
            contacts.removeAtIndex(indexPath.row)
            
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

}
