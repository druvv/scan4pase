//
//  CartProductDetailVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/5/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit
import MagicalRecord

class CartProductDetailVC: UIViewController, UITextFieldDelegate {
	@IBOutlet var name: UILabel!
	@IBOutlet var quantity: UITextField!
	@IBOutlet var taxable: UISegmentedControl!
    @IBOutlet var addtoCartButton: UIButton!

	var product: Product!
    fileprivate var cartProduct: CartProduct!
    var edit = false
    var saved = false
    
    enum ValidationError: Error {
        case quantityZero
        case quantityInvalid
        case quantityNone
    }
    
    
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    let moc = NSManagedObjectContext.mr_default()

	override func viewDidLoad() {
		super.viewDidLoad()
        
        quantity.delegate = self
        
        if let cartProduct = CartProduct.mr_findFirst(byAttribute: "product", withValue: product, in: moc) {
            self.cartProduct = cartProduct 
        } else {
            cartProduct = CartProduct.mr_createEntity(in: moc)
            cartProduct.product = product
        }
        
        hideKeyboardWhenTappedAround()

		// Do any additional setup after loading the view.
        name.text = product.name
        
        if let quantity = cartProduct.quantity {
            self.quantity.text = quantity.stringValue
            if self.quantity.text == "0" {
                self.quantity.text = "1"
            }
        }
        
        if let taxable = cartProduct.taxable {
            self.taxable.selectedSegmentIndex = taxable.boolValue ? 0 : 1
        }
        
        if edit {
            addtoCartButton.setTitle("Save", for: UIControlState())
        }
        
        title = product.sku
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        keyboardDoneButtonView.items = [flexibleWidth,doneButton]
        quantity.inputAccessoryView = keyboardDoneButtonView
        
	}

	@IBAction func addToCart(_ sender: AnyObject) {

		do {
			try validateEntries()
		} catch ValidationError.quantityZero {
			let alert = UIAlertController(title: "Error!", message: "The quantity can not be less than or equal to zero.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
			return

		} catch ValidationError.quantityNone {
			let alert = UIAlertController(title: "Error!", message: "The product must have a quantity.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
			return

		} catch ValidationError.quantityInvalid {
			let alert = UIAlertController(title: "Error!", message: "The quantity is invalid.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
			return
		} catch {
			let alert = UIAlertController(title: "Wow!", message: "You broke me beyond error recognition.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
			return
		}
        
        cartProduct.quantity = NSDecimalNumber(decimal: formatter.number(from: quantity.text!)!.decimalValue)
		cartProduct.taxable = NSNumber(value: (taxable.selectedSegmentIndex == 0) as Bool)
		moc.mr_saveToPersistentStoreAndWait()
        saved = true
        _ = navigationController?.popToRootViewController(animated: true)

	}
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController && !saved && !edit{
            cartProduct.mr_deleteEntity()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

	func validateEntries() throws {
        
        if (quantity.text == "") {
            throw ValidationError.quantityNone
        } else if let num = formatter.number(from: quantity.text!) {
            if num.doubleValue <= 0 {
                throw ValidationError.quantityZero
            }
        } else {
            throw ValidationError.quantityInvalid
        }
    }

    @IBAction func increase(_ sender: AnyObject) {
        if var num = Int(quantity.text!) {
            num += 1
            quantity.text = String(num)
        }
    }
    
    @IBAction func decrease(_ sender: AnyObject) {
        if var num = Int(quantity.text!), num - 1 > 0 {
            num -= 1
            quantity.text = String(num)
        }
    }
    
    
	@IBAction func cancel(_ sender: AnyObject) {
		_ = self.navigationController?.popToRootViewController(animated: true)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
