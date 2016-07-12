//
//  CartVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/5/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit
import MagicalRecord

protocol CartVCDelegate {
	var iboCostSubtotal: NSDecimalNumber { get }
	var retailCostSubtotal: NSDecimalNumber { get }
	var iboCostGrandTotal: NSDecimalNumber { get }
	var retailCostGrandTotal: NSDecimalNumber { get }
	var pvTotal: NSDecimalNumber { get }
	var bvTotal: NSDecimalNumber { get }
    var quantityTotal: NSDecimalNumber { get }

}

class CartVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CartVCDelegate {
	@IBOutlet var addButton: UIBarButtonItem!

	@IBOutlet var cart: UITableView!
	@IBOutlet var pvBVTotal: UILabel!
	@IBOutlet var subtotal: UILabel!
	@IBOutlet var grandTotal: UILabel!

	@IBOutlet var pvBVLabel: UILabel!
	@IBOutlet var subtotalLabel: UILabel!
	@IBOutlet var grandTotalLabel: UILabel!
	@IBOutlet var checkout: UIButton!

	@IBOutlet var loadingView: UIView!
	@IBOutlet var activitiyIndicator: UIActivityIndicatorView!

	var cartProducts: [CartProduct] = []
	var selectedCartProduct: CartProduct?

	var iboCostSubtotal: NSDecimalNumber = 0
	var retailCostSubtotal: NSDecimalNumber = 0
	var iboCostGrandTotal: NSDecimalNumber = 0
	var retailCostGrandTotal: NSDecimalNumber = 0
	var pvTotal: NSDecimalNumber = 0
	var bvTotal: NSDecimalNumber = 0
    var quantityTotal: NSDecimalNumber = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		cart.delegate = self
		cart.dataSource = self
		// Do any additional setup after loading the view.
		loadProducts()

