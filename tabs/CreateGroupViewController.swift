//
//  CreateGroupViewController.swift
//  tabs
//
//  Created by Andrew Platkin on 2/18/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import UIKit
import CoreData
import AddressBookUI

class CreateGroupViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate, ManageContactsDelegate {

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
    
    @IBOutlet weak var groupNameInput: UITextField!
    @IBOutlet weak var daysWatchedSlider: UISlider!
    @IBOutlet weak var daysWatchedLabel: UILabel!
    @IBOutlet weak var phoneCallToggle: UISwitch!
    @IBOutlet weak var textMessagesToggle: UISwitch!
    @IBOutlet weak var facetimesToggle: UISwitch!
    @IBOutlet weak var trackedContactsLabel: UILabel!
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var deleteGroupButton: UIButton!
    
    var groupObjectID  = NSManagedObjectID()
    var isEditing = false
    var group = [Group]()
    var contacts = [ABRecordID]()
    var groupInterval:String = "days"
    
    @IBAction func manageContactsButton(sender: AnyObject) {
        performSegueWithIdentifier("manageContactsSegue", sender: self)
    }

    @IBAction func deleteGroupButtonPressed(sender: AnyObject) {
        deleteAlertConfirmation()
    }
    
    @IBAction func createGroupButton(sender: AnyObject) {
        let units = Int(convertDaysAndWeeks(groupInterval, currentValue: daysWatchedSlider.value, destInterval: "days"))
        
        if isEditing {
            var selectedGroup = group[0]
            
            //Update Group Attributes
            selectedGroup.setValue(groupNameInput.text, forKey: "name")
            selectedGroup.setValue(units, forKey: "dayswatched")
            selectedGroup.setValue(textMessagesToggle.on, forKey: "watchtexts")
            selectedGroup.setValue(phoneCallToggle.on, forKey: "watchcalls")
            selectedGroup.setValue(facetimesToggle.on, forKey: "watchfacetimes")
            selectedGroup.setValue(groupInterval, forKey: "interval")
            
            //Update Contacts
            
            //Retrieve Current Contacts
            var currentContacts = fetchContacts(selectedGroup)
            
            //Delete all contacts not in the new contact list
            for currentContact in currentContacts {
                if contains(contacts,currentContact) == false {
                    let contactForDeletion = fetchContact(Int(currentContact), group: selectedGroup)
                    managedObjectContext?.deleteObject(contactForDeletion)
                }
            }
            
            //Add all contacts that were previously in the contact list
            for contact in contacts {
                if contains(currentContacts,contact) == false {
                    Contact.createInManagedObjectContext(managedObjectContext!, recordid: Int(contact), group: selectedGroup)
                }
            }
            
            save()
            
        } else {
            let group = Group.createInManagedObjectContext(managedObjectContext!, name: groupNameInput.text, dayswatched: units, watchtexts: textMessagesToggle.on, watchcalls: phoneCallToggle.on, watchfacetimes: facetimesToggle.on, interval: groupInterval)
            
            save()
            
            //Save contacts to the group
            for contact in contacts {
                Contact.createInManagedObjectContext(managedObjectContext!, recordid: Int(contact), group: group)
                save()
            }
        }
        
        performSegueWithIdentifier("createToMainSegue", sender: nil)
    }
    @IBAction func changeIntervalButton(sender: AnyObject) {
        let intervalAlert:UIAlertController = UIAlertController(title: "Interval", message: "Select an interval", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            println(action)
        }
        
        if groupInterval == "days" {
            let weekAction = UIAlertAction(title: "Weeks", style: .Default) { (action) in
                self.changeGroupInterval(self.groupInterval, currentValue: self.daysWatchedSlider.value, destInterval: "weeks")
            }
            intervalAlert.addAction(weekAction)
        } else {
            let dayAction = UIAlertAction(title: "Days", style: .Default) { (action) in
                self.changeGroupInterval(self.groupInterval, currentValue: self.daysWatchedSlider.value, destInterval: "days")
            }
            intervalAlert.addAction(dayAction)
        }
    
        intervalAlert.addAction(cancelAction)
        
        self.presentViewController(intervalAlert, animated: true, completion: {

        })
        
    }
    
