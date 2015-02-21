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

class CreateGroupViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate {

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
    
    let picker = ABPeoplePickerNavigationController()
    var groupObjectID  = NSManagedObjectID()
    var group = [Group]()
    var contacts = [ABRecordID]()
    var groupInterval:String = "days"
    
    @IBAction func createGroupButton(sender: AnyObject) {
        
        var days = Int(round(daysWatchedSlider.value))
        
        Group.createInManagedObjectContext(managedObjectContext!, name: groupNameInput.text, dayswatched: days, watchtexts: textMessagesToggle.enabled, watchcalls: phoneCallToggle.enabled, watchfacetimes: facetimesToggle.enabled, interval: groupInterval)
        
        save()
        
        performSegueWithIdentifier("createToMainSegue", sender: nil)
        
    }
    @IBAction func changeIntervalButton(sender: AnyObject) {
        let intervalAlert:UIAlertController = UIAlertController(title: "Interval", message: "Select an interval", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            println(action)
        }
        
        if groupInterval == "days" {
            let weekAction = UIAlertAction(title: "Weeks", style: .Default) { (action) in
                self.changeGroupInterval("weeks")
            }
            intervalAlert.addAction(weekAction)
        } else {
            let dayAction = UIAlertAction(title: "Days", style: .Default) { (action) in
                self.changeGroupInterval("days")
            }
            intervalAlert.addAction(dayAction)
        }
    
        intervalAlert.addAction(cancelAction)
        
        self.presentViewController(intervalAlert, animated: true, completion: {

        })
        
    }
    
    @IBAction func addContactsButton(sender: AnyObject) {
        peoplePicker()
    }
    
    
    @IBAction func sliderChanged(sender: AnyObject) {
        var units = daysWatchedSlider.value
        var unitsrounded = round(units)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        if fetchGroup() {
            groupNameInput.text = group[0].name
            daysWatchedSlider.value = Float(group[0].dayswatched)
            phoneCallToggle.enabled = group[0].watchcalls
            textMessagesToggle.enabled = group[0].watchtexts
            facetimesToggle.enabled = group[0].watchfacetimes
            changeGroupInterval(group[0].interval)
        } else {
            daysWatchedLabel.text = "30 days"
        }
        refreshContactCounter()
    }
    
    //Used to retrieve the latest from TimersDefined and Insert the results into the timers array
    func fetchGroup() -> Bool {
        if groupObjectID.isAccessibilityElement {
            let fetchRequest = NSFetchRequest(entityName: "Group")
            
            fetchRequest.predicate = NSPredicate(format: "self == %@", groupObjectID)
            
            if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Group] {
                group = fetchResults
                return true
            }
        }
        
        return false
    }
    
    func refreshContactCounter() {
        trackedContactsLabel.text = "\(contacts.count)"
    }
    
    func changeGroupInterval(interval: String) {
        groupInterval = interval
        
        if interval == "days" {
            var days = daysWatchedSlider.value * 7
            
            daysWatchedSlider.maximumValue = 365
            daysWatchedSlider.value = days
        } else if (interval == "weeks") {
            var weeks = daysWatchedSlider.value / 7
            
            var rounded = round(weeks)
            
            daysWatchedSlider.value  = rounded
            daysWatchedSlider.maximumValue = 52
        }
        
        sliderChanged(self)
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
            
            refreshContactCounter()
            
        } else {
            println("No Record Found")
        }

    }
    
}
