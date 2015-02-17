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
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    var groups = [1,2,3]
    var rowHeight = 53.0
    var viewOverheadHeight = 35.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set the navigation bar
        self.title = "Your Tabs"
        var refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshCells")
        navigationItem.leftBarButtonItem = refreshButton
        
        //Other Properties
        self.view.backgroundColor = UIColor.lightGrayColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Used to redraw the cells
    func refreshCells() {
        println("Cells being refreshed!")
    }
    
    //Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var myCell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("viewCell", forIndexPath: indexPath) as UITableViewCell
        
        var myView = myCell.contentView.viewWithTag(10) as ContactTable
        
        myView.groupName = String(groups[indexPath.row])
        
        return myCell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var group = groups[indexPath.row]
        
        var rows = groupContactsCount(group)
        
        var totalRowHeight = rowHeight * Double(rows)
        
        var totalHeight:CGFloat = CGFloat(totalRowHeight + viewOverheadHeight)
        
        return totalHeight
    }
    
    func groupContactsCount(group: Int) -> Int {
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        
        // Create a sort descriptor object that sorts on the "timerName"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "recordid", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var contacts = [Contact]()
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Contact] {
            contacts = fetchResults
        }
        
        return contacts.count
    }
}
