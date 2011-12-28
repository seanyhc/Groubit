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

@property (nonatomic, retain) NSString* HabitID;
@property (nonatomic, retain) NSString* HabitName;
@property (nonatomic, retain) NSString* HabitOwner;
@property (nonatomic, retain) NSDate*   HabitStartDate;
@property (nonatomic, retain) NSString* HabitFrequency;
@property (nonatomic, retain) NSNumber*  HabitAttempts;
@property (nonatomic, retain) NSString* HabitStatus;


@end
