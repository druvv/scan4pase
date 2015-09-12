//
//  ITSearchPopupCell.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 6/1/14.
//  Copyright (c) 2014 Sringari Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITSearchPopupCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *SKU;
@property (strong, nonatomic) IBOutlet UILabel *Name;
@property (strong, nonatomic) IBOutlet UILabel *iboCost;
@property (strong, nonatomic) IBOutlet UILabel *iboCostLabel;
@property (strong, nonatomic) IBOutlet UILabel *retailCost;


@end
