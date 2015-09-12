//
//  ITSearchPopupCell.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 6/1/14.
//  Copyright (c) 2014 Sringari Worldwide. All rights reserved.
//

#import "ITSearchPopupCell.h"

@implementation ITSearchPopupCell

@synthesize SKU,Name,iboCost,retailCost;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
