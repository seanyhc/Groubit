//
//  GBHabit.h
//  Groubit_iOS
//
//  Created by Jeffrey on 1/20/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GBRelation, GBTask, GBUser;

@interface GBHabit : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * createAt;
@property (nonatomic, retain) NSNumber * HabitAttempts;
@property (nonatomic, retain) NSString * HabitDescription;
@property (nonatomic, retain) NSString * HabitFrequency;
@property (nonatomic, retain) NSString * HabitID;
@property (nonatomic, retain) NSString * HabitName;
@property (nonatomic, retain) NSString * HabitOwner;
@property (nonatomic, retain) NSDate * HabitStartDate;
@property (nonatomic, retain) NSString * HabitStatus;
@property (nonatomic, retain) NSDate * updateAt;
@property (nonatomic, retain) GBUser *belongsToUser;
@property (nonatomic, retain) GBRelation *referencedByRelation;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface GBHabit (CoreDataGeneratedAccessors)

- (void)addTasksObject:(GBTask *)value;
- (void)removeTasksObject:(GBTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;
@end
