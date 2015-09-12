//
//  ITSearch.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 11/5/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITViewController.h"
#import "ITData.h"

@interface ITSearch : UIViewController {
    
    NSString *skuSearchValue;
    NSString *skuTextValue;
    
    NSString *nameTextValue;
    
    NSString *retailTextValue;
    NSString *iboTextValue;
    
    NSString *iboPriceTextValue;
    
    NSString *pvTextValue;
    NSString *bvTextValue;
    
    NSString *salesTaxValue;
    NSString *quantityValue;
    NSString *productTaxable;
    UIImage *image1;
    
    NSMutableArray *searchedObjects;
    
    BOOL taxableYesOrNO;
    
}
-(IBAction)resignKeyboard:(id)sender;
-(IBAction)resignKeyboard2:(id)sender;
-(IBAction)didCancel:(id)sender;
@property(nonatomic, strong)IBOutlet UITextField *skuField;
@property(nonatomic, strong)IBOutlet UIButton *searchButton;
@property(nonatomic, strong)IBOutlet UITextField *quantityField;
@property(nonatomic, strong)IBOutlet UISegmentedControl *segmentField;
@end
