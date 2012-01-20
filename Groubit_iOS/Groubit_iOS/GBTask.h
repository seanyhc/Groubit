//
//  GBTask.h
//  Groubit_iOS
//
//  Created by Jeffrey on 1/20/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GBHabit;

@interface GBTask : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * TaskID;
@property (nonatomic, retain) NSString * TaskName;
@property (nonatomic, retain) NSString * TaskStatus;
@property (nonatomic, retain) NSDate * TaskTargetDate;
@property (nonatomic, retain) GBHabit *belongsToHabit;

@end
