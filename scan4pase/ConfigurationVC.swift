//
//  ConfigurationVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/6/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit
import StaticDataTableViewController

enum PaymentMethod {
    case Cash
    case Check
    case CreditCard
    case Other
}

class ConfigurationVC: StaticDataTableViewController {
	@IBOutlet var name: UITextField!
	@IBOutlet var iboNumber: UITextField!

	@IBOutlet var paid: UISegmentedControl!
	@IBOutlet var method: UISegmentedControl!

	@IBOutlet var methodCell: UITableViewCell!
	@IBOutlet var checkNumberCell: UITableViewCell!
	@IBOutlet var otherMethodNameCell: UITableViewCell!

	@IBOutlet var checkNumber: UITextField!
	@IBOutlet var otherMethodName: UITextField!

    @IBOutlet var finshButton: UIBarButtonItem!
    
    var cartDelegate: CartVCDelegate!
	override func viewDidLoad() {
		super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
		cell(methodCell, setHidden: true)
		cell(checkNumberCell, setHidden: true)
		cell(otherMethodNameCell, setHidden: true)
        hideSectionsWithHiddenRows = true
		reloadDataAnimated(false)
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismissKeyboard))
        let flexibleWidth = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        keyboardDoneButtonView.items = [flexibleWidth,doneButton]
        name.inputAccessoryView = keyboardDoneButtonView
        iboNumber.inputAccessoryView = keyboardDoneButtonView
        checkNumber.inputAccessoryView = keyboardDoneButtonView
        otherMethodName.inputAccessoryView = keyboardDoneButtonView
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    func entriesValid() -> Bool {
        var entriesValid = true
        
        entriesValid = name.text != ""
        entriesValid = iboNumber.text != ""
        
        if paid.selectedSegmentIndex == 0 {
            switch method.selectedSegmentIndex {
            case 1:
                entriesValid = checkNumber.text != ""
            case 3:
                entriesValid = otherMethodName.text != ""
            default:
                break
            }
        }
        
        return entriesValid
    }


	func hideOrShowDependingOnMethod() {
		switch method.selectedSegmentIndex {
		case 0:
			hideAllMethodCells()
		case 1:
			hideAllMethodCells()
			cell(checkNumberCell, setHidden: false)
		case 2:
			hideAllMethodCells()
		case 3:
			hideAllMethodCells()
			cell(otherMethodNameCell, setHidden: false)
		default:
			hideAllMethodCells()
		}
	}
    
    func hideAllPaymentCells() {
        cell(checkNumberCell, setHidden: true)
        cell(otherMethodNameCell, setHidden: true)
        cell(methodCell, setHidden: true)
    }

	func hideAllMethodCells() {
		cell(checkNumberCell, setHidden: true)
		cell(otherMethodNameCell, setHidden: true)
	}

	@IBAction func paidChanged(sender: AnyObject) {
		if paid.selectedSegmentIndex == 0 {
			hideAllMethodCells()
            cell(methodCell, setHidden: false)
            hideOrShowDependingOnMethod()
        } else {
            hideAllPaymentCells()
        }
        
        reloadDataAnimated(false)
        
	}

	@IBAction func methodChanged(sender: AnyObject) {
        hideOrShowDependingOnMethod()
        reloadDataAnimated(false)
	}
    
    @IBAction func somethingChanged(sender: AnyObject) {
        finshButton.enabled = entriesValid()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "invoice" {
            let invoiceVC = segue.destinationViewController as! InvoiceVC
            invoiceVC.cartDelegate = cartDelegate
            invoiceVC.name = name.text
            invoiceVC.iboNumber = iboNumber.text
            invoiceVC.checkNumber = checkNumber.text
            invoiceVC.otherMethodName = otherMethodName.text
            invoiceVC.paid = paid.selectedSegmentIndex == 0
            switch method.selectedSegmentIndex {
            case 0:
                invoiceVC.paymentMethod = PaymentMethod.Cash
            case 1:
                invoiceVC.paymentMethod = PaymentMethod.Check
            case 2:
                invoiceVC.paymentMethod = PaymentMethod.CreditCard
            case 3:
                invoiceVC.paymentMethod = PaymentMethod.Other
            default:
                break
            }
        }
    }
    
}
