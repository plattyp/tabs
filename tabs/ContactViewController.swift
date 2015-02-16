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
    
    var groups = ["Group 1","Group 2","Group 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Your Tabs"
        var refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshCells")
        navigationItem.leftBarButtonItem = refreshButton
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
        
        myView.groupName = groups[indexPath.row]
        
        return myCell
        
    }

}
