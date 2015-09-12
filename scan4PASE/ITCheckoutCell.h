//
//  ITCheckoutCell.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 9/28/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITCheckoutCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *SKU;
@property (strong, nonatomic) IBOutlet UILabel *Name;
@property (strong, nonatomic) IBOutlet UILabel *iboCost;
@property (strong, nonatomic) IBOutlet UILabel *iboCostLabel;
@property (strong, nonatomic) IBOutlet UILabel *retailCost;
@property (strong, nonatomic) IBOutlet UILabel *pvAndBv;
@property (strong, nonatomic) IBOutlet UILabel *salesTaxCell;
@property (strong, nonatomic) IBOutlet UILabel *quantity;

@end
