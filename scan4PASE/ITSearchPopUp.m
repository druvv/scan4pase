//
//  ITSearchPopUp.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 6/1/14.
//  Copyright (c) 2014 Sringari Worldwide. All rights reserved.
//

#import "ITSearchPopUp.h"

@interface ITSearchPopUp ()

@end

@implementation ITSearchPopUp

@synthesize  allProducts;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = false;
    _searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = _searchController.searchBar;
    self.definesPresentationContext = YES;
    
    
    mainData = [ITData getInstance];
    
    mainData.currentProduct = nil;
    
    allProducts = [[ITData getAllProducts] mutableCopy];
    
    
}

-(void)viewDidLayoutSubviews {
    [_searchController.searchBar sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)filterContentForSearchText:(NSString*)searchText {
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name Contains[cd] %@ OR sku Contains[cd] %@", searchText,searchText];
    
    searchResults = [allProducts filteredArrayUsingPredicate:resultPredicate];
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self filterContentForSearchText:searchString];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
        return [searchResults count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 117;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"searchCell";
    ITSearchPopupCell *cell = (ITSearchPopupCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ITSearchPopupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isIBO = [defaults boolForKey:@"iboOrCustomer"];
    
    if (isIBO) {
        cell.iboCost.hidden  =  NO;
        cell.iboCostLabel.hidden = NO;
    } else {
        cell.iboCost.hidden = YES;
        cell.iboCostLabel.hidden = YES;
    }
    
    if ([[[searchResults objectAtIndex:indexPath.row] objectForKey:@"custom"] boolValue] == true) {
        //cell.backgroundColor = UIColor(red: 0.141, green: 0.929, blue: 0.878, alpha: 0.5)
        cell.backgroundColor = [UIColor colorWithRed:0.141 green:0.929 blue:0.878 alpha:0.5];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    // Configure the cell...
    
    cell.SKU.text = [NSString stringWithFormat:@"%@", [[searchResults objectAtIndex:indexPath.row] objectForKey:@"sku"]];
    cell.Name.text = [NSString stringWithFormat:@"%@", [[searchResults objectAtIndex:indexPath.row] objectForKey:@"name"]];
    cell.retailCost.text = [NSString stringWithFormat:@"$%.2f", [[[searchResults objectAtIndex:indexPath.row] objectForKey:@"retailCost"]doubleValue]];
    cell.iboCost.text = [NSString stringWithFormat:@"$%.2f", [[[searchResults objectAtIndex:indexPath.row] objectForKey:@"iboCost"]doubleValue]];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSearchResults"])
    {
        NSIndexPath *myIndexPath = [self.tableView
                                    indexPathForSelectedRow];
        
        mainData = [ITData getInstance];
        [mainData setCurrentProduct:[[searchResults objectAtIndex:myIndexPath.row] mutableCopy]];

    }
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
