//
//  ITTableViewController.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 8/27/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITCell.h"
@class ITTableViewController;
@interface ITTableViewController : UITableViewController <UIAlertViewDelegate> {
    NSMutableArray *scannedItems;
}

@property (strong , nonatomic) NSMutableArray *scannedItems;

@end
