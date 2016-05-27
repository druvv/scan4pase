//
//  ITSearchPopUp.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 6/1/14.
//  Copyright (c) 2014 Sringari Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITData.h"
#import "ITSearchPopupCell.h"
#import "ITScanDetails.h"

@interface ITSearchPopUp : UITableViewController<UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate> {
    ITData *mainData;
    
    NSArray *searchResults;
}

@property (nonatomic, strong)NSMutableArray *allProducts;
@property (nonatomic, strong) UISearchController *searchController;

@end
