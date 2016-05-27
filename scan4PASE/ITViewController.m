//
//  ITViewController.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 8/25/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import "ITViewController.h"
#import "ITHelp.h"

@interface ITViewController ()

@end

@implementation ITViewController

@synthesize salesTaxValue, skuTextValue, skuSearchValue, productTaxable, quantityValue;

@synthesize scanButton,searchedObjectsArray;

@synthesize nameTextValue, retailTextValue, iboTextValue,pvTextValue,bvTextValue,image1;

@synthesize productsArray, scannedItemsarray;

@synthesize alertTextField, numberOfProductsInCart, cartButton;

@synthesize readerqr;



-(IBAction)help:(id)sender {
    [self performSegueWithIdentifier:@"help" sender:nil];
}

-(IBAction)checkout:(id)sender {
    
    UIAlertView *checkoutAlert = [[UIAlertView alloc] initWithTitle:@"Checkout" message:@"Please check your bag before checking out." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    
    [checkoutAlert addButtonWithTitle:@"Checkout"];
    [checkoutAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title  isEqual: @"Checkout"] && buttonIndex == 1) {
        
        ITData *mainData = [ITData getInstance];
        if (!mainData.cartProducts) {
            mainData.cartProducts = [[NSMutableArray alloc] init];
        }
        if (mainData.cartProducts.count != 0) {
            
            [self performSegueWithIdentifier:@"checkoutPush" sender:nil];
            
        } else {
            
            UIAlertView *noItemAlert = [[UIAlertView alloc] initWithTitle:@"No Items in Cart" message:@"Please add items to your cart first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [noItemAlert show];
        }
        
        
    }
    
}

// load zbar
-(IBAction)scanButtonPressed:(id)sender
{
    
    //clear the objects array
    [searchedObjectsArray removeAllObjects];
    // Check if we have camera rights!
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusAuthorized) {
        [self presentViewController:readerqr animated:YES completion:NULL];
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined) {
        NSLog(@"%@", @"Camera access not determined. Ask for permission.");
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
             if(granted) {
                 NSLog(@"Granted access to %@", AVMediaTypeVideo);
                 [self presentViewController:readerqr animated:YES completion:NULL];
             } else {
                 NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                 [self camDenied];
             }
         }];
    }
    else if (authStatus == AVAuthorizationStatusRestricted) {
        // Tells User that Camera has been restricted in Parental Controls
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Access" message:@"You've been restricted from using the camera on this device. Without camera access this feature won't work. Please contact the device owner so they can give you access." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self camDenied];
    }
    
    
    
    return;
}

- (void)camDenied
{
    NSLog(@"%@", @"Denied camera access");
    
    NSString *alertText;
    NSString *alertButton;
    
    BOOL canOpenSettings = (UIApplicationOpenSettingsURLString != NULL);
    if (canOpenSettings)
    {
        alertText = @"It looks like your privacy settings are preventing us from accessing your camera to do barcode scanning. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Touch Privacy.\n\n3. Turn the Camera on.\n\n4. Open this app and try again.";
        
        alertButton = @"Go";
    }
    else
    {
        alertText = @"It looks like your privacy settings are preventing us from accessing your camera to do barcode scanning. You can fix this by doing the following:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Touch Privacy.\n\n5. Turn the Camera on.\n\n6. Open this app and try again.";
        
        alertButton = @"OK";
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error"
                          message:alertText
                          delegate:self
                          cancelButtonTitle:alertButton
                          otherButtonTitles:nil];
    alert.tag = 3491832;
    [alert show];
}


-(void)imagePickerController:(UIImagePickerController *)reader didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get decode results
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    
    ZBarSymbol *symbol = nil;
    // this gets the first thing in results
    for (ZBarSymbol *s in results) {
        symbol = s;
        break;
    }
    
    mainReader = reader;
    NSLog(@"Original = %@",symbol.data);
    
    // We have to remove certain characters because of amway
    NSCharacterSet *illegalChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    skuSearchValue = [[symbol.data componentsSeparatedByCharactersInSet:illegalChars] componentsJoinedByString:@""];
    NSLog(@"%@",skuSearchValue);
    
    ITData *mainData= [ITData getInstance];
    
    if (!mainData.cartProducts) {
        mainData.cartProducts = [[NSMutableArray alloc] init];
    }
    
    if ([ITData searchProducts:skuSearchValue].count != 0) {
        mainData.currentProduct = [ITData searchProducts:skuSearchValue][0];
        [reader dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"scanDetails" sender:self];

    } else {
        
        UIAlertView *itemNotFound = [[UIAlertView alloc] initWithTitle:@"No Item Found" message:@"Make sure that you have scanned a valid item." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [itemNotFound show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3491832)
    {
        BOOL canOpenSettings = (UIApplicationOpenSettingsURLString != NULL);
        if (canOpenSettings)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}




- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    infoViewController = [[ITInfoViewController alloc] init];
    
    readerqr = [[ZBarReaderViewController alloc] init];
    
    //create a new zbar reader
    readerqr.readerDelegate = self;
    readerqr.showsHelpOnFail = NO;
    
    ZBarImageScanner *scanner = readerqr.scanner;
    
    //disable I2/5
    
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    productsArray = [[ITData getAllProducts] mutableCopy];
    
    UIImage *cart = [UIImage imageNamed:@"shoppingCartIcon"];
    
    [self.cartButton setImage:[cart imageByScalingProportionallyToSize:CGSizeMake(74,64)] forState:UIControlStateNormal];
    
}

-(void)viewWillAppear:(BOOL)animated {
    ITData *data = [ITData getInstance];
    
    totalNumber = 0;
    if (!data.cartProducts) {
        data.cartProducts = [[NSMutableArray alloc] init];
        
    }
    
    
    
    for (id dict in data.cartProducts) {
        int temp =  [[NSString stringWithFormat:@"%@",[dict objectForKey:@"quantity"]] intValue];
        totalNumber = temp + totalNumber;
    }
    
    numberOfProductsInCart.text = [NSString stringWithFormat:@"%d",totalNumber];
}


-(IBAction)cartButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"scannedItemsSegue" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
        
    if ([[segue identifier] isEqualToString:@"scannedItemsSegue"]) {
        
        tableViewController = segue.destinationViewController;
        
        ITData *mainData = [ITData getInstance];
        tableViewController.scannedItems = mainData.cartProducts;
        
    } else if ([[segue identifier] isEqualToString:@"checkoutPush"]) {
        
        ITCheckoutController *checkoutController = [[ITCheckoutController alloc] init];
        checkoutController = segue.destinationViewController;
        
        ITData *mainData = [ITData getInstance];
        checkoutController.checkoutItems = mainData.cartProducts;
        
    } else if ([[segue identifier] isEqualToString:@"help"]) {
        ITHelp *help = [[ITHelp alloc] init];
        help = segue.destinationViewController;
    } else if ([[segue identifier] isEqualToString:@"scanDetails"]) {
        ITScanDetails *detail = [[ITScanDetails alloc] init];
        
        detail = segue.destinationViewController;
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
