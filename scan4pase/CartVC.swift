//
//  CartVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/5/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit
import MagicalRecord

class CartVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet var addButton: UIBarButtonItem!

	@IBOutlet var cart: UITableView!
	@IBOutlet var pvBVTotal: UILabel!
	@IBOutlet var subtotal: UILabel!
	@IBOutlet var grandTotal: UILabel!

	@IBOutlet var pvBVLabel: UILabel!
	@IBOutlet var subtotalLabel: UILabel!
	@IBOutlet var grandTotalLabel: UILabel!
	@IBOutlet var checkout: UIButton!

	var cartProducts: [CartProduct] = []

	var selectedCartProduct: CartProduct?

	override func viewDidLoad() {
		super.viewDidLoad()
		cart.delegate = self
		cart.dataSource = self
		// Do any additional setup after loading the view.
		ProductService.importProducts({ _, _ in
			dispatch_async(dispatch_get_main_queue(), {
				self.reloadCart()
				let alert = UIAlertController(title: "Done", message: "", preferredStyle: .Alert)
				alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
			})
		})

		navigationItem.leftBarButtonItem = editButtonItem()
	}

	func calculateTotals() {
		let roundUP = NSDecimalNumberHandler(roundingMode: .RoundPlain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
		var pvTotal: NSDecimalNumber = 0
		var bvTotal: NSDecimalNumber = 0
		var retailCostSubtotal: NSDecimalNumber = 0
		var iboCostSubtotal: NSDecimalNumber = 0
		var quantityTotal: NSDecimalNumber = 0

		for cartProduct in cartProducts {
			let product = cartProduct.product!
			let quantity = NSDecimalNumber(decimal: cartProduct.quantity!.decimalValue)

			quantityTotal = quantityTotal.decimalNumberByAdding(quantity)

			let qPV = product.pv!.decimalNumberByMultiplyingBy(quantity, withBehavior: roundUP)
			let qBV = product.bv!.decimalNumberByMultiplyingBy(quantity, withBehavior: roundUP)
			let qRetailCost = product.retailCost!.decimalNumberByMultiplyingBy(quantity, withBehavior: roundUP)
			let qIboCost = product.iboCost!.decimalNumberByMultiplyingBy(quantity, withBehavior: roundUP)

			pvTotal = pvTotal.decimalNumberByAdding(qPV, withBehavior: roundUP)
			bvTotal = bvTotal.decimalNumberByAdding(qBV, withBehavior: roundUP)
			retailCostSubtotal = retailCostSubtotal.decimalNumberByAdding(qRetailCost, withBehavior: roundUP)
			iboCostSubtotal = iboCostSubtotal.decimalNumberByAdding(qIboCost, withBehavior: roundUP)
		}

		title = "Cart(\(quantityTotal.stringValue))"

		UIView.animateWithDuration(0.3, animations: {
			var formatter = NSNumberFormatter()
			formatter.numberStyle = .CurrencyStyle

			self.subtotal.text = formatter.stringFromNumber(iboCostSubtotal)! + " / " + formatter.stringFromNumber(retailCostSubtotal)!

			formatter = NSNumberFormatter()
			formatter.numberStyle = .DecimalStyle
			formatter.minimumIntegerDigits = 1
			formatter.maximumFractionDigits = 2
			formatter.minimumFractionDigits = 2
			self.pvBVTotal.text = formatter.stringFromNumber(pvTotal)! + " / " + formatter.stringFromNumber(bvTotal)!
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
			// Display a message when the table is empty
			let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
			label.text = "No products in cart."
			label.textColor = UIColor(red: 38, green: 184, blue: 151)
			label.numberOfLines = 0
			label.textAlignment = .Center
			label.font = UIFont.systemFontOfSize(20)
			label.sizeToFit()

			cart.backgroundView = label
			cart.separatorStyle = .None
			hide()
			return 1
		}
		cart.backgroundView = nil
		cart.separatorStyle = .SingleLine
		show()
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cartProducts.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		if let cell = tableView.dequeueReusableCellWithIdentifier("cartCell") as? CartCell {
			let cartProduct = cartProducts[indexPath.row]
			if let product = cartProduct.product {
				let formatter = NSNumberFormatter()
				formatter.maximumFractionDigits = 2
				formatter.minimumFractionDigits = 2
				formatter.minimumIntegerDigits = 1
				cell.name.text = product.name
				cell.sku.text = product.sku
				cell.pvBV.text = formatter.stringFromNumber(product.pv!)! + "/" + formatter.stringFromNumber(product.bv!)!
				formatter.numberStyle = .CurrencyStyle
				cell.retailCost.text = formatter.stringFromNumber(product.retailCost!)
				cell.iboCost.text = formatter.stringFromNumber(product.iboCost!)
				if product.custom!.boolValue {
					cell.sku.textColor = UIColor(red: 97, green: 188, blue: 109)
				}
				cell.quantity.text = cartProduct.quantity?.stringValue
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

	func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
		if (cart.editing) {
			return UITableViewCellEditingStyle.Delete
		}
		return UITableViewCellEditingStyle.None
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

	func clearCart() {
		let alert = UIAlertController(title: "Empty Cart", message: "This will delete all of the products in the cart.", preferredStyle: .ActionSheet)

		let delete = UIAlertAction(title: "Delete All", style: .Destructive, handler: { _ in
			for cartProduct in self.cartProducts {
				self.cartProducts.removeObject(cartProduct)
				cartProduct.MR_deleteEntity()
			}
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            self.reloadCart()
            self.setEditing(false, animated: true)
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
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
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
		}
	}

}
