//
//  GBTask.h
//  Groubit_iOS
//
//  Created by Jeffrey on 3/10/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GBHabit;

@interface GBTask : NSManagedObject

@property (nonatomic, retain) NSDate * createAt;
@property (nonatomic, retain) NSString * TaskID;
@property (nonatomic, retain) NSString * TaskName;
@property (nonatomic, retain) NSString * TaskStatus;
@property (nonatomic, retain) NSDate * TaskTargetDate;
@property (nonatomic, retain) NSDate * updateAt;
@property (nonatomic, retain) GBHabit *belongsToHabit;

@end
