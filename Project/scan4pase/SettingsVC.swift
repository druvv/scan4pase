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
	@IBOutlet var creditCardFeePercentage: UITextField!

	lazy var formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimumIntegerDigits = 1
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2
		return formatter
	}()

	override func viewDidLoad() {

		super.viewDidLoad()
		taxPercentage.delegate = self
        creditCardFeePercentage.delegate = self
		tableView.delegate = self
		tableView.dataSource = self

		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tap.cancelsTouchesInView = false
		tableView.addGestureRecognizer(tap)

		if let num = UserDefaults.standard.object(forKey: "taxPercentage") as? NSNumber {
			taxPercentage.text = formatter.string(from: num)
		}

		if let num = UserDefaults.standard.object(forKey: "creditCardFeePercentage") as? NSNumber {
			creditCardFeePercentage.text = formatter.string(from: num)
		}

		let keyboardDoneButtonView = UIToolbar()
		keyboardDoneButtonView.sizeToFit()
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
		let flexibleWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

		keyboardDoneButtonView.items = [flexibleWidth, doneButton]
		taxPercentage.inputAccessoryView = keyboardDoneButtonView
        creditCardFeePercentage.inputAccessoryView = keyboardDoneButtonView
	}

	func showError() {
		let alert = UIAlertController(title: "Error!", message: "Invalid Entry!", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		if (textField == taxPercentage) {
			if let num = formatter.number(from: textField.text!) {
				if num.doubleValue < 100 && num.doubleValue > 0 {
					UserDefaults.standard.set(num, forKey: "taxPercentage")
					textField.text = formatter.string(from: num)
					NotificationCenter.default.post(name: Notification.Name(rawValue: "settingsUpdated"), object: self)
				} else {
					showError()
				}
			} else {
				showError()
			}
        } else {
            if let num = formatter.number(from: textField.text!) {
                if num.doubleValue < 100 && num.doubleValue > 0 {
                    UserDefaults.standard.set(num, forKey: "creditCardFeePercentage")
                    textField.text = formatter.string(from: num)
                } else {
                    showError()
                }
            } else {
                showError()
            }
        }
	}
}
