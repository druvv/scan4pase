//
//  ITCell.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 8/27/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import "ITCell.h"

@implementation ITCell
@synthesize Name,SKU,pvAndBv,iboCost,retailCost, quantity;

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
