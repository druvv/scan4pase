//
//  Invoice.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/7/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit

class Invoice: NSObject, UIActivityItemSource {
    let subject: String
    let message: NSAttributedString

    init(subject: String, message: NSAttributedString) {
        self.subject = subject
        self.message = message
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return message
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        return message
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return subject
    }
}
