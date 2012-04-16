//
//  Groubit_iOSAppDelegate.h
//  Groubit_iOS
//
//  Created by Sean Chen on 12/28/11.
//  Copyright 2011 UCB MIMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterLoginViewController.h"

@interface Groubit_iOSAppDelegate : NSObject <UIApplicationDelegate> {
    UITabBarController *tabController;
    RegisterLoginViewController *loginViewController;
    
    NSString *localUserName;
}

@property (nonatomic, strong) NSString *localUserName;
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *tabController;
@property (nonatomic, strong) IBOutlet RegisterLoginViewController *loginViewController;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
