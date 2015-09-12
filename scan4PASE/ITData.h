//
//  ITData.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 11/6/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITViewController.h"
#import <CoreData/CoreData.h>
@class ITData;
@interface ITData : NSObject {
}

+(NSArray *)getAllProducts;
+(NSMutableArray *)searchProducts:(NSString *)searchtext;
+(ITData *)getInstance;
-(void)changeQuantityTo:(NSString *)quantity;
-(void)setCurrentProduct:(NSMutableDictionary *)current;
+(NSManagedObject *)getMOForSku:(NSString *)sku withMOC:(NSManagedObjectContext *)context;


@property(nonatomic, retain) NSMutableArray *cartProducts;
@property(nonatomic, retain) NSMutableDictionary *currentProduct;
@property(nonatomic, retain) NSString *test;

@end
