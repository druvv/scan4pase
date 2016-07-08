//
//  EditProductVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/8/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit
import MagicalRecord

class EditProductVC: UITableViewController {
	@IBOutlet var name: UITextField!
	@IBOutlet var sku: UITextField!
	@IBOutlet var pv: UITextField!
	@IBOutlet var bv: UITextField!
	@IBOutlet var retailCost: UITextField!
	@IBOutlet var iboCost: UITextField!

	var product: Product?

	lazy var currencyFormatter: NSNumberFormatter = {
		let formatter = NSNumberFormatter()
		formatter.numberStyle = .CurrencyStyle
		return formatter
	}()

	lazy var decimalFormatter: NSNumberFormatter = {
		let formatter = NSNumberFormatter()
		formatter.numberStyle = .DecimalStyle
		formatter.minimumIntegerDigits = 1
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2
		return formatter
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		if let product = product {
			name.text = product.name
			sku.text = product.sku
			pv.text = decimalFormatter.stringFromNumber(product.pv!)
			bv.text = decimalFormatter.stringFromNumber(product.bv!)
			retailCost.text = currencyFormatter.stringFromNumber(product.retailCost!)
			iboCost.text = currencyFormatter.stringFromNumber(product.iboCost!)
            self.navigationController?.navigationBar.topItem?.title = "Edit Product"
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func showInvalidError() {
		let alert = UIAlertController(title: "Invalid Entry", message: "Enter a valid value.", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
		presentViewController(alert, animated: true, completion: nil)
	}

	func showEmptyError() {
		let alert = UIAlertController(title: "Invalid Entries", message: "All fields must have a value.", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
		presentViewController(alert, animated: true, completion: nil)
	}

	func validateNumber(number: NSDecimalNumber) -> Bool {
		if number.doubleValue >= 0 {
			return true
		} else {
			showInvalidError()
			return false
		}
	}

	@IBAction func checkPvBv(sender: AnyObject) {
		let textField = sender as! UITextField
		if let num = decimalFormatter.numberFromString(textField.text!) {
			let num = NSDecimalNumber(decimal: num.decimalValue)
			if !validateNumber(num) {
				textField.text = ""
			} else {
				textField.text = decimalFormatter.stringFromNumber(num)
			}
		} else {
			showInvalidError()
			textField.text = ""
		}
	}

	@IBAction func checkCosts(sender: AnyObject) {
		let textField = sender as! UITextField
		if let num = currencyFormatter.numberFromString(textField.text!) {
			let num = NSDecimalNumber(decimal: num.decimalValue)
			if !validateNumber(num) {
				textField.text = ""
			} else {
				textField.text = currencyFormatter.stringFromNumber(num)
			}
		} else {
			showInvalidError()
			textField.text = ""
		}
	}

	func validateAllEntries() -> Bool {
		return name.text != "" && sku.text != "" && pv.text != "" && bv.text != "" && retailCost != "" && iboCost != ""
	}

	@IBAction func save(sender: AnyObject) {
		if validateAllEntries() {
			if product == nil {
				product = Product.MR_createEntity()
			}
			product!.name = name.text
			product!.sku = sku.text
			product!.pv = NSDecimalNumber(decimal: decimalFormatter.numberFromString(pv.text!)!.decimalValue)
			product!.bv = NSDecimalNumber(decimal: decimalFormatter.numberFromString(bv.text!)!.decimalValue)
			product!.retailCost = NSDecimalNumber(decimal: currencyFormatter.numberFromString(retailCost.text!)!.decimalValue)
			product!.iboCost = NSDecimalNumber(decimal: currencyFormatter.numberFromString(iboCost.text!)!.decimalValue)
			NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
			navigationController?.popViewControllerAnimated(true)

		} else {
			showEmptyError()
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
