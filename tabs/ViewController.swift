//
//  ViewController.swift
//  tabs
//
//  Created by Andrew Platkin on 2/12/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import CoreData

class ViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    var contacts  = [Contact]()
    
    @IBOutlet weak var numContactLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func refreshContactList(sender: AnyObject) {
        fetchContacts()
        
        numContactLabel.text = "\(contacts.count)"
        
        tableView.reloadData()
    }
    
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
    
    @IBAction func addContactButton(sender: AnyObject) {
        checkAddressBookPermissions()
        peoplePicker()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Styling for table
        tableView.layer.borderWidth = 2.0
        var tblView = UIView(frame: CGRectZero)
        //Hide the footer rows
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // All methods for controlling the table
    //
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var myCell:ContactListCell = tableView.dequeueReusableCellWithIdentifier("cell") as ContactListCell
        
        // Get the timer for this index
        let contactItem = contacts[indexPath.row]
        
        myCell.nameLabel.text = retrievePersonInfo(contactItem.recordid.intValue)
        
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
    
    func checkAddressBookPermissions() {
        //Check existing status of the Address Book Permissions
        if(ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Denied ||
            ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Restricted) {
                
                //Send alert that user is denied or restricted
                alertUser("No Access", message: "This application requires acccess to Contacts in order to operate. Please grant permissions to continue. \n (Settings -> App -> Toggle Contacts)")
                
        } else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Authorized) {
            NSLog("Authorized")
        } else {
            //If the status has not been Authorized or Denied
            ABAddressBookRequestAccessWithCompletion(addressBook, {success, error in
                if success {
                    NSLog("It worked!")
                } else {
                    //Send alert that user is denied or restricted
                    self.alertUser("No Access", message: "This application requires acccess to Contacts in order to operate. Please grant permissions to continue. \n (Settings -> App -> Toggle Contacts)")
                }
            })
        }
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!) {
        let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
        if (ABRecordGetRecordID(person) > 0) {
            let index = 0 as CFIndex
            
            //let email = ABMultiValueCopyValueAtIndex(emails, index).takeRetainedValue() as String
        
            let identifier = ABRecordGetRecordID(person)
            
            //Create & Save new Intance of Contact
            Contact.createInManagedObjectContext(self.managedObjectContext!, recordid: Int(identifier))
            
            //Save
            save()
            
        } else {
            println("No Record Found")
        }
    }
    
    func retrievePersonInfo(person: ABRecordID) -> String {
        checkAddressBookPermissions()
        
        var personName = ""
        
        if (person > 0) {
            let record = ABAddressBookGetPersonWithRecordID(addressBook, person)
        
            var personRef:ABRecordRef = Unmanaged<NSObject>.fromOpaque(record.toOpaque()).takeUnretainedValue() as ABRecordRef
            
            let firstName = ABRecordCopyValue(personRef, kABPersonFirstNameProperty).takeRetainedValue() as String
            
            let lastName  = ABRecordCopyValue(personRef, kABPersonLastNameProperty).takeRetainedValue() as String
            
            personName = firstName + " " + lastName
            
            println("Person Name: \(personName)")
        } else {
            NSLog("Cannot find record")
        }
        
        return personName
    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }
    
    func alertUser(alert: NSString, message: NSString) {
        //Create the UIAlertViewController with the message parameter
        var alert = UIAlertController(title: alert, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func peoplePicker() {
        let picker = ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        
        presentViewController(picker, animated: true, completion: nil)
    }

}

