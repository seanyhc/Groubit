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

@property (nonatomic, strong) NSDate * createAt;
@property (nonatomic, strong) NSString * fromUser;
@property (nonatomic, strong) NSString * notificationID;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSString * toUser;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSDate * updateAt;

@end
