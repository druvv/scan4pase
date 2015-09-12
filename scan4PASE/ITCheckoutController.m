//
//  ITCheckoutController.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 9/28/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.

#import "ITCheckoutController.h"

@interface ITCheckoutController ()

@end

@implementation ITCheckoutController

@synthesize retailTotal, iboTotal, iboTotalLabel, pvBvTotal, salesTax;
@synthesize checkoutItems;
@synthesize checkoutTableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)showEmail {
    

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isIBO = [defaults boolForKey:@"iboOrCustomer"];
    NSString *iboEmail = [defaults stringForKey:@"iboEmail"];
    
    
    NSArray *cc;
    NSString *subject;
    NSString *squareCash;
    
    
    if (isIBO)
        subject = [NSString stringWithFormat:@"scan4pase Square Cash: $%.2f",totalIboCost_tax];
     else
         subject = [NSString stringWithFormat:@"scan4pase Square Cash: $%.2f",totalretailCost_tax];
    
    if ([paymentMethod isEqualToString:@"Square Cash"]) {
        
        if (request) {
            squareCash = @"request@square.com";
        } else {
            squareCash = @"send@square.com";
        }
        
        cc = [[NSArray alloc] initWithObjects:squareCash,iboEmail, nil];
        
    } else {
        cc = [[NSArray alloc] initWithObjects:iboEmail, nil];
        subject = [NSString stringWithFormat:@"scan4pase - Checkout - %@", iboName];
    }

    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormat stringFromDate:date];
    

    NSString *emailBody;
    
    NSString *isPaid;
    NSString *paymentDetails;
    
    if (paid) {
         if ([paymentMethod isEqualToString:@"Check"]) {
            paymentDetails = [NSString stringWithFormat:@"Check Number: %@ ", checkNumber];
         }
    }
    
    
    NSMutableString *totalItems = [[NSMutableString alloc] init];
    
    for (id dict in checkoutItems) {
        NSMutableString *item = [NSMutableString stringWithFormat:@"%@ - %@",[dict objectForKey:@"sku"],[dict objectForKey:@"name"]];
        NSMutableString *quantity = [NSMutableString stringWithString:[dict objectForKey:@"quantity"]];
        [item appendString:[NSString stringWithFormat:@" (%@)", quantity]];
        [item appendString:@"\n\n"];
        
        [totalItems appendString:item];
        
        //NSLog(@"Total items %@", totalItems);
    }
    
    if (paid) {
        isPaid = @"Yes";
    } else {
        isPaid = @"No";
    }
    
    if (isIBO) {
        if ([paymentMethod isEqualToString:@"Credit Card"]) {
            
            emailBody = [ NSString stringWithFormat:@"Dear %@, \nHere is your purchase.\n\nPurchase Details: \nDate: %@\nPurchaser's IBO #: %@\nOrder Paid: %@\nPayment Method: Credit Card\n\nTotal PV / BV: %.2f / %.2f \n\nTotal Retail Cost w/ tax: $%.2f\nTotal IBO Cost w/ tax: $%.2f \n\nTotal Retail Cost w/ tax w/ convenience fee: $%.2f\nTotal IBO Cost w/ tax w/ convenience fee: $%.2f\n\nPurchased items:\n%@\nCreated with scan4pase" ,iboName, dateString, iboNumber, isPaid, totalPv, totalBv, totalretailCost_tax, totalIboCost_tax,totalretailCost_tax + conFeeR,totalIboCost_tax + conFeeI,totalItems];
        } else if ([paymentMethod isEqualToString:@"Cash"]) {
            
            emailBody = [ NSString stringWithFormat:@"Dear %@, \nHere is your purchase.\n\nPurchase Details: \nDate: %@\nPurchaser's IBO #: %@\nOrder Paid: %@\nPayment Method: Cash\nTotal PV / BV: %.2f / %.2f \n\nTotal Retail Cost w/ tax: $%.2f\nTotal IBO Cost w/ tax: $%.2f \n\n Purchased items:\n%@\nCreated with scan4pase" ,iboName, dateString, iboNumber, isPaid, totalPv, totalBv, totalretailCost_tax, totalIboCost_tax, totalItems];
        } else if ([paymentMethod isEqualToString:@"Check"]) {
            emailBody = [ NSString stringWithFormat:@"Dear %@, \nHere is your purchase.\n\nPurchase Details: \nDate: %@\nPurchaser's IBO #: %@\nOrder Paid: %@\nPayment Method: Check\nTotal PV / BV: %.2f / %.2f \nCheck Number: %@\n\nTotal Retail Cost w/ tax: $%.2f\nTotal IBO Cost w/ tax: $%.2f \n\n Purchased items:\n%@\nCreated with scan4pase" ,iboName, dateString, iboNumber, isPaid, totalPv, totalBv, checkNumber, totalretailCost_tax, totalIboCost_tax, totalItems];
        } else if (!paid) {
             emailBody = [ NSString stringWithFormat:@"Dear %@, \nHere is your purchase.\n\nPurchase Details: \nDate: %@\nOrder Paid: %@\n\nTotal PV / BV: %.2f / %.2f \n\nTotal Retail Cost w/ tax: $%.2f\nTotal IBO Cost w/ tax: $%.2f \n\n Purchased items:\n%@\nCreated with scan4pase"  ,iboName,dateString, isPaid,totalPv, totalBv, totalretailCost_tax,totalIboCost_tax, totalItems];
        } else if ([paymentMethod isEqualToString:@"Square Cash"]) {
             emailBody = [ NSString stringWithFormat:@"Dear %@, \nHere is your purchase.\n\nPurchase Details: \nDate: %@\nPurchaser's IBO #: %@\nOrder Paid: %@\nPayment Method: Square Cash\nTotal PV / BV: %.2f / %.2f \n\nTotal Retail Cost w/ tax: $%.2f\nTotal IBO Cost w/ tax: $%.2f \n\n Purchased items:\n%@\nCreated with scan4pase" ,iboName, dateString, iboNumber, isPaid, totalPv, totalBv, totalretailCost_tax, totalIboCost_tax, totalItems];
        }
        
    } else {
        
        if (paid) {
            
            if ([paymentMethod isEqualToString:@"Credit Card"]) {
                
                emailBody = [ NSString stringWithFormat:@"Dear %@, \n\nPurchase Details: \nDate: %@\nOrder Paid: %@\nPayment Method: Credit Card\n\nPaymentTotal PV / BV: %.2f / %.2f \n\nTotal Retail Cost w/ tax: $%.2f\nTotal Retail Cost w/ tax w/ convenience fee: $%.2f\n\nPurchased items:\n%@ \nCreated with scan4pase" ,iboName,dateString, isPaid, totalPv, totalBv, totalretailCost_tax,totalretailCost_tax + conFeeR, totalItems];
            } else if ([paymentMethod isEqualToString:@"Cash"]) {
                emailBody = [ NSString stringWithFormat:@"Dear %@, \nHere is your purchase.\n\nPurchase Details: \nDate: %@\nOrder Paid: %@\nPayment Method: Cash\nTotal PV / BV: %.2f / %.2f \n\nTotal Retail Cost w/ tax: $%.2f \n\nPurchased items:\n%@\nCreated with scan4pase" ,iboName, dateString, isPaid, totalPv, totalBv, totalretailCost_tax, totalItems];
            } else if ([paymentMethod isEqualToString:@"Check"]) {
                emailBody = [ NSString stringWithFormat:@"Dear %@, \nHere is your purchase.\n\nPurchase Details: \nDate: %@\nOrder Paid: %@\nPayment Method: Check\nCheck Number: %@\n\nTotal PV / BV: %.2f / %.2f \nTotal Retail Cost w/ tax: $%.2f \n\nPurchased items:\n%@\nCreated with scan4pase" ,iboName, dateString, isPaid, checkNumber, totalPv, totalBv,  totalretailCost_tax, totalItems];
            } else if ([paymentMethod isEqualToString:@"Square Cash"]) {
                emailBody = [ NSString stringWithFormat:@"Dear %@, \nHere is your purchase.\n\nPurchase Details: \nDate: %@\nOrder Paid: %@\nPayment Method: Square Cash\nTotal PV / BV: %.2f / %.2f \n\nTotal Retail Cost w/ tax: $%.2f \n\nPurchased items:\n%@\nCreated with scan4pase" ,iboName, dateString, isPaid, totalPv, totalBv, totalretailCost_tax, totalItems];
            }
            
        } else {
            
            emailBody = [ NSString stringWithFormat:@"Dear %@, \n\nPurchase Details: \nDate: %@\nOrder Paid: %@\n\nPaymentTotal PV / BV: %.2f / %.2f \n\nTotal Retail Cost w/ tax: $%.2f \n\n Purchased items:\n%@ \nCreated with scan4pase" ,iboName,dateString, isPaid,totalPv, totalBv, totalretailCost_tax, totalItems];
        } 
    }
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:subject];
    [mc setCcRecipients:cc];
    [mc setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)startInfo:(id)sender {
    UIAlertView *getName = [[UIAlertView alloc] initWithTitle:@"Purchaser's Name" message:@"Enter the Purchaser's Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    getName.alertViewStyle = UIAlertViewStylePlainTextInput;
    [getName show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        
        return;
    }
    
    if ([alertView.title  isEqual: @"Purchaser's Name"]) {
        
        UITextField *name = [alertView textFieldAtIndex:0];
        iboName = name.text;
        //NSLog(@"%@", iboName);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL isIBO = [defaults boolForKey:@"iboOrCustomer"];
        
        if (isIBO) {
            UIAlertView *getIboNumber = [[UIAlertView alloc] initWithTitle:@"Purchaser's IBO#" message:@"Enter the purchaser's IBO#" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            getIboNumber.alertViewStyle = UIAlertViewStylePlainTextInput;
            [getIboNumber show];
        } else {
            UIAlertView *paidAlert = [[UIAlertView alloc] initWithTitle:@"Paid?" message:@"Purchaser Paying Now?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"No", @"Yes", nil];
            [paidAlert show];
        }
        
    } else if ([alertView.title  isEqual: @"Purchaser's IBO#"]) {
        
        UITextField *ibo = [alertView textFieldAtIndex:0];
        iboNumber = ibo.text;
        //NSLog(@"%@", iboNumber);
        
        UIAlertView *paidAlert = [[UIAlertView alloc] initWithTitle:@"Paid?" message:@"Purchaser Paying Now?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"No", @"Yes", nil];
        [paidAlert show];
        
    } else if ([alertView.title isEqual: @"Paid?"]) {
        
        if (buttonIndex == 1) {
            
            paid = NO;
            [self showEmail];
            
        } else {
            
            paid = YES;
            UIAlertView *instructions = [[UIAlertView alloc] initWithTitle:@"Payment" message:@"Payment through Cash, Check, Credit Card, or Square Cash" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Cash", @"Check",@"Credit Card",@"Square Cash", nil];
            [instructions show];
        }
        
    } else if ([alertView.title  isEqual: @"Payment"]) {
        
        if (buttonIndex == 1) {
            paymentMethod = @"Cash";
            [self showEmail];
            
        } else if (buttonIndex == 2) {
            
            paymentMethod = @"Check";
            UIAlertView *getCheckNumber = [[UIAlertView alloc] initWithTitle:@"Check #" message:@"Enter the check #" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            getCheckNumber.alertViewStyle = UIAlertViewStylePlainTextInput;
            [getCheckNumber show];
            
        } else if (buttonIndex == 3) {
            paymentMethod = @"Credit Card";
            [self showEmail];
         
        } else if (buttonIndex == 4) {
            paymentMethod = @"Square Cash";
            UIAlertView *sendOrRequest = [[UIAlertView alloc] initWithTitle:@"Send or Request" message:@"Would you like to send or request money?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", @"Request", nil];
            [sendOrRequest show];
            
        }
    
    } else if ([alertView.title  isEqual: @"Send or Request"]) {
        
        if (buttonIndex == 1) {
            request = NO;
        } else if (buttonIndex == 2) {
            request = YES;
        }
        
        [self showEmail];
        
    } else if ([alertView.title  isEqual: @"Check #"]) {
        
        UITextField *checkNum = [alertView textFieldAtIndex:0];
        checkNumber = checkNum.text;
        //NSLog(@"Check Number: %@", checkNumber);
        [self showEmail];
        
    }
    
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    if ([alertView.title isEqualToString:@"Purchaser's Name"]) {
        return ([[[alertView textFieldAtIndex:0] text] length]> 0)?YES:NO;
    }
    
    else if ([alertView.title isEqualToString:@"Purchaser's IBO#"]) {
        return ([[[alertView textFieldAtIndex:0] text] length]>= 4)?YES:NO;
    }
    
    else if ([alertView.title isEqualToString:@"Check #"]) {
        return ([[[alertView textFieldAtIndex:0] text] length]> 0)?YES:NO;
    }
    
    else if ([alertView.title isEqualToString:@"Card Number"]) {
        return ([[[alertView textFieldAtIndex:0] text] length]== 16)?YES:NO;
    }
    
    else if ([alertView.title isEqualToString:@"CVC"]) {
        return ([[[alertView textFieldAtIndex:0] text] length]== 3)?YES:NO;
    }
    
    else if ([alertView.title isEqualToString:@"Expiration Month"]) {
        return ([[[alertView textFieldAtIndex:0] text] length]== 2)?YES:NO;
    }
    
    else if ([alertView.title isEqualToString:@"Expiration Year"]) {
        return ([[[alertView textFieldAtIndex:0] text] length]== 4)?YES:NO;
    }
    
    return YES;
    
}






- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"%@", checkoutItems);
	// Do any additional setup after loading the view.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isIBO = [defaults boolForKey:@"iboOrCustomer"];
    
    if (isIBO) {
        iboTotal.hidden  =  NO;
        iboTotalLabel.hidden = NO;
    } else {
        iboTotal.hidden = YES;
        iboTotalLabel.hidden = YES;
    }
    
    
    
    for (id item in checkoutItems) {
        
        
        // load everything
        
        NSDecimalNumber *pvNumber = [item objectForKey:@"pv"];
        NSDecimalNumber *bvNumber = [item objectForKey:@"bv"];
        
        NSString *quantity = [item objectForKey:@"quantity"];
        
        NSDecimalNumber *iboCost = [item objectForKey:@"iboCost"];
        NSDecimalNumber *retailCost = [item objectForKey:@"retailCost"];
        
        NSDecimalNumber *tax = [item objectForKey:@"salesTax"];
        bool isTaxable = [[item objectForKey:@"taxable"] boolValue];
        
        totalPv += (pvNumber.doubleValue * quantity.doubleValue);
        totalBv += (bvNumber.doubleValue * quantity.doubleValue);
        totalIboCost += (iboCost.doubleValue * quantity.doubleValue);
        totalRetailCost += (retailCost.doubleValue * quantity.doubleValue);
        
        if (isTaxable) {
            totalTax += (tax.doubleValue * quantity.doubleValue);
        }
    }
    
    totalretailCost_tax = totalRetailCost + totalTax;
    totalIboCost_tax = totalIboCost + totalTax;
    
    NSString *pvAndBv = [[NSString stringWithFormat:@"%.2f / ", totalPv] stringByAppendingString:[NSString stringWithFormat:@"%.2f", totalBv]];
    pvBvTotal.text = pvAndBv;
    
    salesTax.text = [NSString stringWithFormat:@"$%.2f", totalTax];
    iboTotal.text = [NSString stringWithFormat:@"$%.2f", totalIboCost_tax];
    retailTotal.text = [NSString stringWithFormat:@"$%.2f", totalretailCost_tax];
    

    
    double feePercent = [defaults doubleForKey:@"cFP"];
    
    if (feePercent != 0) {
        
        feePercent = feePercent * 0.01;
        conFeeR = totalretailCost_tax * feePercent;
        conFeeI = totalIboCost_tax * feePercent;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        [formatter setRoundingMode: NSNumberFormatterRoundHalfUp];
        
        NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithDouble:conFeeR]];
        NSString *numberString1 = [formatter stringFromNumber:[NSNumber numberWithDouble:conFeeI]];
        conFeeR = [numberString doubleValue];
        conFeeI = [numberString1 doubleValue];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return checkoutItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CheckoutCell";
    ITCheckoutCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ITCheckoutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    
    if ([[[checkoutItems objectAtIndex:indexPath.row] objectForKey:@"custom"] boolValue] == true) {
        //cell.backgroundColor = UIColor(red: 0.141, green: 0.929, blue: 0.878, alpha: 0.5)
        cell.backgroundColor = [UIColor colorWithRed:0.141 green:0.929 blue:0.878 alpha:0.5];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    // Configure the cell...
    // set values for cells
    cell.SKU.text = [NSString stringWithFormat:@"%@", [[checkoutItems objectAtIndex:indexPath.row] objectForKey:@"sku"]];
    cell.Name.text = [NSString stringWithFormat:@"%@", [[checkoutItems objectAtIndex:indexPath.row] objectForKey:@"name"]];
    cell.retailCost.text = [NSString stringWithFormat:@"$%.2f", [[[checkoutItems objectAtIndex:indexPath.row] objectForKey:@"retailCost"]doubleValue]];
    cell.iboCost.text = [NSString stringWithFormat:@"$%.2f", [[[checkoutItems objectAtIndex:indexPath.row] objectForKey:@"iboCost"]doubleValue]];
    
    if ([[[checkoutItems objectAtIndex:indexPath.row] objectForKey:@"taxable"] boolValue]) {
        
        cell.salesTaxCell.text = [NSString stringWithFormat:@"$%.2f", [[[checkoutItems objectAtIndex:indexPath.row] objectForKey:@"salesTax"]doubleValue]];
        
    } else {
        cell.salesTaxCell.text = @"N/A";
    }
    
    // combine pv and bv values into one string
    NSString *pvText = [NSString stringWithFormat:@"%0.2f /", [[[checkoutItems objectAtIndex:indexPath.row] objectForKey:@"pv"] doubleValue]];
    NSString *bvText = [NSString stringWithFormat:@" %0.2f", [[[checkoutItems objectAtIndex:indexPath.row] objectForKey:@"bv"] doubleValue]];
    NSString *pvandBv = [pvText stringByAppendingString:bvText];
    cell.quantity.text = [NSString stringWithFormat:@"%@", [[checkoutItems objectAtIndex:indexPath.row]objectForKey:@"quantity"]];
    // set value for pv and bv
    cell.pvAndBv.text = pvandBv;
    
    
    //    CAGradientLayer *gradient = [CAGradientLayer layer];
    //    gradient.frame = cell.bounds;
    //    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor greenColor]CGColor], (id)[[UIColor blueColor]CGColor], nil];
    //    [cell.layer ];
    
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
