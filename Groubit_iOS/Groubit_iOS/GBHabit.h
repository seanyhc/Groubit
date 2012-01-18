//
//  GBHabit.h
//  Groubit_iOS
//
//  Created by Jeffrey on 1/18/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GBTask;

@interface GBHabit : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * HabitName;
@property (nonatomic, retain) NSString * HabitOwner;
@property (nonatomic, retain) NSString * HabitDescription;
@property (nonatomic, retain) NSString * HabitFrequency;
@property (nonatomic, retain) NSDate * HabitStartDate;
@property (nonatomic, retain) NSString * HabitStatus;
@property (nonatomic, retain) NSString * HabitID;
@property (nonatomic, retain) NSNumber * HabitAttempts;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface GBHabit (CoreDataGeneratedAccessors)

- (void)addTasksObject:(GBTask *)value;
- (void)removeTasksObject:(GBTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;
@end
