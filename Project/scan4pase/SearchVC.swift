//
//  SearchVC.swift
//  
//
//  Created by Dhruv Sringari on 7/5/16.
//
//

import UIKit
import MagicalRecord

protocol SearchVCDelegate {
    func selectProduct(forSKU sku: String)
}

class SearchVC: UITableViewController, UISearchResultsUpdating, SearchVCDelegate {
    var products: [Product]?
    var customProducts: [Product]?
    var filteredCustomProducts: [Product]?
    var filteredProducts: [Product]?
    let searchController = UISearchController(searchResultsController: nil)
    
    var selectedProduct: Product?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        products = Product.MR_findByAttribute("custom", withValue: false) as? [Product]
        customProducts = Product.MR_findByAttribute("custom", withValue: true) as? [Product]
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func selectProduct(forSKU sku: String) {
        if let product = Product.MR_findFirstWithPredicate(NSPredicate(format: "sku == %@ AND custom != TRUE", argumentArray: [sku])) {
            selectedProduct = product
            performSegueWithIdentifier("searchToDetail", sender: nil)
        }
    }
    
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
        
        filteredProducts = products?.filter{compoundNamePredicate.evaluateWithObject($0) || skuPredicate.evaluateWithObject($0)}
        filteredCustomProducts = customProducts?.filter{compoundNamePredicate.evaluateWithObject($0) || skuPredicate.evaluateWithObject($0)}
        
        
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
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {return "Custom Items"}
        if (section == 1) {return "Standard Items"}
        return ""
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 84
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if  section == 0 {
            if searchController.active && searchController.searchBar.text != "" {
                return filteredCustomProducts!.count
            }
            return customProducts!.count
        }
        
        if section == 1 {
            if searchController.active && searchController.searchBar.text != "" {
                return filteredProducts!.count
            }
            return products!.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! ProductCell
        

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
                selectedProduct = filteredCustomProducts![indexPath.row]
            } else {
                selectedProduct = customProducts![indexPath.row]
            }
            
        } else {
            if (searchController.active && searchController.searchBar.text != "") {
                selectedProduct = filteredProducts![indexPath.row]
            } else {
                selectedProduct = products![indexPath.row]
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("searchToDetail", sender: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "searchToDetail") {
            let detailVC = segue.destinationViewController as! CartProductDetailVC
            detailVC.product = selectedProduct
        } else if segue.identifier == "scanBarcode" {
            let scanVC = segue.destinationViewController as! ScanVC
            scanVC.searchDelegate = self
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }


}
