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
#import "Groubit_alphaAppDelegate.h"

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


- (void) createHabit:(NSString*)habitID  
         withHabitOwner:(NSString*) habitOwner  
         withHabitName:(NSString*) habitName
         withHabitStartDate:(NSDate*) habitStartDate
         withHabitFrequency: (NSString*) habitFrequency
         withHabitAttempts: (int) attempts
         withHabitStatus:(NSString*) habitStatus
{
    
    Groubit_alphaAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];


    NSManagedObjectContext* objectContext = [appDelegate managedObjectContext];
    
    NSManagedObject* newHabit;
    newHabit = [NSEntityDescription insertNewObjectForEntityForName:@"HabitType" inManagedObjectContext:objectContext];
    
    [newHabit setValue:habitID forKey:@"HabitID"];
    [newHabit setValue:habitName forKey:@"HabitName"];
    [newHabit setValue:habitOwner forKey:@"HabitOwner"];
    [newHabit setValue:habitFrequency forKey:@"HabitFrequency"];
    [newHabit setValue:[NSNumber numberWithInt:attempts] forKey:@"HabitAttempts"];
    [newHabit setValue:habitStartDate forKey:@"HabitStartDate"];
    [newHabit setValue:habitStatus forKey:@"HabitStatus"];
    
    NSError *error;
    [objectContext save:&error];
    
    NSLog(@"New Habit[%@] Stored", habitName);
    
    
    // Automatically create tasks
    
    
    NSArray* targetDates =nil;
    targetDates = [self getTaskSchedule:habitStartDate withFrequency:habitFrequency withAttempts:attempts];
        
    for(int i=0;i<[targetDates count];i++)
    {

        NSDate* target = (NSDate*) [targetDates objectAtIndex:i];
        [self createTaskForHabit:habitName withHabitID:habitID withTaskOwner:habitOwner withTargetDate:target];
        
    }
    
}


- (void) deleteHabitByID:(NSString*)habitID
{
    
    Groubit_alphaAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
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

    Groubit_alphaAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
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


- (NSArray*) getHabitsByOwner:(NSString*) habitOwner
{

    Groubit_alphaAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* objectContext = [appDelegate managedObjectContext];
    NSEntityDescription* desc = [NSEntityDescription entityForName:@"HabitType" inManagedObjectContext:objectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(HabitOwner = %@)", habitOwner];
    [request setPredicate:predicate];
    
    
    NSError *error;
    
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];
    
    NSMutableArray *array = [[NSMutableArray alloc] init ];
    
    for (int i=0; i<[objects count]; i++) {
        HabitTypeObject* habit = (HabitTypeObject*)[objects objectAtIndex:i];
        [array addObject:habit];
    }

    return array;
}


- (void) createTaskForHabit: (NSString*) habitName
             withHabitID:(NSString*) habitID
             withTaskOwner:(NSString*) taskOwner
             withTargetDate:(NSDate*) taskTargetDate
{

    // generate task ID
    NSString* taskID = nil;
    
    
    
    Groubit_alphaAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    NSManagedObjectContext* objectContext = [appDelegate managedObjectContext];
    
    NSManagedObject* newTask;
    newTask = [NSEntityDescription insertNewObjectForEntityForName:@"TaskType" inManagedObjectContext:objectContext];
    
    [newTask setValue:taskID forKey:@"TaskID"];
    [newTask setValue:habitName forKey:@"HabitName"];
    [newTask setValue:habitID forKey:@"HabitID"];
    [newTask setValue:taskOwner forKey:@"TaskOwner"];
    [newTask setValue:taskTargetDate forKey:@"TaskTargetDate"];
    [newTask setValue:@"INIT" forKey:@"TaskStatus"];
      
    NSError *error;
    [objectContext save:&error];
    
    NSLog(@"New Task[%@] Stored", taskID);
    
    
}

- (void) markTaskCompletedByID:(NSString*) taskID{

    Groubit_alphaAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
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


@end
