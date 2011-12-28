//
//  HabitDataModel.h
//  Groubit_alpha
//
//  Created by Jeffrey on 7/26/11.
//  Copyright 2011 NTU. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HabitDataModel : NSObject {
    
}



+ (HabitDataModel*) getDataModel;


- (void) createHabit:(NSString*)habitID  
         withHabitOwner:(NSString*) habitOwner  
         withHabitName:(NSString*) habitName
         withHabitStartDate:(NSDate*) habitStartDate
         withHabitFrequency: (NSString*) habitFrequency
         withHabitAttempts: (int) attempts
         withHabitStatus:(NSString*) habitStatus;

- (void) deleteHabitByID:(NSString*)habitID;

- (void) deleteHabitByName:(NSString*)habitName;

- (NSArray*) getHabitsByOwner:(NSString*) habitOwner;

- (void) createTaskForHabit: (NSString*) habitName
             withHabitID:(NSString*) habitID
             withTaskOwner:(NSString*) taskOwner
             withTargetDate:(NSDate*) taskTargetDate;

- (void) markTaskCompletedByID:(NSString*) taskID;


//- (CHabitObject*) retrieveHabitWithOwner:(NSString*) habitOwner;

- (NSArray *) getTaskSchedule: (NSDate*) startDate withFrequency: (NSString*) frequency withAttempts: (int) attempts;


@end
