//
//  ITAppDelegate.h
//  scan4PASE
//
//  Created by Dhruv Sringari on 8/25/13.
//  Copyright (c) 2013 Sringari Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Here are the Core Date Required Variables and Methods
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (BOOL)coreDataHasEntriesForEntityName:(NSString *)entityName;
-(void)resetCoreDataAndCustom:(BOOL)custom;


@end
