//
//  EditProductVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/8/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit
import MagicalRecord

class EditProductVC: UITableViewController, UITextFieldDelegate {
	@IBOutlet var name: UITextField!
	@IBOutlet var sku: UITextField!
	@IBOutlet var pv: UITextField!
	@IBOutlet var bv: UITextField!
	@IBOutlet var retailCost: UITextField!
	@IBOutlet var iboCost: UITextField!

	var product: Product?

	lazy var currencyFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		return formatter
	}()

	lazy var decimalFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimumIntegerDigits = 1
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2
		return formatter
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

        pv.delegate = self
        bv.delegate = self
        iboCost.delegate = self
        retailCost.delegate = self

        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        keyboardDoneButtonView.items = [flexibleWidth, doneButton]
        name.inputAccessoryView = keyboardDoneButtonView
        sku.inputAccessoryView = keyboardDoneButtonView
        pv.inputAccessoryView = keyboardDoneButtonView
        bv.inputAccessoryView = keyboardDoneButtonView
        iboCost.inputAccessoryView = keyboardDoneButtonView
        retailCost.inputAccessoryView = keyboardDoneButtonView

		if let product = product {
			name.text = product.name
			sku.text = product.sku
			pv.text = decimalFormatter.string(from: product.pv!)
			bv.text = decimalFormatter.string(from: product.bv!)
			retailCost.text = currencyFormatter.string(from: product.retailCost!)
			iboCost.text = currencyFormatter.string(from: product.iboCost!)
            title = "Edit Product"
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func showInvalidError() {
		let alert = UIAlertController(title: "Invalid Entry", message: "Enter a valid value.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
	}

	func showEmptyError() {
		let alert = UIAlertController(title: "Invalid Entries", message: "All fields must have a value.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
	}

	func validateNumber(_ number: NSNumber) -> Bool {
		if number.doubleValue >= 0 {
			return true
		} else {
			showInvalidError()
			return false
		}
	}

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let num = decimalFormatter.number(from: textField.text!) {
            if validateNumber(num) {
                if textField == iboCost || textField == retailCost {
                    textField.text = currencyFormatter.string(from: num)
                } else {
                    textField.text = decimalFormatter.string(from: num)
                }
            } else {
                showInvalidError()
                textField.text = ""
            }
        } else {
            textField.text = ""
            showInvalidError()
        }
    }

	func validateAllEntries() -> Bool {
		return name.text != "" && sku.text != "" && pv.text != "" && bv.text != "" && retailCost.text != "" && iboCost.text != ""
	}

	@IBAction func save(_ sender: AnyObject) {
		if validateAllEntries() {

            // If we have a custom product edit its values, if we have a standard product create a custom product, and if we have no product create it
            let newProduct: Product
            if let product = self.product, product.custom!.boolValue {
                newProduct = product
            } else {
                newProduct = Product.mr_createEntity()!
            }

			newProduct.name = name.text
			newProduct.sku = sku.text
			newProduct.pv = NSDecimalNumber(decimal: decimalFormatter.number(from: pv.text!)!.decimalValue)
			newProduct.bv = NSDecimalNumber(decimal: decimalFormatter.number(from: bv.text!)!.decimalValue)
			newProduct.retailCost = NSDecimalNumber(decimal: currencyFormatter.number(from: retailCost.text!)!.decimalValue)
			newProduct.iboCost = NSDecimalNumber(decimal: currencyFormatter.number(from: iboCost.text!)!.decimalValue)
            newProduct.custom = NSNumber(value: true as Bool)
			NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
			_ = navigationController?.popViewController(animated: true)

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
