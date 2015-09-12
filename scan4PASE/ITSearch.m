//
//  ITSearch.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 11/5/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import "ITSearch.h"

@interface ITSearch ()

@end

@implementation ITSearch
@synthesize skuField, quantityField, segmentField, searchButton;

-(IBAction)didCancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)searchButtonPressed:(id)sender
{
    
    double qt = [quantityField.text doubleValue];
    
    if ( qt < 0 || qt == 0 ) {
        
        UIAlertView *noNo = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid Quantity Setting" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [noNo show];
        
    } else {
        ITData *mainData = [ITData getInstance];
        
        mainData.currentProduct = nil;
        
        skuSearchValue = skuField.text;
        [self searchProducts:skuSearchValue];
        
        
        if (!mainData.currentProduct) {
            mainData.currentProduct = [[NSMutableDictionary alloc] init];
        }
        
        if (mainData.currentProduct.count != 0) {
            
            [self performSegueWithIdentifier:@"infoPushSearch" sender:nil];
            
        } else {
            
            UIAlertView *itemNotFound = [[UIAlertView alloc] initWithTitle:@"No Item Found" message:@"Make sure that the SKU that you have entered is correct." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [itemNotFound show];
        }
        
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"infoPushSearch"])
        
    {
        ITInfoViewController *infoViewController = [[ITInfoViewController alloc] init];
        infoViewController = segue.destinationViewController;
        infoViewController.skuResult = skuTextValue;
        infoViewController.nameResult = nameTextValue;
        infoViewController.imageResult = image1;
        infoViewController.quantityResult = quantityValue;
        infoViewController.retailResult = [retailTextValue doubleValue];
        infoViewController.iboResult = [iboTextValue doubleValue];
        infoViewController.pvResult = [pvTextValue doubleValue];
        infoViewController.bvResult = [bvTextValue doubleValue];
        infoViewController.taxable = [productTaxable boolValue];
        infoViewController.salesTaxResult = [salesTaxValue doubleValue];
        
    }
    
}



-(void)searchProducts:(NSString *)searchtext
{
    
    
    searchedObjects = [[NSMutableArray alloc] init];
    searchedObjects = [ITData searchProducts:searchtext];
    quantityValue = quantityField.text;
    
    if (segmentField.selectedSegmentIndex == 0) {
        taxableYesOrNO = YES;
    } else {
        taxableYesOrNO = NO;
    }
    
    
    for (NSMutableDictionary *dict in searchedObjects)
    {
        //Store the data in global instances to be used else where
        [dict setValue:quantityValue forKey:@"Quantity"];
        [dict setValue:[NSString stringWithFormat:@"%d", taxableYesOrNO] forKey:@"Taxable"];
        skuTextValue = [NSString stringWithFormat:@"%@", [dict objectForKey:@"SKU"]];
        nameTextValue = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Name"]];
        retailTextValue = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Retail Price"]];
        iboTextValue = [NSString stringWithFormat:@"%@", [dict objectForKey:@"IBO Price"]];
        pvTextValue = [NSString stringWithFormat:@"%@", [dict objectForKey:@"PV"]];
        bvTextValue = [NSString stringWithFormat:@"%@", [dict objectForKey:@"BV"]];
        salesTaxValue = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Sales Tax"]];
        productTaxable = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Taxable"]];
        
        ITData *mainData = [ITData getInstance];
        
        if (!mainData.cartProducts) {
            
            mainData.cartProducts = [[NSMutableArray alloc] init];
        }
        
        [mainData.cartProducts addObject:dict];
        [mainData setCurrentProduct:dict];
        NSLog(@"%@", mainData.cartProducts);
    }
    
    
    
}



-(IBAction)resignKeyboard:(id)sender
{
    [self resignFirstResponder];
}

-(IBAction)resignKeyboard2:(id)sender {
    [self resignFirstResponder];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
