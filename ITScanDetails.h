//
//  ITScanDetails.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 11/11/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITData.h"

@interface ITScanDetails : UIViewController {
    NSDecimalNumber *retailDecimalNumber;
    NSDecimalNumber *salesTaxDecimalNumber;
}

@property (nonatomic , strong) IBOutlet UITextField *quantityTextField;
@property (nonatomic , strong) IBOutlet UISegmentedControl *taxableSegment;
@property (nonatomic , strong) IBOutlet UIButton *ok;
@property (nonatomic , strong) IBOutlet UILabel *itemLabel;

@property (strong, nonatomic) NSString *skuResult;
@property (strong, nonatomic) NSString *nameResult;
@property (strong, nonatomic) NSString *quantityResult;
@property (strong, nonatomic) NSString *SKU;
@property double retailResult;
@property double iboResult;
@property double pvResult;
@property double bvResult;
@property double salesTaxResult;
@property BOOL taxable;


// Methods

-(IBAction)okClicked:(id)sender;
-(IBAction)resignKeyboard:(id)sender;
-(IBAction)didCancel:(id)sender;
    


@end
