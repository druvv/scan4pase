//
//  ProductService.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/5/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import Foundation
import MagicalRecord
import FirebaseStorage

class ProductService {
	class func importProducts(_ completion: @escaping (Bool, NSError?) -> Void) {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let documentsDirectory = paths[0]
		let filePath = documentsDirectory + "/products.csv"

		let storage = FIRStorage.storage()
		let storageRef = storage.reference(forURL: "gs://project-2924719563810163534.appspot.com/")
		let fileRef = storageRef.child("products.csv")
        
        storage.maxDownloadRetryTime = 5
        storage.maxOperationRetryTime = 5

		if FileManager.default.fileExists(atPath: filePath) {
			fileRef.write(toFile: URL(fileURLWithPath: filePath), completion: { URL, error in
				if (error != nil) {
					completion(true, nil)
				} else {
					do {
						try parseProducts()
					} catch let error as NSError {
						completion(false, error)
					}
					completion(true, nil)
				}
			})
		} else {
			fileRef.write(toFile: URL(fileURLWithPath: filePath), completion: { URL, error in
				if (error != nil) {
					completion(false, error as NSError?)
				} else {
                    do {
                        try parseProducts()
                    } catch let error as NSError {
                        completion(false, error)
                    }
					completion(true, nil)
				}
			})
		}
	}

	fileprivate class func parseProducts() throws {
		let moc = NSManagedObjectContext.mr_default()
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = documentsDirectory + "/products.csv"
        
        let fileString = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue)
        let lineArray = fileString.components(separatedBy: CharacterSet.newlines)
        
        var productsToDelete = Product.mr_find(byAttribute: "custom", withValue: false) as! [Product]


		for line in lineArray {
			let components = line.components(separatedBy: ";")

			let sku = components[0]
			let name = components[1]
			let pv = components[2]
			let bv = components[3]
			let iboPrice = components[4]
			let retailPrice = components[5]
            
            let product: Product
            
            if let p = productsToDelete.filter({$0.custom!.boolValue != true && $0.sku == sku}).first {
                product = p
                productsToDelete.removeObject(p)
            } else {
                product = Product.mr_createEntity(in: moc)!
            }
            
            product.sku = sku
            product.name = name
            product.pv = NSDecimalNumber(string: pv)
            product.bv = NSDecimalNumber(string: bv)
            product.iboCost = NSDecimalNumber(string: iboPrice)
            product.retailCost = NSDecimalNumber(string: retailPrice)
            product.custom = NSNumber(value: false as Bool)
		}
        
        for product in productsToDelete {
            product.mr_deleteEntity()
        }

		moc.mr_saveToPersistentStoreAndWait()
	}
}
