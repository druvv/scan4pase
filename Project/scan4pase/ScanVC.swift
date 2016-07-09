//
//  ScanVC.swift
//  scan4pase
//
//  Created by Dhruv Sringari on 7/7/16.
//  Copyright © 2016 Dhruv Sringari. All rights reserved.
//

import UIKit
import MTBBarcodeScanner

class ScanVC: UIViewController {
    
    var searchDelegate: SearchVCDelegate!
    
    @IBOutlet var targetBox: UIView!
    
    lazy var scanner: MTBBarcodeScanner = {
        let scanner = MTBBarcodeScanner(previewView: self.view)
        return scanner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        targetBox.layer.borderWidth = 1
        targetBox.layer.borderColor = UIColor(red: 27/255, green: 188/255, blue: 155/255, alpha: 0.6).CGColor
        scanner.allowTapToFocus = true
        MTBBarcodeScanner.requestCameraPermissionWithSuccess { success in
            if success {
                self.scanner.startScanningWithResultBlock { [unowned self] codes in
                    if let code = codes.first as? AVMetadataMachineReadableCodeObject {
                        self.scanner.freezeCapture()
                        if Product.MR_findFirstWithPredicate(NSPredicate(format: "sku == %@ AND custom != TRUE", argumentArray: [code.stringValue])) != nil {
                            self.dismissViewControllerAnimated(true, completion: {
                                self.searchDelegate.selectProduct(forSKU: code.stringValue)
                            })
                        } else {
                            let alert = UIAlertController(title: "Invalid SKU", message: "A product was not found for SKU: \(code.stringValue)", preferredStyle: .Alert)
                            let continueScanning = UIAlertAction(title: "Continue", style: .Default, handler: { _ in
                                self.scanner.unfreezeCapture()
                            })
                            let stopScanning = UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
                                self.scanner.stopScanning()
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                            alert.addAction(continueScanning)
                            alert.addAction(stopScanning)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                self.camDenied()
            }
        }
    }
    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func toggleFlashlight(sender: AnyObject) {
        scanner.toggleTorch()
    }
    
    func camDenied() {
        let settingsURL = UIApplicationOpenSettingsURLString
        let alert = UIAlertController(title: nil, message: "It looks like your privacy settings are preventing us from accessing your camera to do barcode scanning. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Touch Privacy.\n\n3. Turn the Camera on.\n\n4. Open this app and try again.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Go", style: .Default, handler: { _ in
            UIApplication.sharedApplication().openURL(NSURL(string: settingsURL)!)
        }))
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
