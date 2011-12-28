//
//  TaskTypeObject.h
//  Groubit_alpha
//
//  Created by Jeffrey on 7/26/11.
//  Copyright 2011 NTU. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TaskTypeObject : NSManagedObject {
    
}


@property (nonatomic, retain) NSString* TaskID;
@property (nonatomic, retain) NSString* HabitName;
@property (nonatomic, retain) NSString* HabitID;
@property (nonatomic, retain) NSString* TaskOwner;
@property (nonatomic, retain) NSDate*   TaskTargetDate;
@property (nonatomic, retain) NSString* TaskStatus;

@end
