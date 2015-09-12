//
//  ITScanDetails.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 11/11/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import "ITScanDetails.h"

@interface ITScanDetails ()

@end

@implementation ITScanDetails
@synthesize skuResult, nameResult, retailResult, iboResult, pvResult, bvResult, quantityResult , taxable, salesTaxResult;
@synthesize quantityTextField, taxableSegment, itemLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)didCancel:(id)sender {
    ITData *mainData = [ITData getInstance];
    [mainData.cartProducts removeLastObject];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad

{
    [super viewDidLoad];
    
    ITData *mainData = [ITData getInstance];
    
    skuResult = [mainData.currentProduct objectForKey:@"sku"];
    nameResult = [mainData.currentProduct objectForKey:@"name"];
    retailDecimalNumber = [mainData.currentProduct objectForKey:@"retailCost"];
    retailResult = retailDecimalNumber.doubleValue;
    iboResult = [[mainData.currentProduct objectForKey:@"iboCost"] doubleValue];
    pvResult = [[mainData.currentProduct objectForKey:@"pv"] doubleValue];
    bvResult = [[mainData.currentProduct objectForKey:@"bv"] doubleValue];
    salesTaxResult = 0.0;
    itemLabel.text = nameResult;
    
    self.navigationController.navigationItem.hidesBackButton = YES;
    
	// Do any additional setup after loading the view.
}
-(IBAction)okClicked:(id)sender {
    
    double qt = [quantityTextField.text doubleValue];
    
    if ( qt < 0 || qt == 0 ) {
        
        UIAlertView *noNo = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid Quantity Setting" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [noNo show];
        
    } else {
        quantityResult = quantityTextField.text;
    
        if ([taxableSegment selectedSegmentIndex] == 0) {
            
            taxable = YES;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDecimalNumber *taxPercent = [NSDecimalNumber decimalNumberWithString:[defaults objectForKey:@"taxPref"]];
            taxPercent = [taxPercent decimalNumberByMultiplyingByPowerOf10:-2];
            // This handler rounds number up to the 100th place
            NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                     scale:2
                                                                                          raiseOnExactness:NO
                                                                                           raiseOnOverflow:NO
                                                                                          raiseOnUnderflow:NO
                                                                                       raiseOnDivideByZero:NO];
            // Do the Multiplication
            salesTaxDecimalNumber = [retailDecimalNumber decimalNumberByMultiplyingBy:taxPercent withBehavior:handler];
            salesTaxResult = salesTaxDecimalNumber.doubleValue;
            
        } else {
            
            taxable = NO;
            
        }
    
        ITData *mainData = [ITData getInstance];
    
        [mainData.currentProduct setValue:[NSNumber numberWithBool:taxable] forKey:@"taxable"];
        [mainData.currentProduct setValue:quantityResult forKey:@"quantity"];
        [mainData.currentProduct setValue:salesTaxDecimalNumber forKey:@"salesTax"];
        [mainData.cartProducts addObject:mainData.currentProduct];
        
    
        [self performSegueWithIdentifier:@"infoPush" sender:self];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)resignKeyboard:(id)sender {
    [self resignFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"infoPush" ]) {
        
        ITInfoViewController *infoViewController = [[ITInfoViewController alloc] init];
        infoViewController = segue.destinationViewController;
        infoViewController.skuResult = skuResult;
        infoViewController.nameResult = nameResult;
        infoViewController.quantityResult = quantityResult;
        infoViewController.retailResult =  retailResult;
        infoViewController.iboResult = iboResult;
        infoViewController.pvResult = pvResult;
        infoViewController.bvResult = bvResult;
        infoViewController.taxable = taxable;
        infoViewController.salesTaxResult = salesTaxResult;
        
        BOOL scanning = YES;
        infoViewController.scanning = scanning;
    }
}

@end
