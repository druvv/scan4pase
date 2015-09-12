//
//  ITInfoViewController.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 8/25/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ITInfoViewController : UIViewController <UIAlertViewDelegate>
{
    NSString *skuResult;
    NSString *nameResult;
    UIImage *imageResult;
    double retailResult;
    double iboResult;
    double pvResult;
    double bvResult;
    double salesTaxResult;
    BOOL taxable;
    
    
    
}

@property (strong, nonatomic) NSString *skuResult;
@property (strong, nonatomic) NSString *nameResult;
@property (strong, nonatomic) NSString *quantityResult;
@property (strong, nonatomic) UIImage *imageResult;

@property double retailResult;
@property double iboResult;
@property double pvResult;
@property double bvResult;
@property double salesTaxResult;
@property BOOL taxable;
@property BOOL scanning;



@property (strong, nonatomic) IBOutlet UILabel *sku;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *retail;
@property (strong, nonatomic) IBOutlet UILabel *ibo;
@property (strong, nonatomic) IBOutlet UILabel *iboLabel;
@property (strong, nonatomic) IBOutlet UILabel *pv;
@property (strong, nonatomic) IBOutlet UILabel *bv;
@property (strong, nonatomic) IBOutlet UILabel *quantity;
@property (strong, nonatomic) IBOutlet UILabel *salesTaxLabel;

-(IBAction)home:(id)sender;
-(IBAction)removeItem:(id)sender;
-(void)added;




@end
