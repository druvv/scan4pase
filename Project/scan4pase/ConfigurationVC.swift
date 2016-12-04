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
    case cash
    case check
    case creditCard
    case other
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
		reloadData(animated: false)
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
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

	@IBAction func paidChanged(_ sender: AnyObject) {
		if paid.selectedSegmentIndex == 0 {
			hideAllMethodCells()
            cell(methodCell, setHidden: false)
            hideOrShowDependingOnMethod()
        } else {
            hideAllPaymentCells()
        }
        
        reloadData(animated: false)
        
	}

	@IBAction func methodChanged(_ sender: AnyObject) {
        hideOrShowDependingOnMethod()
        reloadData(animated: false)
	}
    
    @IBAction func somethingChanged(_ sender: AnyObject) {
        finshButton.isEnabled = entriesValid()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "invoice" {
            let invoiceVC = segue.destination as! InvoiceVC
            invoiceVC.cartDelegate = cartDelegate
            invoiceVC.name = name.text
            invoiceVC.iboNumber = iboNumber.text
            invoiceVC.checkNumber = checkNumber.text
            invoiceVC.otherMethodName = otherMethodName.text
            invoiceVC.paid = paid.selectedSegmentIndex == 0
            switch method.selectedSegmentIndex {
            case 0:
                invoiceVC.paymentMethod = PaymentMethod.cash
            case 1:
                invoiceVC.paymentMethod = PaymentMethod.check
            case 2:
                invoiceVC.paymentMethod = PaymentMethod.creditCard
            case 3:
                invoiceVC.paymentMethod = PaymentMethod.other
            default:
                break
            }
        }
    }
    
}
