//
//  HabitDataModel.m
//  Groubit_alpha
//
//  Created by Jeffrey on 7/26/11.
//  Copyright 2011 NTU. All rights reserved.
//

#import "HabitDataModel.h"
#import "HabitTypeObject.h"
#import "TaskTypeObject.h"
#import "Groubit_iOSAppDelegate.h"

@implementation HabitDataModel



static HabitDataModel* dataModel = nil; 

+(HabitDataModel*) getDataModel
{
    if(dataModel == nil)
    {
        dataModel = [[HabitDataModel alloc] init];
    }
    return dataModel;
}


- (bool) createHabit:(NSString*) habitName
       withStartDate:(NSDate*) habitStartDate
       withFrequency: (HabitFrequency)habitFrequency
        withAttempts: (int) attempts
{

    Groubit_iOSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    NSManagedObjectContext* objectContext = [appDelegate managedObjectContext];
    
    NSManagedObject* newHabit;
    newHabit = [NSEntityDescription insertNewObjectForEntityForName:@"HabitTypeObject" inManagedObjectContext:objectContext];
    
    
    
    // Prepare values 
    // j2do : auto-gen these values
    
    //NSString* habitID     = [NSString stringWithString:@"12345"];
    NSString* habitID     = [[NSString alloc] initWithFormat:@"HABIT_%@",[HabitDataModel createLocalUUID]];
    
    NSLog(@"HABIT_ID:%@", habitID);
    
    NSString* habitOwner  = [NSString stringWithString:@"Bob"];
    NSString* habitStatus = [NSString stringWithString:@"HABIT_INIT"];
    NSString* habitFrequencyStr = [[NSString alloc]initWithString:@"weekly"];
    
    
    
    [newHabit setValue:habitID forKey:@"HabitID"];
    [newHabit setValue:habitName forKey:@"HabitName"];
    [newHabit setValue:habitOwner forKey:@"HabitOwner"];
    [newHabit setValue:habitFrequencyStr forKey:@"HabitFrequency"];
    [newHabit setValue:[NSNumber numberWithInt:attempts] forKey:@"HabitAttempts"];
    [newHabit setValue:habitStartDate forKey:@"HabitStartDate"];
    [newHabit setValue:habitStatus forKey:@"HabitStatus"];
    
    NSError *error;
    [objectContext save:&error];
    
    // j2do : Error Handling Here
    

    
    NSLog(@"New Habit[%@] Stored", habitName);
    
    
    // Automatically create tasks
    
    NSArray* targetDates =nil;
    // calculate the targeted dates based on frequency
    targetDates = [self getTaskSchedule:habitStartDate withFrequency:habitFrequencyStr withAttempts:attempts];
    
    for(int i=0;i<[targetDates count];i++)
    {
        
        NSDate* target = (NSDate*) [targetDates objectAtIndex:i];
        [self createTaskForHabit:habitName withHabitID:habitID withTaskOwner:habitOwner withTargetDate:target];
        
    }
    
    
    return true;
}


- (NSArray *) getAllHabits:(int) userType
{

    return NULL;
}

- (NSArray *) getAllHabitsByOwnerName:(NSString*) ownerName
{
    
    
    Groubit_iOSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* objectContext = [appDelegate managedObjectContext];
    NSEntityDescription* desc = [NSEntityDescription entityForName:@"HabitTypeObject" inManagedObjectContext:objectContext];
    
    
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(HabitOwner = %@)", ownerName];
    [request setPredicate:predicate];
    
    
    NSError *error;
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];
    
    // j2do : Error Handling Here
    
    
    // j2do auto release 
    NSMutableArray *array = [[NSMutableArray alloc] init ];
    
    for (int i=0; i<[objects count]; i++) {
        HabitTypeObject* habit = (HabitTypeObject*)[objects objectAtIndex:i];
        [array addObject:habit];
    }
    
    return array;
}

- (NSArray *) getMyNanniedHabits:(NSString*) friendName
{

    return NULL;
}

- (NSArray *) getMyBabyHabits:(NSString*) friendName
{

    return NULL;
}

- (void) setHabitStatus: (NSString*) habitID 
             withStatus:(HabitStatus) habitStatus
{

}

- (void) deleteHabitByID:(NSString*)habitID
{
    
    Groubit_iOSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* objectContext = [appDelegate managedObjectContext];
    NSEntityDescription* desc = [NSEntityDescription entityForName:@"HabitType" inManagedObjectContext:objectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(HabitID = %@)", habitID];
    [request setPredicate:predicate];
    
    
    NSError *error;
    
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];

    
    for (int i=0; i< [objects count]; i++) {
        HabitTypeObject* habit = (HabitTypeObject*)[objects objectAtIndex:i];
        
        NSLog(@"Deleting Habit [%@]", habit.HabitName);
        [objectContext deleteObject:habit];   
        
    }
    
    
}

