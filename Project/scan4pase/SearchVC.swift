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
        
        products = Product.mr_find(byAttribute: "custom", withValue: false) as? [Product]
        customProducts = Product.mr_find(byAttribute: "custom", withValue: true) as? [Product]
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = []
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func selectProduct(forSKU sku: String) {
        if let product = Product.mr_findFirst(with: NSPredicate(format: "sku == %@ AND custom != TRUE", argumentArray: [sku])) {
            selectedProduct = product
            performSegue(withIdentifier: "searchToDetail", sender: nil)
        }
    }
    
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
        
        filteredProducts = products?.filter{compoundNamePredicate.evaluate(with: $0) || skuPredicate.evaluate(with: $0)}
        filteredCustomProducts = customProducts?.filter{compoundNamePredicate.evaluate(with: $0) || skuPredicate.evaluate(with: $0)}
        
        
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
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {return "Custom Items"}
        if (section == 1) {return "Standard Items"}
        return ""
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if  section == 0 {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredCustomProducts!.count
            }
            return customProducts!.count
        }
        
        if section == 1 {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredProducts!.count
            }
            return products!.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductCell
        

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
                selectedProduct = filteredCustomProducts![indexPath.row]
            } else {
                selectedProduct = customProducts![indexPath.row]
            }
            
        } else {
            if (searchController.isActive && searchController.searchBar.text != "") {
                selectedProduct = filteredProducts![indexPath.row]
            } else {
                selectedProduct = products![indexPath.row]
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "searchToDetail", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "searchToDetail") {
            let detailVC = segue.destination as! CartProductDetailVC
            detailVC.product = selectedProduct
        } else if segue.identifier == "scanBarcode" {
            let scanVC = segue.destination as! ScanVC
            scanVC.searchDelegate = self
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }


}
