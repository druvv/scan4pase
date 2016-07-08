//
//  Product+CoreDataProperties.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/5/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Product {

    @NSManaged var name: String?
    @NSManaged var sku: String?
    @NSManaged var pv: NSDecimalNumber?
    @NSManaged var bv: NSDecimalNumber?
    @NSManaged var iboCost: NSDecimalNumber?
    @NSManaged var retailCost: NSDecimalNumber?
    @NSManaged var custom: NSNumber?
    @NSManaged var cartProduct: CartProduct?

}
