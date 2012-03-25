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
@property (nonatomic, strong) NSDate * createAt;
@property (nonatomic, strong) NSNumber * HabitAttempts;
@property (nonatomic, strong) NSString * HabitDescription;
@property (nonatomic, strong) NSString * HabitFrequency;
@property (nonatomic, strong) NSString * HabitID;
@property (nonatomic, strong) NSString * HabitName;
@property (nonatomic, strong) NSString * HabitOwner;
@property (nonatomic, strong) NSDate * HabitStartDate;
@property (nonatomic, strong) NSString * HabitStatus;
@property (nonatomic, strong) NSDate * updateAt;
@property (nonatomic, strong) GBUser *belongsToUser;
@property (nonatomic, strong) GBRelation *referencedByRelation;
@property (nonatomic, strong) NSSet *tasks;
@end

@interface GBHabit (CoreDataGeneratedAccessors)

- (void)addTasksObject:(GBTask *)value;
- (void)removeTasksObject:(GBTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;
@end
