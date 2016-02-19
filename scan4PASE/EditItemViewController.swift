//
//  EditItemViewController.swift
//  scan4PASE
//
//  Created by Dhruv Sringari on 3/16/15.
//  Copyright (c) 2015 Sringari Worldwide. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class EditItemViewController: UIViewController, UIAlertViewDelegate {
    var product : NSDictionary?
    // if the view has been instantiated to edit a product
    var edit : Bool = false
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var skuField: UITextField!
    @IBOutlet var pvField: UITextField!
    @IBOutlet var bvField: UITextField!
    @IBOutlet var retailCostField: UITextField!
    @IBOutlet var iboCostField: UITextField!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    // simple return if cancel
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion:nil);
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        resignFirstResponder()
    }
    
    @IBAction func saveEdit(sender: AnyObject) {
        let allProducts: NSArray = ITData.getAllProducts()
        
        // checks if any of the textfields have invalid characters
        var b: Bool = true
        if hasAlphaCharacters(pvField.text!) || hasAlphaCharacters(bvField.text!) || hasAlphaCharacters(retailCostField.text!) || hasAlphaCharacters(iboCostField.text!) {
            b = false
        }
        
        if (nameField.text!.characters.count > 0 && skuField.text!.characters.count > 0 && pvField.text!.characters.count > 0 && bvField.text!.characters.count > 0  && retailCostField.text!.characters.count > 0 && iboCostField.text!.characters.count > 0 && b) {
            
            // get delegate and create the MOC
            let del = ITAppDelegate();
            let moc = del.managedObjectContext;
            // store the currencies/data into decimal numbers
            let pv = NSDecimalNumber(string: pvField.text)
            let bv = NSDecimalNumber(string: bvField.text)
            let retailCost = NSDecimalNumber(string: retailCostField.text)
            let iboCost = NSDecimalNumber(string: iboCostField.text)
            
            let customNum: NSNumber = NSNumber(bool: true)
            
            if (edit) {
                // get the product from the database
                let entityDesc : NSEntityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: moc)!
                let mo: NSManagedObject = NSManagedObject(entity: entityDesc, insertIntoManagedObjectContext: moc)
                
                // New Sku when editing is C + Sku
                let newSku : String = "c" + skuField.text!
                let filtered = allProducts.filteredArrayUsingPredicate(NSPredicate(format: "sku == %@", newSku))
                
                if (filtered.count == 0) {
                    // Edit the changed fields
                    mo.setValue(nameField.text, forKey: "name")
                    mo.setValue(newSku, forKey: "sku")
                    mo.setValue(pv, forKey: "pv")
                    mo.setValue(bv, forKey: "bv")
                    mo.setValue(retailCost, forKey:"retailCost")
                    mo.setValue(iboCost, forKey:"iboCost")
                    mo.setValue(customNum, forKey: "custom")
                } else {
                    let alert = UIAlertView(title: "Duplicate SKU!", message: "Please choose a different sku!", delegate: nil, cancelButtonTitle: "Ok")
                    alert.show()
                }
                
                
            } else {
                
                // Get the Name and SKU
                let name: String = nameField.text!
                let sku: String = skuField.text!
                
                let filtered = allProducts.filteredArrayUsingPredicate(NSPredicate(format: "sku == %@", sku))
                
                if (filtered.count == 0) {
                    // We need an Entity Description for the Managed Object!
                    let entityDesc : NSEntityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext:moc)!
                    // Create MO
                    let newProduct : NSManagedObject = NSManagedObject(entity: entityDesc, insertIntoManagedObjectContext: moc)
                    // Set Values
                    newProduct.setValue(name, forKey: "name")
                    newProduct.setValue(sku, forKey: "sku")
                    newProduct.setValue(pv, forKey: "pv")
                    newProduct.setValue(bv, forKey: "bv")
                    newProduct.setValue(retailCost, forKey: "retailCost")
                    newProduct.setValue(iboCost, forKey: "iboCost")
                    newProduct.setValue(customNum, forKey: "custom")
                } else {
                    let alert = UIAlertView(title: "Duplicate SKU!", message: "Please choose a different sku!", delegate: nil, cancelButtonTitle: "Ok")
                    alert.show()
                }
                
            }
            
            // Save the Context
            do {
                try moc.save()
            } catch {
                
            }
            dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            let alert = UIAlertView(title: "Not Saved", message: "Check the Entries", delegate: nil, cancelButtonTitle:"Ok")
            alert.show()
        }
        
    }
    
    func hasAlphaCharacters(s: String) -> Bool {
        // Need to convert to NSstring to use rangOfCharacterFromSet()
        let string1: NSString = s as NSString
        // Create a list and flip it to all other characters
        var list: NSCharacterSet = NSCharacterSet(charactersInString:"1234567890.")
        list = list.invertedSet
        // if the string has any of the denied characters then return true
        if (string1.rangeOfCharacterFromSet(list).location != NSNotFound) {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func deleteProduct(sender: AnyObject) {
        if (edit) {
            let alert = UIAlertView(title: "Delete?", message: "Are you sure you want to delete this product?", delegate: self, cancelButtonTitle: "No", otherButtonTitles:"Yes")
            alert.show()
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView.title == "Delete?" && buttonIndex == 1 {
            // Create Delegate and Load MOC
            let del = ITAppDelegate()
            let moc = del.managedObjectContext
            // Get Managed Object from the Database
            let mo: NSManagedObject = ITData.getMOForSku(product!.valueForKey("sku") as! String, withMOC: moc)
            // Use the MOC to delete the MO
            moc.deleteObject(mo)
            do {
                // Save Database
                try moc.save()
            } catch _ {
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (edit) {
            // we don't want to allow editing of custom products only deletion
            if (product!.valueForKey("custom") as! Bool) {
                nameField.enabled = false
                nameField.textColor = UIColor.lightGrayColor()
                skuField.enabled = false
                skuField.textColor = UIColor.lightGrayColor()
                pvField.enabled = false
                pvField.textColor = UIColor.lightGrayColor()
                bvField.enabled = false
                bvField.textColor = UIColor.lightGrayColor()
                retailCostField.enabled = false
                retailCostField.textColor = UIColor.lightGrayColor()
                iboCostField.enabled = false
                iboCostField.textColor = UIColor.lightGrayColor()
                saveButton.hidden = true
            }
            
            nameField.text = product!.valueForKey("name") as? String
            skuField.text = product!.valueForKey("sku") as? String
            
            // Have to Convert to Decimal Number because the values are stored as them
            let pv = product!.valueForKey("pv")as! NSDecimalNumber
            let bv = product!.valueForKey("bv")as! NSDecimalNumber
            let retailCost = product!.valueForKey("retailCost")as! NSDecimalNumber
            let iboCost = product!.valueForKey("iboCost")as! NSDecimalNumber
            
            pvField.text = pv.stringValue
            bvField.text = bv.stringValue
            retailCostField.text = retailCost.stringValue
            iboCostField.text = iboCost.stringValue
            
            // Problems Occur Without this
           // nameField.enabled = false
            //skuField.enabled = false
            
            if (product!.valueForKey("custom") as! Bool == false) {
                deleteButton.hidden = true
            }
            
            
        } else {
            deleteButton.hidden = true
        }
        
        
        
        
        
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