- (void) deleteHabitByName:(NSString*)habitName
{

    Groubit_iOSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* objectContext = [appDelegate managedObjectContext];
    NSEntityDescription* desc = [NSEntityDescription entityForName:@"HabitType" inManagedObjectContext:objectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(HabitName = %@)", habitName];
    [request setPredicate:predicate];
    
    
    NSError *error;
    
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];
    
    
    for (int i=0; i< [objects count]; i++) {
        HabitTypeObject* habit = (HabitTypeObject*)[objects objectAtIndex:i];
        
        NSLog(@"Deleting Habit [%@]", habit.HabitName);
        [objectContext deleteObject:habit];   
        
    }
    

}


// Task Related API


- (bool) createTaskForHabit: (NSString*) habitName
                withHabitID:(NSString*) habitID
              withTaskOwner:(NSString*) taskOwner
             withTargetDate:(NSDate*) taskTargetDate
{

    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *taskID = [[NSString alloc] initWithFormat:@"TASK_%@",[HabitDataModel createLocalUUID]];
    
    
    
    
    Groubit_iOSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    NSManagedObjectContext* objectContext = [appDelegate managedObjectContext];
    
    NSManagedObject* newTask;
    newTask = [NSEntityDescription insertNewObjectForEntityForName:@"TaskTypeObject" inManagedObjectContext:objectContext];
    
    [newTask setValue:taskID forKey:@"TaskID"];
    [newTask setValue:habitName forKey:@"HabitName"];
    [newTask setValue:habitID forKey:@"HabitID"];
    [newTask setValue:taskOwner forKey:@"TaskOwner"];
    [newTask setValue:taskTargetDate forKey:@"TaskTargetDate"];
    [newTask setValue:@"INIT" forKey:@"TaskStatus"];
    
    NSError *error;
    [objectContext save:&error];
    
    NSLog(@"New Task[%@] Created. Target Date: %@", taskID, taskTargetDate);
    
    return true;
}


- (void) markTaskCompletedByID:(NSString*) taskID{

    Groubit_iOSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* objectContext = [appDelegate managedObjectContext];
    NSEntityDescription* desc = [NSEntityDescription entityForName:@"TaskType" inManagedObjectContext:objectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(TaskID = %@)", taskID];
    [request setPredicate:predicate];
    
    
    NSError *error;
    
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];
    
    
    if([objects count] >0) {
        TaskTypeObject* habit = (TaskTypeObject*)[objects objectAtIndex:0];
        
        habit.TaskStatus = [[NSString alloc ] initWithString:@"Completed"];
        
        NSLog(@"Complete task [%@]", taskID);
        [objectContext save:&error];   
        
    }
    
}


- (NSArray *) getAllTasks:(int) userType
{
    
    return NULL;
}

- (NSArray *) getMyBabyTasks
{

    return NULL;
}



// USER RELATED API

- (bool) createLocalUser: (NSString *) ownerName
            withNickName: (NSString*) nickName 
            withPassword: (NSString*) password
{

    return false;
}

- (bool) createFriend: (NSString*) email
{
    return false;
}

- (bool) createNanny: (NSString*) UserID withHabitID:(NSString*) HabitID
{

    return false;
}

- (NSArray *) getFriendList
{

    return NULL;
}

- (NSArray *) getNannyList
{
    return NULL;
}


// INTERNAL HELPER FUNCTIONS

- (NSArray *) getTaskSchedule: (NSDate*) startDate withFrequency: (NSString*) frequency withAttempts: (int) attempts
{
    NSMutableArray *array = [[NSMutableArray alloc] init ];
    
    NSTimeInterval dailyInterval = 60 * 60 * 24; // 86400
    NSTimeInterval weeklyInterval = dailyInterval * 7;  
    
    // Create a list of NSDate objects
    
    if ( [frequency caseInsensitiveCompare:@"daily"] == 0){
        
        
        for (int i =1; i<=attempts; i++) {
            NSDate* newDate = [startDate dateByAddingTimeInterval:(dailyInterval*i)];
            [array addObject:newDate];
        }
        
    }else if ([frequency caseInsensitiveCompare:@"weekly"] == 0){
        
        for (int i =1; i<=attempts; i++) {
            NSDate* newDate = [startDate dateByAddingTimeInterval:(weeklyInterval * i)];
            [array addObject:newDate];
        }
        
    }else if ([frequency caseInsensitiveCompare:@"monthly"] == 0){
        
        NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
        NSCalendar *cal = [NSCalendar currentCalendar];
        
        
        
        for (int i =1; i<=attempts; i++) {
            [comps setMonth:i];   
            NSDate *newDate = [cal dateByAddingComponents:comps toDate:startDate options:0];
            [array addObject:newDate];
        }
        
    }
    
    for (int i=0;i<attempts;i++){
        
        NSDate* date = (NSDate*)[array objectAtIndex:i];
        NSLog(@"new date %@",[date descriptionWithLocale:@"yy-mm-dd"]);
    }
    
    return array;
}

+ (NSString *)createLocalUUID {
    
    
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    return (NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuid);
   }



@end
