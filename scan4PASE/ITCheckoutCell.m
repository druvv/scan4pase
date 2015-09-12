//
//  ITCheckoutCell.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 9/28/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import "ITCheckoutCell.h"

@implementation ITCheckoutCell

@synthesize SKU,Name,iboCost,retailCost,pvAndBv, salesTaxCell,quantity;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
