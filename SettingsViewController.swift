//
//  SettingsViewController.swift
//  scan4PASE
//
//  Created by Dhruv Sringari on 4/4/15.
//  Copyright (c) 2015 Sringari Worldwide. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet var taxField: UITextField!
    @IBOutlet var iboSwitch: UISwitch!
    @IBOutlet var cFPField: UITextField!
    @IBOutlet var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get the settings from the app
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        // store all the items from the app
        let tax : String = defaults.stringForKey("taxPref")! // defined in app delegate
        let email : String? = defaults.stringForKey("iboEmail")
        let ibo: Bool = defaults.boolForKey("iboOrCustomer") // defined in app delegate
        let cFP : String = defaults.stringForKey("cFP")! // defined in app delegate
        // Set the tax fields
        taxField.text = tax
        if (ibo) {
            iboSwitch.setOn(true, animated: false)
        } else {
            iboSwitch.setOn(false, animated: false)
        }
        
        emailField.text = email
        cFPField.text = cFP
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func save(sender: AnyObject) {
        let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let tax : String? = taxField.text
        let email : String? = emailField.text
        let ibo : Bool = iboSwitch.on
        let cFP : String? = cFPField.text
        
        if ((tax!).characters.count == 0) {
            tax == "0"
        }
        if ((cFP!).characters.count == 0){
            cFP == "0"
        }
        
        defaults.setObject(tax!, forKey: "taxPref")
        defaults.setObject(cFP!, forKey: "cFP")
        defaults.setObject(ibo, forKey:"iboOrCustomer")
        defaults.setObject(email, forKey:"iboEmail")
        let alert: UIAlertView = UIAlertView(title: "Saved", message: "Settings Saved", delegate: self, cancelButtonTitle: "Ok")
        alert.show()
    }
    @IBAction func dismissKeyboard(sender: AnyObject) {
        resignFirstResponder()
    }

   
    @IBAction func resetProducts(sender: AnyObject) {
        let alert: UIAlertView = UIAlertView(title: "Reset?", message: "This will reset standard products.", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
        alert.show()
        
    }
    @IBAction func resetAllProducts(sender: AnyObject) {
        let alert: UIAlertView = UIAlertView(title: "Reset All?", message: "This will reset all products including custom ones", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
        alert.show()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView.title == "Saved" {
            navigationController?.popViewControllerAnimated(true)
        } else if (alertView.title == "Reset?" && buttonIndex == 1) {
            let del = ITAppDelegate()
            del.resetCoreDataAndCustom(false)
            navigationController?.popViewControllerAnimated(true)
        } else if (alertView.title == "Reset All?" && buttonIndex == 1) {
            let del = ITAppDelegate()
            del.resetCoreDataAndCustom(true)
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
