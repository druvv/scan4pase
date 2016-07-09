//
//  InvoiceVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/7/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit

class InvoiceVC: UIViewController {
    
    @IBOutlet var textview: UITextView!
    var paymentMethod: PaymentMethod = .Cash
    var paid: Bool = true
    var name: String!
    var iboNumber: String!
    var checkNumber: String!
    var otherMethodName: String!
    var invoiceText: NSMutableAttributedString = NSMutableAttributedString(string: "")
    var subject: String = ""
    var cartDelegate: CartVCDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        buildText()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismissKeyboard))
        let flexibleWidth = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        keyboardDoneButtonView.items = [flexibleWidth,doneButton]
        textview.inputAccessoryView = keyboardDoneButtonView
        
    }
    
    func buildText() {
        
        // Justifications Config
        let paragraphCenter = NSMutableParagraphStyle()
        paragraphCenter.alignment = .Center
        let paragraphRight = NSMutableParagraphStyle()
        paragraphRight.alignment = .Right
        // Styles
        let fontSize: CGFloat = 15
        let bold = [NSFontAttributeName: UIFont.boldSystemFontOfSize(fontSize), NSForegroundColorAttributeName: UIColor.blackColor()]
        let boldBlue = [NSFontAttributeName: UIFont.boldSystemFontOfSize(fontSize), NSForegroundColorAttributeName: UIColor(red: 43, green: 130, blue: 201)]
        let normal = [NSFontAttributeName: UIFont.systemFontOfSize(fontSize), NSForegroundColorAttributeName: UIColor.blackColor()]
        let normalRight = [NSFontAttributeName: UIFont.systemFontOfSize(fontSize), NSForegroundColorAttributeName: UIColor.blackColor(),  NSParagraphStyleAttributeName: paragraphRight]
        
        subject = "scan4pase - Invoice - \(name)"
        
        // Identification
        invoiceText += NSMutableAttributedString(string: "Identification\n", attributes: boldBlue)
        invoiceText += NSMutableAttributedString(string: "Payee: ", attributes: bold) + NSMutableAttributedString(string: name + "\n", attributes: normal)
        invoiceText += NSMutableAttributedString(string: "IBO Number: ", attributes: bold) + NSMutableAttributedString(string: iboNumber + "\n", attributes: normal)
        
        // Payment Details
        invoiceText += NSMutableAttributedString(string: "Payment Details\n", attributes: boldBlue)
        invoiceText += NSMutableAttributedString(string: "Paid: ", attributes: bold) + NSMutableAttributedString(string: (paid ? "Yes" : "No") + "\n", attributes: normal)
        if paid {
            invoiceText += NSMutableAttributedString(string: "Payment Method: ", attributes: bold)
            switch paymentMethod {
            case PaymentMethod.Cash:
                invoiceText += NSMutableAttributedString(string: "Cash\n", attributes: normal)
            case PaymentMethod.Check:
                invoiceText += NSMutableAttributedString(string: "Check\n", attributes: normal)
                invoiceText += NSMutableAttributedString(string:"Check Number: ", attributes: bold) + NSMutableAttributedString(string: checkNumber + "\n", attributes: normal)
            case PaymentMethod.CreditCard:
                invoiceText += NSMutableAttributedString(string:"Credit Card\n", attributes: normal)
            case PaymentMethod.Other:
                invoiceText += NSMutableAttributedString(string: otherMethodName + "\n", attributes:  normal)
            }
        }
        
        // Order Details
        let pointFormatter = NSNumberFormatter()
        pointFormatter.numberStyle = .DecimalStyle
        pointFormatter.maximumFractionDigits = 2
        pointFormatter.minimumIntegerDigits = 1
        pointFormatter.minimumFractionDigits = 2
        
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.numberStyle = .CurrencyStyle
        
        invoiceText += NSMutableAttributedString(string: "Order Details\n", attributes: boldBlue)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a EEE MMMM d, yy"
        invoiceText += NSMutableAttributedString(string: "Date: ", attributes: bold)
            + NSMutableAttributedString(string: dateFormatter.stringFromDate(NSDate()) + "\n", attributes: normal)
        
        let pvBVAttributedText = NSMutableAttributedString(string: "PV/BV Total: ",  attributes: bold)
        invoiceText += pvBVAttributedText
            + NSMutableAttributedString(string: pointFormatter.stringFromNumber(cartDelegate.pvTotal)! + " / " + pointFormatter.stringFromNumber(cartDelegate.bvTotal)! + "\n", attributes: normalRight)
        
        let subtotalAttributedText = NSMutableAttributedString(string: "Subtotal (IBO / Retail): ", attributes: bold)
        invoiceText += subtotalAttributedText
            + NSMutableAttributedString(string: currencyFormatter.stringFromNumber(cartDelegate.iboCostSubtotal)! + " / " + currencyFormatter.stringFromNumber(cartDelegate.retailCostSubtotal)! + "\n",attributes: normalRight)
        
        let grandTotalAttributedText = NSMutableAttributedString(string: "Grand Total (IBO / Retail): ", attributes: bold)
        invoiceText += grandTotalAttributedText
            + NSMutableAttributedString(string: currencyFormatter.stringFromNumber(cartDelegate.iboCostGrandTotal)! + " / " + currencyFormatter.stringFromNumber(cartDelegate.retailCostGrandTotal)! + "\n", attributes: normalRight)
        
        if paymentMethod == .CreditCard {
            if let tax = NSUserDefaults.standardUserDefaults().objectForKey("creditCardFeePercentage") as? NSNumber {
                var tax = NSDecimalNumber(decimal: tax.decimalValue)
                tax = tax.decimalNumberByMultiplyingByPowerOf10(-2)
                tax = tax.decimalNumberByAdding(1)
                
                let roundUP = NSDecimalNumberHandler(roundingMode: .RoundPlain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
                let iboGrandTotalWithFee = cartDelegate.iboCostGrandTotal.decimalNumberByMultiplyingBy(tax, withBehavior: roundUP)
                let retailGrandTotalWithFee = cartDelegate.retailCostGrandTotal.decimalNumberByMultiplyingBy(tax, withBehavior: roundUP)
                
                let iboGrandTotalWithFeeAttributedText = NSMutableAttributedString(string: "Grand Total w/ CC Fee (IBO / Retail): ", attributes: bold)
                invoiceText += iboGrandTotalWithFeeAttributedText
                    + NSMutableAttributedString(string: currencyFormatter.stringFromNumber(iboGrandTotalWithFee)! + " / " + currencyFormatter.stringFromNumber(retailGrandTotalWithFee)! + "\n", attributes: normalRight)
            }
        }
        
        // Purchased Items
        invoiceText += NSMutableAttributedString(string: "Purchased Items (\(cartDelegate.quantityTotal.stringValue))\n", attributes: boldBlue)
        
        if let cartProducts = CartProduct.MR_findAll() as? [CartProduct] {
            for cartProduct in cartProducts {
                invoiceText += NSMutableAttributedString(string: "\(cartProduct.product!.sku!) \(cartProduct.product!.custom!.boolValue ? "Custom" : "") (\(cartProduct.quantity!.stringValue))", attributes: boldBlue)
                invoiceText += NSMutableAttributedString(string: " - \(cartProduct.product!.name!)\n", attributes: normal)
            }
        }
        
        textview.attributedText = invoiceText
    }
    @IBAction func shareInvoice(sender: AnyObject) {
        let invoice = Invoice(subject: subject, message: invoiceText)
        let activityViewController = UIActivityViewController(activityItems: [invoice], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {_, completed, _, _ in
            if (completed) {
                self.performSegueWithIdentifier("exit", sender: self)
            }
        }
        presentViewController(activityViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
