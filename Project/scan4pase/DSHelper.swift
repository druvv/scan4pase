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
	mutating func removeObject(_ object: Element) {
		if let index = self.index(of: object) {
			self.remove(at: index)
		}
	}

	// Removes a set of objects from a swift array
	mutating func removeObjectsInArray(_ array: [Element]) {
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
	func getObjectInArray(_ predicateString: String, args: [AnyObject]?) -> AnyObject? {
		let predicate = NSPredicate(format: predicateString, argumentArray: args)
		let result = self.filtered(using: predicate)
		if result.count == 0 {
			return nil
		} else if result.count > 1 {
			print("Wanted one object got multiple returning nil")
			return nil
		}
		return result[0] as AnyObject?
	}

	class func getObjectsInArray(_ predicateString: String, args: [AnyObject]?, array: NSArray) -> [AnyObject] {
		let predicate = NSPredicate(format: predicateString, argumentArray: args)
		let result = array.filtered(using: predicate)
		if result.count == 0 {
			return []
		}
		return result as [AnyObject]
	}

}

extension Collection where Indices.Iterator.Element == Index {
	/// Returns the element at the specified index iff it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Iterator.Element? {
		return indices.contains(index) ? self[index] : nil
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
		if let rootController = UIApplication.shared.keyWindow?.rootViewController {

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

		if let navigationController = UIApplication.shared.keyWindow?.rootViewController {

			return navigationController as? UINavigationController
		}
		return nil
	}
}

extension UIView {
	func snapshot() -> UIImage {
		UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
		drawHierarchy(in: bounds, afterScreenUpdates: true)
		let result = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return result!
	}
}

extension UITableViewCell {
	func removeMargins() {

		if self.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
			self.separatorInset = UIEdgeInsets.zero
		}

		if self.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
			self.preservesSuperviewLayoutMargins = false
		}

		if self.responds(to: #selector(setter: UIView.layoutMargins)) {
			self.layoutMargins = UIEdgeInsets.zero
		}
	}
}

func relativeDateStringForDate(_ date: Date) -> String {
	let components = (Calendar.current as NSCalendar).components([.day, .month, .year], from: date, to: Date(), options: [])

	if (components.year! > 0) {
		if (components.year == 1) {
			return String(format: "%ld year ago", arguments: [components.month!])
		}
		return String(format: "%ld years ago", arguments: [components.year!])
	} else if (components.month! > 0) {
		if (components.month == 1) {
			return String(format: "%ld month ago", arguments: [components.month!])
		}
		return String(format: "%ld months ago", arguments: [components.month!])
	} else if (components.day! > 0) {
		if (components.day! > 1) {
			return String(format: "%ld days ago", arguments: [components.day!])
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

func +=(lhs: NSMutableAttributedString, rhs: NSAttributedString) {
    lhs.append(rhs)
}

func +(lhs: NSMutableAttributedString, rhs: NSMutableAttributedString) -> NSMutableAttributedString {
    let returnString = NSMutableAttributedString(attributedString: lhs)
    returnString.append(rhs)
    return returnString
}
