//
//  HabitTypeObject.m
//  Groubit_alpha
//
//  Created by Jeffrey on 7/26/11.
//  Copyright 2011 NTU. All rights reserved.
//

#import "HabitTypeObject.h"


@implementation HabitTypeObject

@dynamic HabitOwner;
@dynamic HabitID;
@dynamic HabitName;
@dynamic HabitStartDate;
@dynamic HabitFrequency;
@dynamic HabitAttempts;
@dynamic HabitStatus;


-(NSString *) MyDescription {
    return [NSString stringWithFormat:@"\nHabitID:%@ \nHabitName:%@ \nHabitOwner: %@\nHabitStartDate:%@ \nHabitFrequency:%@ \nHabitAttempts: %d\nHabitStatus:%@\n ", self.HabitID, self.HabitName, self.HabitOwner, self.HabitStartDate, self.HabitFrequency, self.HabitAttempts, self.HabitStatus];
}


@end
