//
//  ITCheckoutController.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 9/28/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ITCheckoutCell.h"
#import <MessageUI/MessageUI.h>

@interface ITCheckoutController : UIViewController<UITableViewDataSource, UITableViewDelegate , MFMailComposeViewControllerDelegate, UIAlertViewDelegate> {
    double totalIboCost_tax;
    double totalIboCost;
    double totalPv;
    double totalBv;
    double totalretailCost_tax;
    double totalRetailCost;
    double totalTax;
    
    BOOL taxable;
    BOOL run;
    BOOL paid;
    BOOL request;
    
    NSString *iboName;
    NSString *iboNumber;
    
    UILabel *retailTotal;
    UILabel *iboTotal;
    UILabel *pvBvTotal;
    
    NSString *paymentMethod;
    
    
    NSString *checkNumber;
    
    NSString *cardType;
    NSString *paymentType;
    NSString *cvcCode;
    NSString *expireMonth;
    NSString *expireYear;
    NSString *cardNumber;
    
    NSString *convenienceFee;
    double conFeeR;
    double conFeeI;
}



@property (strong, nonatomic) IBOutlet UITableView *checkoutTableView;
@property(strong, nonatomic) NSMutableArray *checkoutItems;

@property (strong, nonatomic) IBOutlet UILabel *retailTotal;
@property (strong, nonatomic) IBOutlet UILabel *iboTotal;
@property (strong, nonatomic) IBOutlet UILabel *iboTotalLabel;
@property (strong, nonatomic) IBOutlet UILabel *pvBvTotal;
@property (strong, nonatomic) IBOutlet UILabel *salesTax;

-(IBAction)startInfo:(id)sender;
-(void)showEmail;



@end
