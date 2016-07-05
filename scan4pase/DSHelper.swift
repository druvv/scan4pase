//
//  DSHelper.swift
//  Grade Checker
//
//  Created by Dhruv Sringari on 4/7/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// Array Extensions
extension Array where Element: Equatable {
	// Removes an Object from a swift array
	mutating func removeObject(object: Element) {
		if let index = self.indexOf(object) {
			self.removeAtIndex(index)
		}
	}

	// Removes a set of objects from a swift array
	mutating func removeObjectsInArray(array: [Element]) {
		for object in array {
			self.removeObject(object)
		}
	}

	// Returns a random object from a swift array
	var randomObject: Element? {
		if (self.count == 0) {
			return nil
		}
		let index = Int(arc4random_uniform(UInt32(self.count)))
		return self[index]
	}
}

extension NSArray {
	func getObjectInArray(predicateString: String, args: [AnyObject]?) -> AnyObject? {
		let predicate = NSPredicate(format: predicateString, argumentArray: args)
		let result = self.filteredArrayUsingPredicate(predicate)
		if result.count == 0 {
			return nil
		} else if result.count > 1 {
			print("Wanted one object got multiple returning nil")
			return nil
		}
		return result[0]
	}

	class func getObjectsInArray(predicateString: String, args: [AnyObject]?, array: NSArray) -> [AnyObject] {
		let predicate = NSPredicate(format: predicateString, argumentArray: args)
		let result = array.filteredArrayUsingPredicate(predicate)
		if result.count == 0 {
			return []
		}
		return result
	}

}

extension CollectionType {
	/// Returns the element at the specified index iff it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Generator.Element? {
		return indices.contains(index) ? self[index]: nil
	}
}

extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
	}

	func dismissKeyboard() {
		view.endEditing(true)
	}
}

extension UIApplication {
	/// Returns the most recently presented UIViewController (visible)
	class func getCurrentViewController() -> UIViewController? {

		// If the root view is a navigation controller, we can just return the visible ViewController
		if let navigationController = getNavigationController() {

			return navigationController.visibleViewController
		}

		// Otherwise, we must get the root UIViewController and iterate through presented views
		if let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController {

			var currentController: UIViewController! = rootController

			// Each ViewController keeps track of the view it has presented, so we
			// can move from the head to the tail, which will always be the current view
			while (currentController.presentedViewController != nil) {

				currentController = currentController.presentedViewController
			}
			return currentController
		}
		return nil
	}

	/// Returns the navigation controller if it exists
	class func getNavigationController() -> UINavigationController? {

		if let navigationController = UIApplication.sharedApplication().keyWindow?.rootViewController {

			return navigationController as? UINavigationController
		}
		return nil
	}
}

extension UIView {
	func snapshot() -> UIImage {
		UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
		drawViewHierarchyInRect(bounds, afterScreenUpdates: true)
		let result = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return result
	}
}

extension UITableViewCell {
	func removeMargins() {

		if self.respondsToSelector(Selector("setSeparatorInset:")) {
			self.separatorInset = UIEdgeInsetsZero
		}

		if self.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:")) {
			self.preservesSuperviewLayoutMargins = false
		}

		if self.respondsToSelector(Selector("setLayoutMargins:")) {
			self.layoutMargins = UIEdgeInsetsZero
		}
	}
}

func relativeDateStringForDate(date: NSDate) -> String {
	let components = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: date, toDate: NSDate(), options: [])

	if (components.year > 0) {
		if (components.year == 1) {
			return String(format: "%ld year ago", arguments: [components.month])
		}
		return String(format: "%ld years ago", arguments: [components.year])
	} else if (components.month > 0) {
		if (components.month == 1) {
			return String(format: "%ld month ago", arguments: [components.month])
		}
		return String(format: "%ld months ago", arguments: [components.month])
	} else if (components.day > 0) {
		if (components.day > 1) {
			return String(format: "%ld days ago", arguments: [components.day])
		} else {
			return "Yesterday"
		}
	} else {
		return "Today"
	}
}

class EmptySegue: UIStoryboardSegue {
	override func perform() {

	}
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}
