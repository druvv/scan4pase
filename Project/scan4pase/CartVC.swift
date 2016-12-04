//
//  CartVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/5/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit
import MagicalRecord
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


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

		navigationItem.leftBarButtonItem = editButtonItem

		NotificationCenter.default.addObserver(self, selector: #selector(calculateTotals), name: NSNotification.Name(rawValue: "settingsUpdated"), object: nil)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	func loadProducts() {
		startLoadingAnimation()
		UIApplication.shared.beginIgnoringInteractionEvents()
		ProductService.importProducts({ successful, error in
			DispatchQueue.main.async(execute: {
				UIApplication.shared.endIgnoringInteractionEvents()
				if (!successful) {
					self.activitiyIndicator.stopAnimating()
					let alert = UIAlertController(title: "Error!", message: "We failed to load the products. Check your connection and try again.", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [unowned self] _ in
						self.loadProducts()
						}))
					self.present(alert, animated: true, completion: nil)
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
        
		let roundUP = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)

		var retailCostTaxTotal: NSDecimalNumber = 0

		for cartProduct in cartProducts {
			let product = cartProduct.product!
			let quantity = NSDecimalNumber(decimal: cartProduct.quantity!.decimalValue)

			quantityTotal = quantityTotal.adding(quantity)

			let qPV = product.pv!.multiplying(by: quantity, withBehavior: roundUP)
			let qBV = product.bv!.multiplying(by: quantity, withBehavior: roundUP)
			let qRetailCost = product.retailCost!.multiplying(by: quantity, withBehavior: roundUP)
			let qIboCost = product.iboCost!.multiplying(by: quantity, withBehavior: roundUP)

			if let taxPercentage = UserDefaults.standard.object(forKey: "taxPercentage") as? NSNumber, cartProduct.taxable!.boolValue {
				var taxPercentage = NSDecimalNumber(decimal: taxPercentage.decimalValue)
				taxPercentage = taxPercentage.multiplying(byPowerOf10: -2, withBehavior: roundUP)

				let retailTax = qRetailCost.multiplying(by: taxPercentage, withBehavior: roundUP)

				retailCostTaxTotal = retailCostTaxTotal.adding(retailTax, withBehavior: roundUP)
			}

			pvTotal = pvTotal.adding(qPV, withBehavior: roundUP)
			bvTotal = bvTotal.adding(qBV, withBehavior: roundUP)
			retailCostSubtotal = retailCostSubtotal.adding(qRetailCost, withBehavior: roundUP)
			iboCostSubtotal = iboCostSubtotal.adding(qIboCost, withBehavior: roundUP)
		}

		retailCostGrandTotal = retailCostSubtotal.adding(retailCostTaxTotal, withBehavior: roundUP)
		iboCostGrandTotal = iboCostSubtotal.adding(retailCostTaxTotal, withBehavior: roundUP)

		navigationController?.navigationBar.topItem?.title = "Cart(\(quantityTotal.stringValue))"

		UIView.animate(withDuration: 0.3, animations: {
			var formatter = NumberFormatter()
			formatter.numberStyle = .currency

			self.subtotal.text = formatter.string(from: self.iboCostSubtotal)! + " / " + formatter.string(from: self.retailCostSubtotal)!
			self.grandTotal.text = formatter.string(from: self.iboCostGrandTotal)! + " / " + formatter.string(from: self.retailCostGrandTotal)!
			formatter = NumberFormatter()
			formatter.numberStyle = .decimal
			formatter.minimumIntegerDigits = 1
			formatter.maximumFractionDigits = 2
			formatter.minimumFractionDigits = 2
			self.pvBVTotal.text = formatter.string(from: self.pvTotal)! + " / " + formatter.string(from: self.bvTotal)!
		})
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func reloadCart() {
		self.cartProducts = CartProduct.mr_findAll() as! [CartProduct]
		cartProducts.sort(by: { $0.product!.sku < $1.product!.sku })
		calculateTotals()
		cart.reloadSections(IndexSet(integer: 0), with: .automatic)
	}

	override func viewDidAppear(_ animated: Bool) {
		reloadCart()
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 84
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		if cartProducts.count == 0 {
			showEmptyCart()
			return 1
		}
		hideBackgroundCartView()
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cartProducts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell") as? CartCell {
			let cartProduct = cartProducts[indexPath.row]
			if cartProduct.product != nil {
				cell.load(withCartProduct: cartProduct)
			} else {
				cartProduct.mr_deleteEntity()
				NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
			}
			return cell
		}

		return UITableViewCell()

	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		cart.setEditing(editing, animated: true)

		if cart.isEditing {
			let emptyButton = UIBarButtonItem(title: "Empty Cart", style: .plain, target: self, action: #selector(clearCart))
			navigationItem.rightBarButtonItem = emptyButton
		} else {
			navigationItem.rightBarButtonItem = addButton
		}
	}
    
    func addProduct() {
        performSegue(withIdentifier: "selectItem", sender: self)
    }

	func clearCart() {
		let alert = UIAlertController(title: "Empty Cart", message: "This will delete all of the products in the cart.", preferredStyle: .actionSheet)

		let delete = UIAlertAction(title: "Delete All", style: .destructive, handler: { _ in
			for cartProduct in self.cartProducts {
				self.cartProducts.removeObject(cartProduct)
				cartProduct.mr_deleteEntity()
			}
			NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
			self.reloadCart()
			self.setEditing(false, animated: false)
		})
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(delete)
		alert.addAction(cancel)
		present(alert, animated: true, completion: nil)
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == UITableViewCellEditingStyle.delete) {
			let cartProduct = cartProducts[indexPath.row]
			cartProducts.remove(at: indexPath.row)
			cartProduct.mr_deleteEntity()
			NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
			tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
			calculateTotals()
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedCartProduct = cartProducts[indexPath.row]
		tableView.deselectRow(at: indexPath, animated: true)
		performSegue(withIdentifier: "editItem", sender: nil)
	}

	func hide() {
		pvBVLabel.isHidden = true
		subtotalLabel.isHidden = true
		grandTotalLabel.isHidden = true
		pvBVTotal.isHidden = true
		subtotal.isHidden = true
		grandTotal.isHidden = true
		checkout.isHidden = true
	}

	func show() {
		pvBVLabel.isHidden = false
		subtotalLabel.isHidden = false
		grandTotalLabel.isHidden = false
		pvBVTotal.isHidden = false
		subtotal.isHidden = false
		grandTotal.isHidden = false
		checkout.isHidden = false
	}

	func showEmptyCart() {
		// Display a message when the table is empty

		let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
		label.text = "No products in cart."
		label.textColor = UIColor(red: 43, green: 130, blue: 201)
		label.numberOfLines = 0
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 20)
		label.sizeToFit()

		cart.backgroundView = label
		cart.separatorStyle = .none
		hide()

	}

	func hideBackgroundCartView() {
		cart.backgroundView = nil
		cart.separatorStyle = .singleLine
		show()
	}

	func startLoadingAnimation() {
		loadingView.alpha = 1
		loadingView.isHidden = false
		activitiyIndicator.startAnimating()
	}

	func stopLoadingAnimation() {
		loadingView.alpha = 1
		UIView.animate(withDuration: 0.3, animations: {
			self.loadingView.alpha = 0
		})
		loadingView.isHidden = true
		activitiyIndicator.stopAnimating()
	}

	@IBAction func checkout(_ sender: AnyObject) {
	}

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let backItem = UIBarButtonItem()
		backItem.title = "Cart"
		navigationItem.backBarButtonItem = backItem

		if segue.identifier == "editItem" {
			let detailVC = segue.destination as! CartProductDetailVC
			detailVC.product = selectedCartProduct?.product
			detailVC.edit = true
		} else if segue.identifier == "config" {
			let configVC = segue.destination as! ConfigurationVC
			configVC.cartDelegate = self
		}
	}

	@IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        for cartProduct in self.cartProducts {
            self.cartProducts.removeObject(cartProduct)
            cartProduct.mr_deleteEntity()
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        reloadCart()
	}

}
