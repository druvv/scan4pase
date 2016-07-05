//
//  ProductService.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/5/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import Foundation
import Alamofire
import MagicalRecord
import FirebaseStorage

class ProductService {
	class func importProducts(completion: (Bool, NSError?) -> Void) {
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory = paths[0]
		let filePath = documentsDirectory + "/products.csv"

		let storage = FIRStorage.storage()
		let storageRef = storage.referenceForURL("gs://project-2924719563810163534.appspot.com/")
		let fileRef = storageRef.child("products.csv")

		if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
			fileRef.writeToFile(NSURL(fileURLWithPath: filePath), completion: { URL, error in
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
			fileRef.writeToFile(NSURL(fileURLWithPath: filePath), completion: { URL, error in
				if (error != nil) {
					completion(false, error)
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

	private class func parseProducts() throws {
		let moc = NSManagedObjectContext.MR_defaultContext()
		Product.MR_deleteAllMatchingPredicate(NSPredicate(format: "custom != TRUE", argumentArray: nil), inContext: moc)
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = documentsDirectory + "/products.csv"
        
        let fileString = try NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        let lineArray = fileString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())


		for line in lineArray {
			let components = line.componentsSeparatedByString(";")

			let sku = components[0]
			let name = components[1]
			let pv = components[2]
			let bv = components[3]
			let iboPrice = components[4]
			let retailPrice = components[5]

			if let product = Product.MR_createEntityInContext(moc) {
				product.sku = sku
				product.name = name
				product.pv = NSDecimalNumber(string: pv)
				product.bv = NSDecimalNumber(string: bv)
				product.iboCost = NSDecimalNumber(string: iboPrice)
				product.retailCost = NSDecimalNumber(string: retailPrice)
				product.custom = NSNumber(bool: false)

			}
		}

		moc.MR_saveToPersistentStoreAndWait()
	}
}
