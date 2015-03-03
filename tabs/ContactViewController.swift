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
import CoreTelephony

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedToggleContactsButton: UISegmentedControl!
    
    var selectedGroup = NSManagedObjectID()
    var editingGroup = false
    
    var groups = [Group]()
    var contacts  = [Contact]()
    var contactsbygroup = Dictionary<Group,Array<Contact>>()
    var callcenter = CTCallCenter()
    
    //Color Palette
    let seashellColor = UIColor(red: 64/255, green: 111/255, blue: 129/255, alpha: 1.0)
    let lightBlueColor = UIColor(red: 191/255, green: 202/255, blue: 206/255, alpha: 1.0)
    let lightCream = UIColor(red: 255/255, green: 255/255, blue: 251/255, alpha: 1.0)
    let darkBlue = UIColor(red: 44/255, green: 76/255, blue: 99/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Retrieves all of the groups from CoreData
        fetchGroups()
        
        //Load contacts to be readable by table
        loadContactDictionary()
        
        //Initialize table
        initializeTable()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set the navigation bar
        self.title = "Your Groups"
        
        //Customize Navigation Controls
        self.navigationController?.navigationBar.tintColor = seashellColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : seashellColor]
        self.navigationController?.navigationBar.barTintColor = lightCream
        
        let plusButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addGroup")
        navigationItem.rightBarButtonItem = plusButton
        
        let settingsButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: "goToSettings")
        navigationItem.leftBarButtonItem = settingsButton
        
        //Customize Segmented Control
        self.segmentedToggleContactsButton.backgroundColor = UIColor.whiteColor()
        self.segmentedToggleContactsButton.layer.cornerRadius = 5
        self.segmentedToggleContactsButton.selectedSegmentIndex = 1
        
        //Customize View
        self.view.backgroundColor = lightBlueColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addGroup() {
        editingGroup = false
        performSegueWithIdentifier("addGroupSegue", sender: nil)
    }
    
    func goToSettings() {
        println("Settings Button Pressed!")
    }
    
    func editGroup(sender: UIButton) {
        var group = groups[sender.tag]
        editingGroup = true
        selectedGroup = group.objectID
        
        performSegueWithIdentifier("addGroupSegue", sender: nil)
    }
    
    func initializeTable() {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0)
        
        tableView.backgroundColor = lightBlueColor
    }
    
    //Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //Locate the group associated with the section
        var group = groups[section]
        
        //Create a view to put the label and button within
        var view:UIView = UIView(frame: CGRectMake(10, 0, 300, 44))
        
        //Create the button
        var addButton:UIButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
        addButton.frame = CGRectMake(300, 5, 100, 50)
        addButton.tag = section
        addButton.tintColor = darkBlue
        addButton.addTarget(self, action: "editGroup:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //Create the title label
        var title:UILabel = UILabel(frame: CGRectMake(10, 5, 250, 50))
        title.textColor = darkBlue
        title.text = "\(group.name)"
        
        //Add button and title to the view
        view.addSubview(addButton)
        view.addSubview(title)
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var group = groups[section]
        
        var rows: Int = 0
        
        var count = contactsbygroup[group]?.count
        
        if count == 0 {
            rows = 1
        } else {
            rows = count!
        }
        
        //This will need to perform a query to determine actual count based on group
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
   
        let group = groups[indexPath.section]
        let contactResults = contactsbygroup[group]
        
        var totalrowcount = contactResults?.count
        
        if totalrowcount == 0 {
            var myCell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("errorCell", forIndexPath: indexPath) as UITableViewCell
            
            myCell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return myCell
            
        } else {
            
            var myCell:ContactListCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as ContactListCell

            var contactItem = contactResults?[indexPath.row]
            
            var contactInfo:ContactInfo = retrievePersonInfo(contactItem!, group: group)
            
            myCell.personNameLabel.text = contactInfo.personName
            myCell.daysSinceLastContactedLabel.text = "\(contactInfo.daysLastContacted)"
            myCell.dateLastContactedLabel.text = contactInfo.lastContactDate
            
            return myCell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let group = groups[indexPath.section]
        let permissions = fetchGroupPermissions(group)
        let contactResults = contactsbygroup[group]
        let contactSelected = contactResults?[indexPath.row]
        
        var permstring = ",".join(permissions)
        
        println("Permissions: \(permstring)")
        
        contactPersonMenu(contactSelected!, permissions: permissions)
    }
    
    func loadContactDictionary() {
        for group in groups {
            contactsbygroup[group] = fetchContacts(group)
        }
    }
    
    //Used to retrieve the latest from Contact and Insert the results into the contacts array
    func fetchContacts(group: Group) -> [Contact] {
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        
        // Create a sort descriptor object that sorts on the "timerName"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "recordid", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.predicate = NSPredicate(format: "groupRel == %@", group)
        
        var contactResults = [Contact]()
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Contact] {
            contactResults = fetchResults
        }
        
        return contactResults
    }
    
    //Used to retrieve the latest from Group and Insert the results into the groups array
    func fetchGroups() -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "Group")
        
        // Create a sort descriptor object that sorts on the "name of the group"
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
    
    func retrievePersonInfo(contact: Contact, group: Group) -> ContactInfo {
        
        var recordid = contact.recordid.intValue
        
        var personName:String = ""
        var lastContactedDate:String = ""
        var daysLastContacted:Int = 0
        
        if (recordid > 0) {
            let record = ABAddressBookGetPersonWithRecordID(addressBook, recordid)
            
            var personRef:ABRecordRef = Unmanaged<NSObject>.fromOpaque(record.toOpaque()).takeUnretainedValue() as ABRecordRef
            
            let firstName = ABRecordCopyValue(personRef, kABPersonFirstNameProperty).takeRetainedValue() as String
            
            let lastName  = ABRecordCopyValue(personRef, kABPersonLastNameProperty).takeRetainedValue() as String
            
            personName = firstName + " " + lastName
        } else {
            NSLog("Cannot find record")
        }
        
        var permissions = fetchGroupPermissions(group)
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        var lastContactDate:NSDate = fetchLastContactDate(contact, permissions: permissions)
        
        var lastContactText = "\(formatter.stringFromDate(lastContactDate))"
        
        // This is set in the retrieving query if no history is found
        if lastContactDate == contact.anchordate {
            lastContactText = "(Never)"
        }
        
        var daysFromLastContactDate:Int = dateToDays(lastContactDate)
    
        var contactItem:ContactInfo = ContactInfo.init(personName: personName, lastContactDate: lastContactText, daysLastContacted: daysFromLastContactDate)
        
        return contactItem
    }
    
    func fetchLastContactDate(contact: Contact, permissions: [String]) -> NSDate {
        let fetchRequest = NSFetchRequest(entityName: "History")
        
        if contains(permissions,"call") {
            fetchRequest.predicate = NSPredicate(format: "type == %@", "call")
        }
        
        if contains(permissions,"text") {
            fetchRequest.predicate = NSPredicate(format: "type == %@", "text")
        }
        
        if contains(permissions,"facetime") {
            fetchRequest.predicate = NSPredicate(format: "type == %@", "facetime")
        }
        
        fetchRequest.predicate = NSPredicate(format: "contactRel == %@", contact)
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.fetchLimit = 1
        
        var lastContactedDate = contact.anchordate
        
        if let fetchresult = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [History] {
            if fetchresult.isEmpty == false {
                lastContactedDate = fetchresult[0].date
            }
        }
        
        return lastContactedDate
    }
    
    func fetchGroupPermissions(group: Group) -> [String] {
        
        var permissions = [String]()
    
        if group.watchcalls {
            permissions.append("call")
        }
            
        if group.watchtexts {
            permissions.append("text")
        }
            
        if group.watchfacetimes {
            permissions.append("facetime")
        }

        return permissions
    }
    
    func dateToDays(date: NSDate) -> Int{
        let currentDate = NSDate()
        
        let cal = NSCalendar.currentCalendar()
        
        let unit:NSCalendarUnit = .DayCalendarUnit
        
        let days = cal.components(unit, fromDate: date, toDate: currentDate, options: nil)
        
        return days.day
    }
    
    //Contact Person ActionSheet Menu
    func contactPersonMenu(contact: Contact, permissions: [String]) {
        let alertController = UIAlertController(title: nil, message: "How would you like to contact this person?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        if contains(permissions,"call") {
            let PhoneAction = UIAlertAction(title: "Phone", style: .Default) { (action) in
            // ...
            }
            alertController.addAction(PhoneAction)
        }
        
        if contains(permissions,"text") {
            let TextAction = UIAlertAction(title: "Text Message", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(TextAction)
        }
        
        if contains(permissions,"facetime") {
            let FacetimeAction = UIAlertAction(title: "Facetime", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(FacetimeAction)
        }
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addGroupSegue" {
            var createGroupViewController = segue.destinationViewController as CreateGroupViewController
            
            if editingGroup {
                createGroupViewController.isEditing = true
                createGroupViewController.groupObjectID = selectedGroup
            } else {
                createGroupViewController.isEditing = false
            }
        }
    }
}
