//
//  SettingsVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/6/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController, UITextFieldDelegate {
	@IBOutlet var taxPercentage: UITextField!

	lazy var formatter: NSNumberFormatter = {
		let formatter = NSNumberFormatter()
		formatter.numberStyle = .DecimalStyle
		formatter.minimumIntegerDigits = 1
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2
		return formatter
	}()

	override func viewDidLoad() {
        
		super.viewDidLoad()
        taxPercentage.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)

		if let num = NSUserDefaults.standardUserDefaults().objectForKey("taxPercentage") as? NSNumber {
			taxPercentage.text = formatter.stringFromNumber(num)
		}
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismissKeyboard))
        let flexibleWidth = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        keyboardDoneButtonView.items = [flexibleWidth,doneButton]
        taxPercentage.inputAccessoryView = keyboardDoneButtonView
	}
    
    func showError() {
        let alert = UIAlertController(title: "Error!", message: "Invalid Tax Percentage", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let num = formatter.numberFromString(textField.text!) {
            if num.doubleValue < 100 && num.doubleValue > 0 {
                NSUserDefaults.standardUserDefaults().setObject(num, forKey: "taxPercentage")
                textField.text = formatter.stringFromNumber(num)
                NSNotificationCenter.defaultCenter().postNotificationName("settingsUpdated", object: self)
            } else {
                showError()
            }
        } else {
            showError()
        }
    }
}
