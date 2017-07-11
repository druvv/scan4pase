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
    var paymentMethod: PaymentMethod = .cash
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
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        keyboardDoneButtonView.items = [flexibleWidth, doneButton]
        textview.inputAccessoryView = keyboardDoneButtonView

    }

    func buildText() {

        // Justifications Config
        let paragraphCenter = NSMutableParagraphStyle()
        paragraphCenter.alignment = .center
        let paragraphRight = NSMutableParagraphStyle()
        paragraphRight.alignment = .right
        // Styles
        let fontSize: CGFloat = 15
        let bold = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize), NSAttributedStringKey.foregroundColor: UIColor.black]
        let boldBlue = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize), NSAttributedStringKey.foregroundColor: UIColor(red: 43, green: 130, blue: 201)]
        let normal = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize), NSAttributedStringKey.foregroundColor: UIColor.black]
        let normalRight = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize), NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.paragraphStyle: paragraphRight]

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
            case PaymentMethod.cash:
                invoiceText += NSMutableAttributedString(string: "Cash\n", attributes: normal)
            case PaymentMethod.check:
                invoiceText += NSMutableAttributedString(string: "Check\n", attributes: normal)
                invoiceText += NSMutableAttributedString(string:"Check Number: ", attributes: bold) + NSMutableAttributedString(string: checkNumber + "\n", attributes: normal)
            case PaymentMethod.creditCard:
                invoiceText += NSMutableAttributedString(string:"Credit Card\n", attributes: normal)
            case PaymentMethod.other:
                invoiceText += NSMutableAttributedString(string: otherMethodName + "\n", attributes:  normal)
            }
        }

        // Order Details
        let pointFormatter = NumberFormatter()
        pointFormatter.numberStyle = .decimal
        pointFormatter.maximumFractionDigits = 2
        pointFormatter.minimumIntegerDigits = 1
        pointFormatter.minimumFractionDigits = 2

        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency

        invoiceText += NSMutableAttributedString(string: "Order Details\n", attributes: boldBlue)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a EEE MMMM d, yy"
        invoiceText += NSMutableAttributedString(string: "Date: ", attributes: bold)
            + NSMutableAttributedString(string: dateFormatter.string(from: Date()) + "\n", attributes: normal)

        let pvBVAttributedText = NSMutableAttributedString(string: "PV/BV Total: ", attributes: bold)
        invoiceText += pvBVAttributedText
            + NSMutableAttributedString(string: pointFormatter.string(from: cartDelegate.pvTotal)! + " / " + pointFormatter.string(from: cartDelegate.bvTotal)! + "\n", attributes: normalRight)

        let subtotalAttributedText = NSMutableAttributedString(string: "Subtotal (IBO / Retail): ", attributes: bold)
        invoiceText += subtotalAttributedText
            + NSMutableAttributedString(string: currencyFormatter.string(from: cartDelegate.iboCostSubtotal)! + " / " + currencyFormatter.string(from: cartDelegate.retailCostSubtotal)! + "\n", attributes: normalRight)

        let grandTotalAttributedText = NSMutableAttributedString(string: "Grand Total (IBO / Retail): ", attributes: bold)
        invoiceText += grandTotalAttributedText
            + NSMutableAttributedString(string: currencyFormatter.string(from: cartDelegate.iboCostGrandTotal)! + " / " + currencyFormatter.string(from: cartDelegate.retailCostGrandTotal)! + "\n", attributes: normalRight)

        if paymentMethod == .creditCard {
            if let tax = UserDefaults.standard.object(forKey: "creditCardFeePercentage") as? NSNumber {
                var tax = NSDecimalNumber(decimal: tax.decimalValue)
                tax = tax.multiplying(byPowerOf10: -2)
                tax = tax.adding(1)

                let roundUP = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
                let iboGrandTotalWithFee = cartDelegate.iboCostGrandTotal.multiplying(by: tax, withBehavior: roundUP)
                let retailGrandTotalWithFee = cartDelegate.retailCostGrandTotal.multiplying(by: tax, withBehavior: roundUP)

                let iboGrandTotalWithFeeAttributedText = NSMutableAttributedString(string: "Grand Total w/ CC Fee (IBO / Retail): ", attributes: bold)
                invoiceText += iboGrandTotalWithFeeAttributedText
                    + NSMutableAttributedString(string: currencyFormatter.string(from: iboGrandTotalWithFee)! + " / " + currencyFormatter.string(from: retailGrandTotalWithFee)! + "\n", attributes: normalRight)
            }
        }

        // Purchased Items
        invoiceText += NSMutableAttributedString(string: "Purchased Items (\(cartDelegate.quantityTotal.stringValue))\n", attributes: boldBlue)

        if let cartProducts = CartProduct.mr_findAll() as? [CartProduct] {
            for cartProduct in cartProducts {
                invoiceText += NSMutableAttributedString(string: "\(cartProduct.product!.sku!)\(cartProduct.product!.custom!.boolValue ? " Custom" : "") \(cartProduct.taxable!.boolValue ? "Taxed" : "Not Taxed") (\(cartProduct.quantity!.stringValue))", attributes: boldBlue)
                invoiceText += NSMutableAttributedString(string: " - \(cartProduct.product!.name!)\n", attributes: normal)
            }
        }

        textview.attributedText = invoiceText
    }
    @IBAction func shareInvoice(_ sender: AnyObject) {
        let invoice = Invoice(subject: subject, message: invoiceText)
        let activityViewController = UIActivityViewController(activityItems: [invoice], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {_, completed, _, _ in
            if (completed) {
                self.performSegue(withIdentifier: "exit", sender: self)
            }
        }
        present(activityViewController, animated: true, completion: nil)
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