    @IBAction func sliderChanged(sender: AnyObject) {
        let units = daysWatchedSlider.value
        let unitsrounded = round(units)
        
        daysWatchedSlider.setValue(unitsrounded, animated: true)
        
        var suffix:String = "day"
        
        if groupInterval == "weeks" {
            suffix = "week"
        }
        
        if unitsrounded > 1 {
            suffix = suffix + "s"
        }
        
        daysWatchedLabel.text = "\(Int(unitsrounded)) \(suffix)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshContactCounter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        if isEditing {
            fetchGroup()
            
            //Adjust visible buttons
            createGroupButton.setTitle("Edit Group", forState: UIControlState.Normal)
            deleteGroupButton.hidden = false
            
            //Input preparation
            groupNameInput.text = group[0].name
            phoneCallToggle.setOn(group[0].watchcalls, animated: false)
            textMessagesToggle.setOn(group[0].watchtexts, animated: false)
            facetimesToggle.setOn(group[0].watchfacetimes, animated: false)
            
            //Adjust times for the slider
            changeGroupInterval("days", currentValue: Float(group[0].dayswatched) , destInterval: group[0].interval)
        } else {
            //Adjust visible buttons
            createGroupButton.setTitle("Create Group", forState: UIControlState.Normal)
            deleteGroupButton.hidden = true
            
            //Input preparation
            groupNameInput.text = ""
            daysWatchedSlider.value = 30.0
            phoneCallToggle.setOn(false, animated: false)
            textMessagesToggle.setOn(false, animated: false)
            facetimesToggle.setOn(false, animated: false)
            daysWatchedLabel.text = "30 days"
        }
        refreshContactCounter()
    }
    
    //Used to retrieve the latest from TimersDefined and Insert the results into the timers array
    func fetchGroup() {
        if isEditing {
            let fetchRequest = NSFetchRequest(entityName: "Group")
            
            fetchRequest.predicate = NSPredicate(format: "self == %@", groupObjectID)
            
            if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Group] {
                group = fetchResults
            }
            
            contacts = fetchContacts(group[0])
        }
    }
    
    //Used to retrieve the latest from Contact and Insert the results into the contacts array
    func fetchContacts(group: Group) -> [ABRecordID] {
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        
        // Create a sort descriptor object that sorts on the "timerName"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "recordid", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.predicate = NSPredicate(format: "groupRel == %@", group)
        
        var contactResults = [Contact]()
        var contactRecordArray = [ABRecordID]()
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Contact] {
            contactResults = fetchResults
        }
        
        for contact in contactResults {
            let recordid = contact.recordid.intValue as ABRecordID
            contactRecordArray.append(recordid)
        }
        
        return contactRecordArray
    }
    
    func fetchContact(recordid: Int, group: Group) -> Contact {
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        
        fetchRequest.predicate = NSPredicate(format: "groupRel == %@ AND recordid == %d", group, recordid)
        
        var contactList = [Contact]()
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Contact] {
            contactList = fetchResults
        }
        
        return contactList[0]
    }
    
    func deleteGroup() {
        let groupForDeletion = group[0]
        
        //Delete Contacts for Group
        for contact in contacts {
            var contactForDeletion = fetchContact(Int(contact), group: groupForDeletion)
            managedObjectContext?.deleteObject(contactForDeletion)
        }
        
        //Delete Group
        managedObjectContext?.deleteObject(groupForDeletion)
        
        save()
    }
    
    func deleteAlertConfirmation() {
        let alertController = UIAlertController(title: "Delete Group", message: "Are you sure that you would like to delete this group?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default) { (action) in
            self.deleteGroup()
            self.performSegueWithIdentifier("createToMainSegue", sender: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        self.presentViewController(alertController, animated: true, completion: {
            //
        })
    }
    
    func refreshContactCounter() {
        trackedContactsLabel.text = "\(contacts.count)"
    }
    
    func changeGroupInterval(interval: String, currentValue: Float, destInterval: String) {
        groupInterval = destInterval
        
        if destInterval == "days" {
            daysWatchedSlider.maximumValue = 365
        } else if (destInterval == "weeks") {
            daysWatchedSlider.maximumValue = 52
        }
        
        daysWatchedSlider.value = convertDaysAndWeeks(interval, currentValue: currentValue, destInterval: destInterval)
        
        sliderChanged(self)
    }
    
    func convertDaysAndWeeks(interval: String, currentValue: Float, destInterval: String) -> Float {
        var units = round(currentValue)
        
        if interval == "days" {
            if destInterval == "weeks" {
                return units / 7
            } else if (destInterval == "days") {
                return units
            }
        } else if (interval == "weeks") {
            if destInterval == "days" {
                return units * 7
            }
        }
        
        return 0
    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }
    
    //Hide on keyboard return
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        self.view.endEditing(true)
        return true;
    }
    
    //Hide on external touches outside the input
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.view.endEditing(true)
    }
    
    //Passing data from Contact Selection delegate back to main view
    func manageContactsDidFinish(controller: ManageContactsTableViewController, contactList: [ABRecordID]) {
        contacts = contactList
        controller.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "manageContactsSegue" {
            let vc = segue.destinationViewController as ManageContactsTableViewController
            vc.contacts = contacts
            vc.delegate = self
        }
    }
    
}
