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

@property (nonatomic, strong) NSDate * createAt;
@property (nonatomic, strong) NSString * TaskID;
@property (nonatomic, strong) NSString * TaskName;
@property (nonatomic, strong) NSString * TaskStatus;
@property (nonatomic, strong) NSDate * TaskTargetDate;
@property (nonatomic, strong) NSDate * updateAt;
@property (nonatomic, strong) GBHabit *belongsToHabit;

@end
