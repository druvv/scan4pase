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
        searchController.searchBar.scopeButtonTitles = []
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        products = Product.mr_find(byAttribute: "custom", withValue: false) as! [Product]
        customProducts = Product.mr_find(byAttribute: "custom", withValue: true) as! [Product]
        
        let editButton = editButtonItem
        editButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = editButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customProducts = Product.mr_find(byAttribute: "custom", withValue: true) as! [Product]
        tableView.reloadSections(IndexSet(integersIn: NSMakeRange(0,2).toRange()!), with: .automatic)
    }
    
    // MARK: - Table view data source
    
    func filterContentForSearchText(_ searchText: String) {
        var words = searchText.components(separatedBy: " ")
        
        words = words.filter{$0 != ""}
        
        var namePredicates: [NSPredicate] = []
        for word in words {
            let predicate = NSPredicate(format: "name CONTAINS[c] %@", argumentArray: [word])
            namePredicates.append(predicate)
        }
        let compoundNamePredicate = NSCompoundPredicate(type: .and, subpredicates: namePredicates)
        
        let skuPredicate = NSPredicate(format: "sku CONTAINS[c] %@", argumentArray: [searchText])
        
        filteredProducts = products.filter{compoundNamePredicate.evaluate(with: $0) || skuPredicate.evaluate(with: $0)}
        filteredCustomProducts = customProducts.filter{compoundNamePredicate.evaluate(with: $0) || skuPredicate.evaluate(with: $0)}
        
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        resignFirstResponder()
        tableView.reloadData()
    }
    
    deinit{
        searchController.view.superview?.removeFromSuperview()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {return "Custom Items"}
        if (section == 1) {return "Standard Items"}
        return ""
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if  section == 0 {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredCustomProducts.count
            }
            return customProducts.count
        }
        
        if section == 1 {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredProducts.count
            }
            return products.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customProductCell", for: indexPath) as! ProductCell
        
        
        // Configure the cell...
        let currentProducts: [Product]?
        if (indexPath.section == 0) {
            if (searchController.isActive && searchController.searchBar.text != "") {
                currentProducts = filteredCustomProducts
            } else {
                currentProducts = customProducts
            }
            
        } else {
            if (searchController.isActive && searchController.searchBar.text != "") {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            if (searchController.isActive && searchController.searchBar.text != "") {
                selectedProduct = filteredCustomProducts[indexPath.row]
            } else {
                selectedProduct = customProducts[indexPath.row]
            }
            
        } else {
            if (searchController.isActive && searchController.searchBar.text != "") {
                selectedProduct = filteredProducts[indexPath.row]
            } else {
                selectedProduct = products[indexPath.row]
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "editProduct", sender: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentProduct: Product
            if (searchController.isActive && searchController.searchBar.text != "") {
                currentProduct = filteredCustomProducts[indexPath.row]
                filteredCustomProducts.remove(at: indexPath.row)
            } else {
                currentProduct = customProducts[indexPath.row]
                customProducts.remove(at: indexPath.row)
            }
            currentProduct.mr_deleteEntity()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        if segue.identifier == "editProduct" {
            if let product = selectedProduct {
                let editVC = segue.destination as! EditProductVC
                editVC.product = product
                selectedProduct = nil
            }
        }
    }
    

}
