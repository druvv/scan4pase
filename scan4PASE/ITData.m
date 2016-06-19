
//
//  ITData.m
//  scan4PASE
//
//  Created by Dhruv Sringari on 11/6/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import "ITData.h"
#include "math.h"
@import FirebaseStorage;
@implementation ITData
@synthesize cartProducts, test, currentProduct;


static ITData *instance = nil;
+(ITData *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            
            instance = [ITData new];
        }
    }
    return instance;
}

+(NSArray *)getAllProducts {
    ITAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSMutableArray *allProducts = [[NSMutableArray alloc] init];
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/products.csv", documentsDirectory];
    
    NSError *error;
    NSString *csvString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Failed to Load CSV : %@",error);
    }
    
    //Set Contents of File sepperated by commasin an Array
    NSArray *csvArray;
    csvArray = [csvString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // Delete all non-custom products
    NSFetchRequest *oldProducts = [[NSFetchRequest alloc] init];
    [oldProducts setEntity:[NSEntityDescription entityForName:@"Product" inManagedObjectContext:moc]];
    [oldProducts setPredicate:[NSPredicate predicateWithFormat:@"custom != TRUE"]];
    [oldProducts setIncludesPropertyValues:NO];
    NSArray *productsToBeDeleted = [moc executeFetchRequest:oldProducts error:nil];
    for (NSManagedObject *product in productsToBeDeleted) {
        [moc deleteObject:product];
    }
    [appDelegate saveContext];
    
    // Get Only custom objects
    NSFetchRequest *request2 = [[NSFetchRequest alloc] init];
    [request2 setEntity:[NSEntityDescription entityForName:@"Product" inManagedObjectContext:moc]];
    [request2 setPredicate:[NSPredicate predicateWithFormat:@"custom == TRUE"]];
    NSArray *customObjects = [moc executeFetchRequest:request2 error:nil];

    for (NSString * product in csvArray) {
        BOOL shouldSave = true;
        NSArray *components = [product componentsSeparatedByString:@";"];
            
        // Temporarilty Hold Objects from the csv
        NSString *SKU   = components[0];
        NSString *name  = components[1];
        NSString *PV =  components[2];
        NSString *BV = components[3];
        NSString *IBOPrice = components[4];
        NSString *RetailPrice = components[5];
        bool taxable = false;
        NSString *quantity = @"1";
        NSDecimalNumber *salesTax = [NSDecimalNumber decimalNumberWithString:@"0"];
            
        // Does the sku Match a Custom Object?
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"sku == %@",SKU];
        if ([customObjects filteredArrayUsingPredicate:pred].count != 0) {
            shouldSave = false;
        }
            
        if (shouldSave) {
                
            // Convert Strings to NSDecimalNumbers to pass to id as a decimal type.
            NSDecimalNumber *pvNumber = [NSDecimalNumber decimalNumberWithString:PV];
            NSDecimalNumber *bvNumber = [NSDecimalNumber decimalNumberWithString:BV];
            NSDecimalNumber *iboCostNumber = [NSDecimalNumber decimalNumberWithString:IBOPrice];
            NSDecimalNumber *retailCostNumber = [NSDecimalNumber decimalNumberWithString:RetailPrice];
            // Bool requires the NSnumber class
            NSNumber *taxableNumber = [NSNumber numberWithBool:taxable];
                
            // Create the Product
            NSManagedObject *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:moc];
                
            // Always not custom!
            NSNumber *num = [NSNumber numberWithBool:false];
            // Set the values for the products.
            [product setValue:SKU forKey:@"sku"];
            [product setValue:name forKey:@"name"];
            [product setValue:pvNumber forKey:@"pv"];
            [product setValue:bvNumber forKey:@"bv"];
            [product setValue:iboCostNumber forKey:@"iboCost"];
            [product setValue:retailCostNumber forKey:@"retailCost"];
            [product setValue:quantity forKey:@"quantity"];
            [product setValue:salesTax forKey:@"salesTax"];
            [product setValue:taxableNumber forKey:@"taxable"];
            [product setValue:num forKey:@"custom"];
                
        } // EXIT SHOULD SAVE
    } // EXIT FOR LOOP
    [appDelegate saveContext];
        
    allProducts = [self getProductsFromContext];
    
    return allProducts;
}

+(NSMutableArray *)searchProducts:(NSString *)searchtext {
    ITAppDelegate *del = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [del managedObjectContext];
    
    // Create Fetch Request
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Product"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"sku == %@",searchtext];
    [request setPredicate:pred];
    NSError *error;
    
    // Search and store
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    if (array.count != 0) {
        NSManagedObject *product = array[0];
        // Turns ManagedObject into Dictionary
        NSArray *keys = [[[product entity] attributesByName] allKeys];
        NSMutableDictionary *dict = [[product dictionaryWithValuesForKeys:keys] mutableCopy];
        NSMutableArray *array = [NSMutableArray arrayWithObjects:dict, nil];
        return array;
    } else {
        return [[NSMutableArray alloc] init];
    }
}

-(void)changeQuantityTo:(NSString *)quantity {
    [[cartProducts lastObject] setObject:quantity forKey:@"quantity"];
}

-(void)setCurrentProduct:(NSMutableDictionary *)current {
    currentProduct = current;
}

+(NSMutableArray *)getProductsFromContext {
    ITAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSArray *productsObjects = [[NSArray alloc] init];
    NSMutableArray *products = [[NSMutableArray alloc] init];
    
    // Describe Product needed
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:context];
    // Create a Request for all products
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    // request it
    NSError *err;
    productsObjects = [context executeFetchRequest:request error:&err];
    
    if (productsObjects == nil) {
        NSLog(@"Failed to store existing objects to all products");
        //abort();
    }
    
    // Convert NSManaged Object in products to NSDictionary
    for (NSManagedObject *oc in productsObjects) {
        NSArray *keys = [[[oc entity] attributesByName] allKeys];
        NSDictionary *dict = [oc dictionaryWithValuesForKeys:keys];
        [products addObject:dict];
    }
    
    return products;
}

+(NSManagedObject *)getMOForSku:(NSString *)sku withMOC:(NSManagedObjectContext *)context {
    // Create Fetch Request
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Product"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"sku == %@",sku];
    [request setPredicate:pred];
    NSError *error;
    // Search and store
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"ERROR = %@",error);
        //abort();
    }
    if (array.count == 0 || array.count > 1) {
        NSLog(@"Array Failed!!!!!");
        //abort();
    }
    NSManagedObject *firstObject = array[0];
    return firstObject;
}







@end
