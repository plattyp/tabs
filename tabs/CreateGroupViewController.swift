//
//  CreateGroupViewController.swift
//  tabs
//
//  Created by Andrew Platkin on 2/18/15.
//  Copyright (c) 2015 PlattypusLabs. All rights reserved.
//

import UIKit
import CoreData

class CreateGroupViewController: UIViewController {

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
    
    @IBAction func createGroupButton(sender: AnyObject) {
        
        var days = Int(round(daysWatchedSlider.value))
        
        Group.createInManagedObjectContext(managedObjectContext!, name: groupNameInput.text, dayswatched: days, watchtexts: textMessagesToggle.enabled, watchcalls: phoneCallToggle.enabled, watchfacetimes: facetimesToggle.enabled)
        
        save()
        
        performSegueWithIdentifier("createToMainSegue", sender: nil)
        
    }
    
    @IBAction func sliderChanged(sender: AnyObject) {
        var days = daysWatchedSlider.value
        var daysrounded = round(days)
        
        daysWatchedSlider.setValue(daysrounded, animated: true)
        
        var suffix:String = "days"
        
        if daysrounded == 1 {
            suffix = "day"
        }
        
        daysWatchedLabel.text = "\(Int(daysrounded)) \(suffix)"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        daysWatchedLabel.text = "30 days"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

}
