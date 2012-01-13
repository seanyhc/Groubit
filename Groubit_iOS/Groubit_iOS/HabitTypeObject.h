//
//  HabitTypeObject.h
//  Groubit_alpha
//
//  Created by Jeffrey on 7/26/11.
//  Copyright 2011 NTU. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HabitTypeObject : NSManagedObject { 
}

typedef enum {
    kHabitStatusInit = 0,
    kHabitStatusInProgress = 1,
    kHabitStatusCompleted = 2,
    kHabitStatusPending = 3,
    kHabitStatusIllegal = 4
} HabitStatus;

typedef enum {
    kDaily = 0,
    kWeekly = 1,
    kBiWeekly = 2,
    kMonthly = 3,
    kCustom = 4
} HabitFrequency;



@property (nonatomic, retain) NSString* HabitID;
@property (nonatomic, retain) NSString* HabitName;
@property (nonatomic, retain) NSString* HabitOwner;
@property (nonatomic, retain) NSDate*   HabitStartDate;
@property (nonatomic, retain) NSString* HabitFrequency;
@property (nonatomic, retain) NSNumber*  HabitAttempts;
@property (nonatomic, retain) NSString* HabitStatus;

- (NSString *) MyDescription;

@end
