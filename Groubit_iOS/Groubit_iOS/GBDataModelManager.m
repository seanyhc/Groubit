//
//  HabitDataModel.m
//  Groubit_alpha
//
//  Created by Jeffrey on 7/26/11.
//  Copyright 2011 NTU. All rights reserved.
//

#import "GBDataModelManager.h"
#import "GBHabit.h"
#import "GBTask.h"
#import "Groubit_iOSAppDelegate.h"

@implementation GBDataModelManager

@synthesize objectContext;
@synthesize localUserName;

static GBDataModelManager* dataModel = nil; 

+(GBDataModelManager*) getDataModelManager
{
    if(dataModel == nil)
    {
        Groubit_iOSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
       
        dataModel = [[GBDataModelManager alloc] init];
        dataModel.objectContext = appDelegate.managedObjectContext;
        dataModel.localUserName = [NSString stringWithString:@"Alice"];
    }
    return dataModel;
}


- (bool) createHabit:(NSString*) habitName
       withStartDate:(NSDate*) habitStartDate
       withFrequency: (HabitFrequency)habitFrequency
        withAttempts: (int) attempts
{

    NSLog(@"Enter HabitDataModel::createHabit. habitName:%@, habitStartDate:%@, habitFrequency:%d, habitAttempts:%d",
          habitName,
          habitStartDate,
          habitFrequency,
          attempts);
    

    
    GBHabit* newHabit;
    newHabit = [NSEntityDescription insertNewObjectForEntityForName:@"GBHabit" inManagedObjectContext:objectContext];
    

    // j2do : create these value based on enum value    
    NSString* habitStatusStr = [NSString stringWithString:@"HABIT_STATUS_INIT"];
    NSString* habitFrequencyStr = [[NSString alloc]initWithString:@"weekly"];
    
    newHabit.HabitID = [[NSString alloc] initWithFormat:@"HABIT_%@",[GBDataModelManager createLocalUUID]];
    newHabit.HabitOwner = self.localUserName;
    newHabit.HabitName = habitName;
    newHabit.HabitFrequency = habitFrequencyStr;
    newHabit.HabitStatus = habitStatusStr;
    newHabit.HabitAttempts = [NSNumber numberWithInt:attempts];
    newHabit.HabitStartDate = habitStartDate;
    
    NSError *error;
    [objectContext save:&error];
    
    // j2do : Error Handling Here
    

    
    NSLog(@"New Habit[%@] Created", habitName);
    
    
    // Automatically create tasks
    
    NSArray* targetDates =nil;
    // calculate the targeted dates based on frequency
    targetDates = [self getTaskSchedule:habitStartDate withFrequency:habitFrequencyStr withAttempts:attempts];
    
    for(int i=0;i<[targetDates count];i++)
    {
        
        NSDate* target = (NSDate*) [targetDates objectAtIndex:i];
        //[self createTaskForHabit:habitName withHabitID:habitID withTaskOwner:habitOwner withTargetDate:target];
        [self createTaskForHabit:newHabit withTargetDate:target];
        
    }
    
    
    return true;
}



- (NSArray *) getAllHabitsByType:(GBUserType) userType
{
    NSLog(@"Enter HabitDataModel::getAllHabits. userType:%d",userType);
    
    NSArray *userNames = nil;
    if(userType == kUserTypeInternal){    

        userNames = [NSArray arrayWithObject:self.localUserName];
    
    }
    else if (userType == kUserTypeFriend){
    
        userNames = [self getFriendList];
    
    }else if (userType == kUserTypeALL){
    
        NSMutableArray *allUserName = [NSMutableArray arrayWithArray:[self getFriendList]];
        [allUserName addObject:self.localUserName];
        userNames = allUserName;        
    }
    
    NSArray *objects = [self getAllHabitsByOwnerNames:userNames];
    
    
    
    NSLog(@"Retrieved %d Habits", [objects count]);
    
              
    return objects;
}

- (NSArray *) getAllHabitsByOwnerName:(NSString*) ownerName
{
    
    NSLog(@"Enter HabitDataModel::getAllHabitsByOwnerName. ownerName:%@", ownerName);
    
    NSArray *nameArray = [NSArray arrayWithObject:ownerName];
    
  
    NSArray *objects = [self getAllHabitsByOwnerNames:nameArray];  
    NSLog(@"Retrieved %d Habits", [objects count]);
    
    return objects;    
}

- (NSArray *) getAllHabitsByOwnerNames:(NSArray*) ownerNames
{
    
    NSLog(@"Enter HabitDataModel::getAllHabitsByOwnerNames. ownerName Count:%d", ownerNames.count);
    
    NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:ownerNames.count];
    
    for(NSString* name in ownerNames){
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(HabitOwner = %@)", name];
        [predicates addObject:predicate];
    }

    
    NSPredicate* orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    
  
    NSArray *objects = [self queryManagedObject:kHabit withPredicate:orPredicate];
    
    [predicates release];
    
    NSLog(@"Retrieved %d Habits", [objects count]);
    
    return objects;    
}



// j2do
- (NSArray *) getMyNanniedHabits:(NSString*) friendName
{

    NSLog(@"Enter HabitDataModel::getAllHabitsByOwnerName. ownerName:%@", friendName);
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(HabitOwner = %@)", friendName];
    
    NSArray *objects = [self queryManagedObject:kHabit withPredicate:predicate];
    
    NSLog(@"Retrieved %d Habits", [objects count]);
    
    return objects;
}


