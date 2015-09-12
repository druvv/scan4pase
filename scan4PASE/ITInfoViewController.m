//
//  ITInfoViewController.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 8/25/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import "ITInfoViewController.h"
#import "ITData.h"
@interface ITInfoViewController ()

@end

@implementation ITInfoViewController

@synthesize sku, name, retail, ibo, iboLabel, pv, bv;
@synthesize skuResult, nameResult, retailResult, iboResult, pvResult, bvResult, imageResult, quantityResult;
@synthesize salesTaxResult, salesTaxLabel , taxable, quantity;
@synthesize scanning;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title  isEqual: @"Item Removed"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(IBAction)removeItem:(id)sender {
    ITData *mainData = [ITData getInstance];
    [mainData.cartProducts removeLastObject];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Item Removed" message:@"This Item Has Been Removed From the Cart" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}

-(IBAction)home:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad

{
    
    if (scanning) {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isIBO = [defaults boolForKey:@"iboOrCustomer"];
    
    if (isIBO) {
        ibo.hidden = NO;
        iboLabel.hidden = NO;
    } else {
        ibo.hidden = YES;
        iboLabel.hidden = YES;
    }
    
    sku.text = skuResult;
    name.text = nameResult;
    quantity.text = quantityResult;
    
    double quantityValue = [quantityResult doubleValue];
    retail.text = [NSString stringWithFormat:@"$%0.2f",retailResult * quantityValue];
    ibo.text = [NSString stringWithFormat:@"$%0.2f",iboResult * quantityValue];
    pv.text = [NSString stringWithFormat:@"%0.2f",pvResult * quantityValue];
    bv.text = [NSString stringWithFormat:@"%0.2f",bvResult * quantityValue];
    
    if (taxable) {
        salesTaxLabel.text = [NSString stringWithFormat:@"$%.2f", salesTaxResult * quantityValue];
    } else {
        salesTaxLabel.text = @"N/A";
    }
    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(added) userInfo:nil repeats:NO];
    
}

-(void)added {
    UIAlertView *added = [[UIAlertView alloc] initWithTitle:@"Added to Cart" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [added show];
    [self performSelector:@selector(dismissAlertView:) withObject:added afterDelay:1];
}

-(void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
