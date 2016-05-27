//
//  ITViewController.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 8/25/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>
@import ZBarSDK;
#import "ITInfoViewController.h"
#import "ITTableViewController.h"
#import "ITCheckoutController.h"
#import "ITData.h"
#import "ITScanDetails.h"
#import "UIImage+Extras.h"
#import <AVFoundation/AVFoundation.h>


@class ITViewController;
@interface ITViewController : UIViewController<ZBarReaderDelegate, UIAlertViewDelegate>
{
    
    NSArray *csvArray;
    
    BOOL scanOrSearch;
    
    NSString *skuSearchValue;
    NSString *skuTextValue;
    
    NSString *nameTextValue;
    
    NSString *retailTextValue;
    NSString *iboPriceTextValue;
    
    NSString *pvTextValue;
    NSString *bvTextValue;
    
    NSString *salesTaxValue;
    NSString *productTaxable;
    UIImage *image1;
    
    ITInfoViewController *infoViewController;
    ITTableViewController *tableViewController;
    
    UIImagePickerController *mainReader;
    int totalNumber;
    
}

-(IBAction)scanButtonPressed:(id)sender;
-(IBAction)cartButtonPressed:(id)sender;
-(IBAction)checkout:(id)sender;
-(IBAction)help:(id)sender;





@property(nonatomic, strong)IBOutlet UIButton *scanButton;
@property(nonatomic, strong)IBOutlet UIButton *cartButton;
@property(nonatomic, strong)IBOutlet UIBarButtonItem *helpButton;
@property(nonatomic, strong)IBOutlet UIButton *checkoutButton;
@property(nonatomic, strong)IBOutlet UILabel *numberOfProductsInCart;

@property(nonatomic, strong) NSString *skuSearchValue;
@property(nonatomic, strong) NSString *skuTextValue;
@property(nonatomic, strong) NSString *nameTextValue;
@property(nonatomic, strong) NSString *retailTextValue;
@property(nonatomic, strong) NSString *iboTextValue;
@property(nonatomic, strong) NSString *pvTextValue;
@property(nonatomic, strong) NSString *bvTextValue;
@property(nonatomic, strong) NSString *salesTaxValue;
@property(nonatomic, strong) NSString *quantityValue;
@property(nonatomic, strong) NSString *productTaxable;
@property(nonatomic, strong) UIImage *image1;
@property(nonatomic, strong) NSMutableArray *searchedObjectsArray;
@property(nonatomic, strong) NSMutableArray *productsArray;
@property(nonatomic, strong) NSMutableArray *scannedItemsarray;

@property (nonatomic, strong) UITextField *alertTextField;

@property (nonatomic, strong) ZBarReaderViewController *readerqr;




@end
