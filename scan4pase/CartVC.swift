//
//  CartVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/5/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit

class CartVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var cart: UITableView!
    @IBOutlet var pvBVTotal: UILabel!
    @IBOutlet var subtotal: UILabel!
    @IBOutlet var grandTotal: UILabel!
    
    @IBOutlet var pvBVLabel: UILabel!
    @IBOutlet var subtotalLabel: UILabel!
    @IBOutlet var grandTotalLabel: UILabel!
    @IBOutlet var checkout: UIButton!
    
     var cartProducts: [CartProduct]?

    override func viewDidLoad() {
        super.viewDidLoad()
        cart.delegate = self
        cart.dataSource = self
        self.cartProducts = CartProduct.MR_findAll() as! [CartProduct]?
        // Do any additional setup after loading the view.
        ProductService.importProducts({ _,_ in
            dispatch_async(dispatch_get_main_queue(), {
                self.cartProducts = CartProduct.MR_findAll() as! [CartProduct]?
                self.cart.reloadData()
                let alert = UIAlertController(title: "Done", message: "", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        })
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if cartProducts?.count == 0 || cartProducts == nil {
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
            return 0
        }
        show()
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = cartProducts?.count {
            self.navigationController?.tabBarItem.badgeValue = String(count)
            return count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("productCell") as? CartCell, let product = cartProducts?[indexPath.row].product {
            cell.name.text = product.name
            cell.sku.text = "SKU: \(product.sku)"
            cell.pvBV.text = "PV/BV: \(product.pv?.stringValue)/\(product.bv?.stringValue)"
            cell.retailCost.text = "$\(product.retailCost?.stringValue)"
            cell.iboCost.text = "$\(product.iboCost?.stringValue)"
            cell.quantity.text = cartProducts?[indexPath.row].quantity?.stringValue
            return cell
        }
        
        return UITableViewCell()
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
