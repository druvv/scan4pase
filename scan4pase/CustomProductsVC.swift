//
//  CustomProductsVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/7/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit
import MagicalRecord

class CustomProductsVC: UITableViewController, UISearchResultsUpdating {
    
    var products: [Product] = []
    var customProducts: [Product] = []
    var filteredCustomProducts: [Product] = []
    var filteredProducts: [Product] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    var selectedProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        products = Product.MR_findByAttribute("custom", withValue: false) as! [Product]
        customProducts = Product.MR_findByAttribute("custom", withValue: true) as! [Product]
        
        let editButton = editButtonItem()
        editButton.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = editButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        customProducts = Product.MR_findByAttribute("custom", withValue: true) as! [Product]
        tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0,2)), withRowAnimation: .Automatic)
    }
    
    // MARK: - Table view data source
    
    func filterContentForSearchText(searchText: String) {
        var words = searchText.componentsSeparatedByString(" ")
        
        words = words.filter{$0 != ""}
        
        var namePredicates: [NSPredicate] = []
        for word in words {
            let predicate = NSPredicate(format: "name CONTAINS[c] %@", argumentArray: [word])
            namePredicates.append(predicate)
        }
        let compoundNamePredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: namePredicates)
        
        let skuPredicate = NSPredicate(format: "sku CONTAINS[c] %@", argumentArray: [searchText])
        
        filteredProducts = products.filter{compoundNamePredicate.evaluateWithObject($0) || skuPredicate.evaluateWithObject($0)}
        filteredCustomProducts = customProducts.filter{compoundNamePredicate.evaluateWithObject($0) || skuPredicate.evaluateWithObject($0)}
        
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        resignFirstResponder()
        tableView.reloadData()
    }
    
    deinit{
        searchController.view.superview?.removeFromSuperview()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 84
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {return "Custom Items"}
        if (section == 1) {return "Standard Items"}
        return ""
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if  section == 0 {
            if searchController.active && searchController.searchBar.text != "" {
                return filteredCustomProducts.count
            }
            return customProducts.count
        }
        
        if section == 1 {
            if searchController.active && searchController.searchBar.text != "" {
                return filteredProducts.count
            }
            return products.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("customProductCell", forIndexPath: indexPath) as! ProductCell
        
        
        // Configure the cell...
        let currentProducts: [Product]?
        if (indexPath.section == 0) {
            if (searchController.active && searchController.searchBar.text != "") {
                currentProducts = filteredCustomProducts
            } else {
                currentProducts = customProducts
            }
            
        } else {
            if (searchController.active && searchController.searchBar.text != "") {
                currentProducts = filteredProducts
            } else {
                currentProducts = products
            }
        }
        
        if let product = currentProducts?[indexPath.row] {
            cell.load(withProduct: product)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            if (searchController.active && searchController.searchBar.text != "") {
                selectedProduct = filteredCustomProducts[indexPath.row]
            } else {
                selectedProduct = customProducts[indexPath.row]
            }
            
        } else {
            if (searchController.active && searchController.searchBar.text != "") {
                selectedProduct = filteredProducts[indexPath.row]
            } else {
                selectedProduct = products[indexPath.row]
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("editProduct", sender: nil)
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let currentProduct: Product
            if (searchController.active && searchController.searchBar.text != "") {
                currentProduct = filteredCustomProducts[indexPath.row]
                filteredCustomProducts.removeAtIndex(indexPath.row)
            } else {
                currentProduct = customProducts[indexPath.row]
                customProducts.removeAtIndex(indexPath.row)
            }
            currentProduct.MR_deleteEntity()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        if segue.identifier == "editProduct" {
            if let product = selectedProduct {
                let editVC = segue.destinationViewController as! EditProductVC
                editVC.product = product
                selectedProduct = nil
            }
        }
    }
    

}