		navigationItem.leftBarButtonItem = editButtonItem()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(calculateTotals), name: "settingsUpdated", object: nil)
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	func loadProducts() {
		startLoadingAnimation()
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
		ProductService.importProducts({ successful, error in
			dispatch_async(dispatch_get_main_queue(), {
				UIApplication.sharedApplication().endIgnoringInteractionEvents()
				if (!successful) {
					self.activitiyIndicator.stopAnimating()
					let alert = UIAlertController(title: "Error!", message: "We failed to load the products. Check your connection and try again.", preferredStyle: .Alert)
					alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { [unowned self] _ in
						self.loadProducts()
						}))
					self.presentViewController(alert, animated: true, completion: nil)
				} else {
					self.stopLoadingAnimation()
					self.reloadCart()
				}

			})
		})
	}

	func resetTotals() {
		iboCostSubtotal = 0
		retailCostSubtotal = 0
		iboCostGrandTotal  = 0
		retailCostGrandTotal  = 0
		pvTotal = 0
        bvTotal = 0
        quantityTotal = 0

	}

	func calculateTotals() {
        resetTotals()
        
		let roundUP = NSDecimalNumberHandler(roundingMode: .RoundPlain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)

		var retailCostTaxTotal: NSDecimalNumber = 0

		for cartProduct in cartProducts {
			let product = cartProduct.product!
			let quantity = NSDecimalNumber(decimal: cartProduct.quantity!.decimalValue)

			quantityTotal = quantityTotal.decimalNumberByAdding(quantity)

			let qPV = product.pv!.decimalNumberByMultiplyingBy(quantity, withBehavior: roundUP)
			let qBV = product.bv!.decimalNumberByMultiplyingBy(quantity, withBehavior: roundUP)
			let qRetailCost = product.retailCost!.decimalNumberByMultiplyingBy(quantity, withBehavior: roundUP)
			let qIboCost = product.iboCost!.decimalNumberByMultiplyingBy(quantity, withBehavior: roundUP)

			if let taxPercentage = NSUserDefaults.standardUserDefaults().objectForKey("taxPercentage") as? NSNumber where cartProduct.taxable!.boolValue {
				var taxPercentage = NSDecimalNumber(decimal: taxPercentage.decimalValue)
				taxPercentage = taxPercentage.decimalNumberByMultiplyingByPowerOf10(-2, withBehavior: roundUP)

				let retailTax = qRetailCost.decimalNumberByMultiplyingBy(taxPercentage, withBehavior: roundUP)

				retailCostTaxTotal = retailCostTaxTotal.decimalNumberByAdding(retailTax, withBehavior: roundUP)
			}

			pvTotal = pvTotal.decimalNumberByAdding(qPV, withBehavior: roundUP)
			bvTotal = bvTotal.decimalNumberByAdding(qBV, withBehavior: roundUP)
			retailCostSubtotal = retailCostSubtotal.decimalNumberByAdding(qRetailCost, withBehavior: roundUP)
			iboCostSubtotal = iboCostSubtotal.decimalNumberByAdding(qIboCost, withBehavior: roundUP)
		}

		retailCostGrandTotal = retailCostSubtotal.decimalNumberByAdding(retailCostTaxTotal, withBehavior: roundUP)
		iboCostGrandTotal = iboCostSubtotal.decimalNumberByAdding(retailCostTaxTotal, withBehavior: roundUP)

		navigationController?.navigationBar.topItem?.title = "Cart(\(quantityTotal.stringValue))"

		UIView.animateWithDuration(0.3, animations: {
			var formatter = NSNumberFormatter()
			formatter.numberStyle = .CurrencyStyle

			self.subtotal.text = formatter.stringFromNumber(self.iboCostSubtotal)! + " / " + formatter.stringFromNumber(self.retailCostSubtotal)!
			self.grandTotal.text = formatter.stringFromNumber(self.iboCostGrandTotal)! + " / " + formatter.stringFromNumber(self.retailCostGrandTotal)!
			formatter = NSNumberFormatter()
			formatter.numberStyle = .DecimalStyle
			formatter.minimumIntegerDigits = 1
			formatter.maximumFractionDigits = 2
			formatter.minimumFractionDigits = 2
			self.pvBVTotal.text = formatter.stringFromNumber(self.pvTotal)! + " / " + formatter.stringFromNumber(self.bvTotal)!
		})
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func reloadCart() {
		self.cartProducts = CartProduct.MR_findAll() as! [CartProduct]
		cartProducts.sortInPlace({ $0.product!.sku < $1.product!.sku })
		calculateTotals()
		cart.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
	}

	override func viewDidAppear(animated: Bool) {
		reloadCart()
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 84
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if cartProducts.count == 0 {
			showEmptyCart()
			return 1
		}
		hideBackgroundCartView()
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cartProducts.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		if let cell = tableView.dequeueReusableCellWithIdentifier("cartCell") as? CartCell {
			let cartProduct = cartProducts[indexPath.row]
			if cartProduct.product != nil {
				cell.load(withCartProduct: cartProduct)
			} else {
				cartProduct.MR_deleteEntity()
				NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
			}
			return cell
		}

		return UITableViewCell()

	}

	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}

	override func setEditing(editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		cart.setEditing(editing, animated: true)

		if cart.editing {
			let emptyButton = UIBarButtonItem(title: "Empty Cart", style: .Plain, target: self, action: #selector(clearCart))
			navigationItem.rightBarButtonItem = emptyButton
		} else {
			navigationItem.rightBarButtonItem = addButton
		}
	}
    
    func addProduct() {
        performSegueWithIdentifier("selectItem", sender: self)
    }

	func clearCart() {
		let alert = UIAlertController(title: "Empty Cart", message: "This will delete all of the products in the cart.", preferredStyle: .ActionSheet)

		let delete = UIAlertAction(title: "Delete All", style: .Destructive, handler: { _ in
			for cartProduct in self.cartProducts {
				self.cartProducts.removeObject(cartProduct)
				cartProduct.MR_deleteEntity()
			}
			NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
			self.reloadCart()
			self.setEditing(false, animated: false)
		})
		let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		alert.addAction(delete)
		alert.addAction(cancel)
		presentViewController(alert, animated: true, completion: nil)
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if (editingStyle == UITableViewCellEditingStyle.Delete) {
			let cartProduct = cartProducts[indexPath.row]
			cartProducts.removeAtIndex(indexPath.row)
			cartProduct.MR_deleteEntity()
			NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
			calculateTotals()
		}
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		selectedCartProduct = cartProducts[indexPath.row]
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		performSegueWithIdentifier("editItem", sender: nil)
	}

	func hide() {
		pvBVLabel.hidden = true
		subtotalLabel.hidden = true
		grandTotalLabel.hidden = true
		pvBVTotal.hidden = true
		subtotal.hidden = true
		grandTotal.hidden = true
		checkout.hidden = true
	}

	func show() {
		pvBVLabel.hidden = false
		subtotalLabel.hidden = false
		grandTotalLabel.hidden = false
		pvBVTotal.hidden = false
		subtotal.hidden = false
		grandTotal.hidden = false
		checkout.hidden = false
	}

	func showEmptyCart() {
		// Display a message when the table is empty

		let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
		label.text = "No products in cart."
		label.textColor = UIColor(red: 43, green: 130, blue: 201)
		label.numberOfLines = 0
		label.textAlignment = .Center
		label.font = UIFont.systemFontOfSize(20)
		label.sizeToFit()

		cart.backgroundView = label
		cart.separatorStyle = .None
		hide()

	}

	func hideBackgroundCartView() {
		cart.backgroundView = nil
		cart.separatorStyle = .SingleLine
		show()
	}

	func startLoadingAnimation() {
		loadingView.alpha = 1
		loadingView.hidden = false
		activitiyIndicator.startAnimating()
	}

	func stopLoadingAnimation() {
		loadingView.alpha = 1
		UIView.animateWithDuration(0.3, animations: {
			self.loadingView.alpha = 0
		})
		loadingView.hidden = true
		activitiyIndicator.stopAnimating()
	}

	@IBAction func checkout(sender: AnyObject) {
	}

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let backItem = UIBarButtonItem()
		backItem.title = "Cart"
		navigationItem.backBarButtonItem = backItem

		if segue.identifier == "editItem" {
			let detailVC = segue.destinationViewController as! CartProductDetailVC
			detailVC.product = selectedCartProduct?.product
			detailVC.edit = true
		} else if segue.identifier == "config" {
			let configVC = segue.destinationViewController as! ConfigurationVC
			configVC.cartDelegate = self
		}
	}

	@IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        for cartProduct in self.cartProducts {
            self.cartProducts.removeObject(cartProduct)
            cartProduct.MR_deleteEntity()
        }
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        reloadCart()
	}

}
