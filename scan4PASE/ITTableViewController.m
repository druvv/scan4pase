 //
//  ITTableViewController.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 8/27/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import "ITTableViewController.h"
#import "ITData.h"

@interface ITTableViewController ()

@end

@implementation ITTableViewController

@synthesize scannedItems;

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
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

    
}

//- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//    [super setEditing:editing animated:animated];
//    [self setEditing:editing animated:animated];
//}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title  isEqual: @"Empty Cart?"] && buttonIndex == 1) {
        [scannedItems removeAllObjects];
        
        ITData *mainData = [ITData getInstance];
        if (!mainData.cartProducts) {
            mainData.cartProducts = [[NSMutableArray alloc] init];
        }
        
        mainData.cartProducts = scannedItems;
        
        [self.tableView reloadData];
    }
    
}



-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
        
            // remove from array
            [scannedItems removeObjectAtIndex:indexPath.row];
            
            ITData *mainData = [ITData getInstance];
            if (!mainData.cartProducts) {
                mainData.cartProducts = [[NSMutableArray alloc] init];
            }
    
            mainData.cartProducts = scannedItems;
            
            //remove from tableview
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Empty Cart" style:UIBarButtonItemStylePlain target:self action:@selector(clearCart)];
    
    if (self.tableView.editing)
        self.navigationItem.leftBarButtonItem = item;
    else
        self.navigationItem.leftBarButtonItem = nil;
}

-(void)clearCart {
    
    UIAlertView *itemsCleared = [[UIAlertView alloc] initWithTitle:@"Empty Cart?" message:@"Are you sure you want to empty your cart?" delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes",nil];
    [itemsCleared show];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [scannedItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ITCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == NULL) {
        cell = [[ITCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    
    if ([[[scannedItems objectAtIndex:indexPath.row] objectForKey:@"custom"] boolValue] == true) {
        //cell.backgroundColor = UIColor(red: 0.141, green: 0.929, blue: 0.878, alpha: 0.5)
        cell.backgroundColor = [UIColor colorWithRed:0.141 green:0.929 blue:0.878 alpha:0.5];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    // Configure the cell...
    
    cell.SKU.text = [NSString stringWithFormat:@"%@", [[scannedItems objectAtIndex:indexPath.row] objectForKey:@"sku"]];
    cell.Name.text = [NSString stringWithFormat:@"%@", [[scannedItems objectAtIndex:indexPath.row] objectForKey:@"name"]];
    
    if ([[[scannedItems objectAtIndex:indexPath.row] objectForKey:@"taxable"]boolValue]) {
        
        cell.salesTax.text = [NSString stringWithFormat:@"$%.2f", [[[scannedItems objectAtIndex:indexPath.row] objectForKey:@"salesTax"]doubleValue]];
        
    } else {
        cell.salesTax.text = @"N/A";
    }

    double quant = [[[scannedItems objectAtIndex:indexPath.row] objectForKey:@"quantity"]doubleValue];
    
    NSString *pvText = [NSString stringWithFormat:@"%0.2f /", [[[scannedItems objectAtIndex:indexPath.row] objectForKey:@"pv"] doubleValue]];
    NSString *bvText = [NSString stringWithFormat:@" %0.2f", [[[scannedItems objectAtIndex:indexPath.row] objectForKey:@"bv"] doubleValue]];
    NSString *pvandBv = [pvText stringByAppendingString:bvText];
    cell.pvAndBv.text = pvandBv;
    cell.retailCost.text = [NSString stringWithFormat:@"$%.2f", [[[scannedItems objectAtIndex:indexPath.row] objectForKey:@"retailCost"]doubleValue] * quant];
    cell.iboCost.text = [NSString stringWithFormat:@"$%.2f", [[[scannedItems objectAtIndex:indexPath.row] objectForKey:@"iboCost"]doubleValue] * quant];
    cell.quantity.text = [NSString stringWithFormat:@"%@", [[scannedItems objectAtIndex:indexPath.row] objectForKey:@"quantity"]];
    
    
    return cell;
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */



@end
