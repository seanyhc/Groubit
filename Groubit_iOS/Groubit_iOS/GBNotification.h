//
//  GBNotification.h
//  Groubit_iOS
//
//  Created by Jeffrey on 3/15/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GBNotification : NSManagedObject

@property (nonatomic, retain) NSDate * createAt;
@property (nonatomic, retain) NSString * fromUser;
@property (nonatomic, retain) NSString * notificationID;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * toUser;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updateAt;

@end
