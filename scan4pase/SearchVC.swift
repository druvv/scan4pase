//
//  SearchVC.swift
//  
//
//  Created by Dhruv Sringari on 7/5/16.
//
//

import UIKit

class SearchVC: UITableViewController, UISearchResultsUpdating {
    var products: [Product]?
    var customProducts: [Product]?
    var filteredCustomProducts: [Product]?
    var filteredProducts: [Product]?
    let searchController = UISearchController(searchResultsController: nil)

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
    
    func filterContentForSearchText(searchText: String) {
        filteredProducts = products?.filter({$0.name!.rangeOfString(searchText, options: [NSStringCompareOptions.CaseInsensitiveSearch]) != nil || $0.sku!.rangeOfString(searchText, options: [NSStringCompareOptions.CaseInsensitiveSearch]) != nil})
        filteredCustomProducts = customProducts?.filter({$0.name!.rangeOfString(searchText, options: [NSStringCompareOptions.CaseInsensitiveSearch]) != nil || $0.sku!.rangeOfString(searchText, options: [NSStringCompareOptions.CaseInsensitiveSearch]) != nil})
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text!)
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        resignFirstResponder()
        tableView.reloadData()
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
            let formatter = NSNumberFormatter()
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            formatter.minimumIntegerDigits = 1
            cell.name.text = product.name
            cell.sku.text = product.sku!
            cell.pvBV.text = formatter.stringFromNumber(product.pv!)! + "/" + formatter.stringFromNumber(product.bv!)!
            formatter.numberStyle = .CurrencyStyle
            cell.retailCost.text = formatter.stringFromNumber(product.retailCost!)
            cell.iboCost.text = formatter.stringFromNumber(product.iboCost!)
            if product.custom!.boolValue {
                cell.sku.textColor = UIColor(red: 38, green: 184, blue: 151)
            }
            return cell
        }

        return UITableViewCell()
    }


}
