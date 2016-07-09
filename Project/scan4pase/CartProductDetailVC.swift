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
    private var cartProduct: CartProduct!
    var edit = false
    var saved = false
    
    enum ValidationError: ErrorType {
        case QuantityZero
        case QuantityInvalid
        case QuantityNone
    }
    
    
    lazy var formatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    let moc = NSManagedObjectContext.MR_defaultContext()

	override func viewDidLoad() {
		super.viewDidLoad()
        
        quantity.delegate = self
        
        if let cartProduct = CartProduct.MR_findFirstByAttribute("product", withValue: product, inContext: moc) {
            self.cartProduct = cartProduct 
        } else {
            cartProduct = CartProduct.MR_createEntityInContext(moc)
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
            addtoCartButton.setTitle("Save", forState: .Normal)
        }
        
        title = product.sku
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismissKeyboard))
        let flexibleWidth = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        keyboardDoneButtonView.items = [flexibleWidth,doneButton]
        quantity.inputAccessoryView = keyboardDoneButtonView
        
	}

	@IBAction func addToCart(sender: AnyObject) {

		do {
			try validateEntries()
		} catch ValidationError.QuantityZero {
			let alert = UIAlertController(title: "Error!", message: "The quantity can not be less than or equal to zero.", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
			return

		} catch ValidationError.QuantityNone {
			let alert = UIAlertController(title: "Error!", message: "The product must have a quantity.", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
			return

		} catch ValidationError.QuantityInvalid {
			let alert = UIAlertController(title: "Error!", message: "The quantity is invalid.", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
			return
		} catch {
			let alert = UIAlertController(title: "Wow!", message: "You broke me beyond error recognition.", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
			return
		}
        
        cartProduct.quantity = NSDecimalNumber(decimal: formatter.numberFromString(quantity.text!)!.decimalValue)
		cartProduct.taxable = NSNumber(bool: taxable.selectedSegmentIndex == 0)
		moc.MR_saveToPersistentStoreAndWait()
        saved = true
        navigationController?.popToRootViewControllerAnimated(true)

	}
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController() && !saved && !edit{
            cartProduct.MR_deleteEntity()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

	func validateEntries() throws {
        
        if (quantity.text == "") {
            throw ValidationError.QuantityNone
        } else if let num = formatter.numberFromString(quantity.text!) {
            if num.doubleValue <= 0 {
                throw ValidationError.QuantityZero
            }
        } else {
            throw ValidationError.QuantityInvalid
        }
    }

    @IBAction func increase(sender: AnyObject) {
        if var num = Int(quantity.text!) {
            num += 1
            quantity.text = String(num)
        }
    }
    
    @IBAction func decrease(sender: AnyObject) {
        if var num = Int(quantity.text!) where num - 1 > 0 {
            num -= 1
            quantity.text = String(num)
        }
    }
    
    
	@IBAction func cancel(sender: AnyObject) {
		self.navigationController?.popToRootViewControllerAnimated(true)
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