// j2do
- (NSArray *) getMyBabyHabits:(NSString*) friendName
{

    return NULL;
}


// j2do
- (void) setHabitStatus: (NSString*) habitID 
             withStatus:(HabitStatus) habitStatus
{
    NSLog(@"Enter HabitDataModel::setHabitStatus. habitID: %@, habitStatus:%d", habitID, habitStatus);
        
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"GBHabit" inManagedObjectContext:objectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(HabitID = %@)", habitID];
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];

    if(!objects || objects.count == 0){
    
        
    }else if (objects.count > 1){
    
    }else{
        GBHabit *habit = (GBHabit*) [objects lastObject];
        habit.HabitStatus = [NSString stringWithString:@"HABIT_STATUS_COMPLETED"];
        [objectContext save:&error];
        
        if(!error){
            NSLog(@"Habit update successfully");
        }
    }
    
    [request release];
    
    
}


// j2do
- (void) deleteHabitByID:(NSString*)habitID
{

    NSEntityDescription* desc = [NSEntityDescription entityForName:@"GBHabit" inManagedObjectContext:objectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(HabitID = %@)", habitID];
    [request setPredicate:predicate];
    
    
    NSError *error;
    
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];

    
    for (int i=0; i< [objects count]; i++) {
        GBHabit* habit = (GBHabit*)[objects objectAtIndex:i];
        
        NSLog(@"Deleting Habit [%@]", habit.HabitName);
        [objectContext deleteObject:habit];   
        
    }
    
    [request release];
    
    
}

// j2do
- (void) deleteHabitByName:(NSString*)habitName
{
    /*

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
    */

}


// Task Related API


- (bool) createTaskForHabit: (GBHabit*) newHabit
             withTargetDate:(NSDate*) taskTargetDate
{

    
       
    GBTask* newTask = nil;
    newTask = [NSEntityDescription insertNewObjectForEntityForName:@"GBTask" inManagedObjectContext:objectContext];
    
    newTask.TaskID = [[NSString alloc] initWithFormat:@"TASK_%@",[GBDataModelManager createLocalUUID]];
    newTask.TaskStatus = [NSString stringWithString:@"TASK_STATUS_INIT"];
    newTask.TaskTargetDate = taskTargetDate;
    newTask.TaskName = [NSString stringWithFormat:@"TASK_@%",newTask.TaskID];
    newTask.belongsToHabit = newHabit;
  
    
    NSError *error;
    [objectContext save:&error];
    
    NSLog(@"New Task[%@] Created. Target Date: %@", newTask.TaskName, taskTargetDate);
    
    return true;
}


// j2do
- (void) setTaskStatus:(NSString*) taskID taskStatus:(TaskStatus) status{
    
    
    NSLog(@"Enter HabitDataModel::setHabitStatus. habitID: %@, habitStatus:%d", taskID, status);
    
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"GBTask" inManagedObjectContext:objectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(TaskID = %@)", taskID];
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];
    
    if(!objects || objects.count == 0){
        
        
    }else if (objects.count > 1){
        
    }else{
        GBTask *task = (GBTask*) [objects lastObject];
        task.TaskStatus = [NSString stringWithString:@"TASK_STATUS_COMPLETED"];
        [objectContext save:&error];
        
        if(!error){
            NSLog(@"Task update successfully");
        }
    }
    
    [request release];
    
    

    
    /*
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
    */
    
}

// j2do
- (NSArray *) getAllTasks:(GBUserType) userType
{
 
    
    NSLog(@"Enter HabitDataModel::getAllTasks. userType:%d",userType);
    
    NSPredicate *predicate;
    
    if(userType == kUserTypeInternal){    
        predicate = [NSPredicate predicateWithFormat:@"(belongsToHabit.HabitOwner = %@)", self.localUserName];
    }
    else{
        // j2do : get a list of friends
        return NULL;
    }
    
    NSArray *objects = [self queryManagedObject:kTask withPredicate:predicate];
    
    NSLog(@"Retrieved %d Tasks", [objects count]);
    
    
    return objects;

    
    return NULL;
}

// j2do
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
    return [NSArray arrayWithObjects:@"Jeffrey",@"Joey",@"Sean", nil];
    
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

- (NSArray*) getNannyNameList{
    
    // j2do : return the name of Nannies. 
    NSArray *result = [NSArray arrayWithObjects:@"Nanny1",@"Nanny2",@"Nanny3", nil];
    return result;
}

- (NSArray*) getBabyNameList{
    
    // j2do : return the name of Nannies. 
    NSArray *result = [NSArray arrayWithObjects:@"Baby1",@"Baby2",@"Baby3", nil];
    return result;
}


- (NSArray*)queryManagedObject: (GBObjectType)type withPredicate:(NSPredicate *)predicate
{
    
    NSLog(@"Enter HabitDataModel::queryManagedObject. type:%d, predicate:%@", type, predicate);
      

    // j2do : map different object type string    
    NSEntityDescription* desc = nil;
    
    if(type == kTask){
        desc = [NSEntityDescription entityForName:@"GBTask" inManagedObjectContext:objectContext];
    }else if(type == kHabit){
        desc = [NSEntityDescription entityForName:@"GBHabit" inManagedObjectContext:objectContext];
    }
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];

    [request setEntity:desc];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];
    

    if(!objects){
    
        NSLog(@"Error Querying Objects, Error:%@", [error localizedDescription]);
    }
    
    return objects;
}



+ (NSString *)createLocalUUID {
    
    
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    return (NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuid);
   }



@end
