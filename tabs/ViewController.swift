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

class ViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate {

    @IBAction func addContactButton(sender: AnyObject) {
        checkAddressBookPermissions()
        peoplePicker()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            var addressBook:ABAddressBookRef?
            
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

