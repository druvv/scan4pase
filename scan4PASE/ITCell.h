//
//  ITCell.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 8/27/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *SKU;
@property (strong, nonatomic) IBOutlet UILabel *Name;
@property (strong, nonatomic) IBOutlet UILabel *iboCost;
@property (strong, nonatomic) IBOutlet UILabel *iboCostLabel;
@property (strong, nonatomic) IBOutlet UILabel *retailCost;
@property (strong, nonatomic) IBOutlet UILabel *pvAndBv;
@property (strong, nonatomic) IBOutlet UILabel *salesTax;
@property (strong, nonatomic) IBOutlet UILabel *quantity;

@end
