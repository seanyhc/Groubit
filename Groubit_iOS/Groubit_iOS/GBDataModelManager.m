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
#import "GBUser.h"
#import "GBRelation.h"
#import "GBNotification.h"
#import "Parse/Parse.h"
#import "Groubit_iOSAppDelegate.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation GBDataModelManager

@synthesize objectContext;
@synthesize localUserName;
@synthesize localUserID;

static GBDataModelManager* dataModel = nil; 

static NSArray *sHabitFrequencyStr;
static NSArray *sHabitStatusStr;
static NSArray *sTaskStatusStr;
static NSArray *sRelationStr;
static NSArray *sRelationStatusStr;
static NSArray *sNotificationTypeStr;
static NSArray *sNotificationStatusStr;



-(id) init{
    
    self = [super init];
    
    sHabitStatusStr = [[NSArray alloc] initWithObjects:@"init",
                                                       @"inProgress",
                                                       @"completed",
                                                       @"pending",
                                                       @"illegal", nil];
    
    sTaskStatusStr = [[NSArray alloc] initWithObjects:@"init",
                                                      @"completed",
                                                      @"illegal", nil];
    
    sHabitFrequencyStr = [[NSArray alloc] initWithObjects:@"daily",
                                                          @"weekly",
                                                          @"biweekly",
                                                          @"monthly",
                                                          @"custom", nil ];
    
    sRelationStr = [[NSArray alloc] initWithObjects:@"friend",
                                                    @"nanny", nil];
    
    sRelationStatusStr = [[NSArray alloc] initWithObjects:@"pending",
                                                          @"confirmed",
                                                          @"rejected",nil];
    
    
    sNotificationTypeStr = [[NSArray alloc] initWithObjects:@"friendRequest",
                                                            @"friendConfirmation",
                                                            @"nannyRequest",
                                                            @"nannyConfirmation",
                                                            @"reminder",
                                                            nil];
    
    sNotificationStatusStr = [[NSArray alloc] initWithObjects:@"new",
                                                              @"viewed",
                                                              nil];
    
    
    Groubit_iOSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.objectContext = appDelegate.managedObjectContext;

    return self;
}


+(GBDataModelManager*) getDataModelManager
{
    if(dataModel == nil)
    {
        dataModel = [[GBDataModelManager alloc] init];
    }
    return dataModel;
}


- (void) SycnData
{
    
    NSError *error;
    
    if(objectContext)
        [objectContext save:&error];
    
    if(error){
    
        DDLogError(@"Sync Context Error: %@", error); 
        
    }
    
}




#pragma mark - 
#pragma mark HABIT RELATED FUNCTION
#pragma mark - 


// SYNC FUNCTION
- (bool) createHabitWithRemoteHabit: (PFObject*) remoteHabit
{
    DDLogVerbose (@"Enter HabitDataModel::createHabitWithRemoteHabit. remoteHabit:%@", remoteHabit);

    GBHabit* newHabit;
    GBUser *habitOwner;
    
    habitOwner= [self getUserByID:[remoteHabit objectForKey:@"HabitOwner"]];    
    if(!habitOwner){
        DDLogError(@"Cannot retrieve habit owner");
        return false;
    }
    
    newHabit = [NSEntityDescription insertNewObjectForEntityForName:@"GBHabit" inManagedObjectContext:objectContext];
    
    newHabit.HabitID           = [remoteHabit objectForKey:@"HabitID"];
    newHabit.HabitOwner        = [remoteHabit objectForKey:@"HabitOwner"];
    newHabit.HabitName         = [remoteHabit objectForKey:@"HabitName"];
    newHabit.HabitStatus       = [remoteHabit objectForKey:@"HabitStatus"];
    newHabit.HabitFrequency    = [remoteHabit objectForKey:@"HabitFrequency"];
    newHabit.HabitAttempts     = [remoteHabit objectForKey:@"HabitAttempts"];
    newHabit.HabitStartDate    = [remoteHabit objectForKey:@"HabitStartDate"];
    newHabit.belongsToUser     = habitOwner;
    newHabit.HabitDescription  = [remoteHabit objectForKey:@"HabitDescription"];
    newHabit.createAt          = remoteHabit.createdAt;
    newHabit.updateAt          = remoteHabit.updatedAt;

    
    NSError *error;
    [objectContext save:&error];
    
    // j2do : Error Handling Here
    
    
    
    DDLogInfo(@"New Habit[%@] Created", newHabit.HabitName);
    

    return true;
}

- (bool) createHabitForUserWithNanny:(NSString*) userID
                            withName:(NSString*) habitName
                            withNannyID: (NSString*) nannyID
                            withStartDate:(NSDate*) habitStartDate
                            withFrequency: (HabitFrequency)habitFrequency
                            withAttempts: (int) attempts
                            withDescription:(NSString*) desc{

    DDLogVerbose (@"Enter HabitDataModel::createHabitForUserWithNanny. userID:%@, habitName:%@, nannyID:%@,habitStartDate:%@, habitFrequency:%d, habitAttempts:%d, habitDesc:%@",
          userID,
          habitName,
          nannyID,
          habitStartDate,
          habitFrequency,
          attempts,
          desc);

    GBUser *habitOwner;

    habitOwner= [self getUserByID:userID];    
    if(!habitOwner){
        DDLogError (@"Cannot retrieve habit owner");
        return false;
    }
    
    
    GBHabit* newHabit;
    newHabit = [NSEntityDescription insertNewObjectForEntityForName:@"GBHabit" inManagedObjectContext:objectContext];
    
    
    NSString* habitStatusStr = [NSString stringWithString:[sHabitStatusStr objectAtIndex:kHabitStatusInit]];
    NSString* habitFrequencyStr = [[NSString alloc]initWithString:[sHabitFrequencyStr objectAtIndex:habitFrequency]];
    
    newHabit.HabitID = [NSString stringWithFormat:@"HABIT_%@",[GBDataModelManager createLocalUUID]];
    newHabit.HabitOwner = userID;
    newHabit.HabitName = habitName;
    newHabit.HabitFrequency = habitFrequencyStr;
    newHabit.HabitStatus = habitStatusStr;
    newHabit.HabitAttempts = [NSNumber numberWithInt:attempts];
    newHabit.HabitStartDate = habitStartDate;
    newHabit.belongsToUser = habitOwner;
    newHabit.HabitDescription = desc;
    newHabit.updateAt = newHabit.createAt = [NSDate date];

    NSError *error;
    if(![objectContext save:&error]){
    
        DDLogError(@"Failed to save create habit, %@, %@", error, [error userInfo]);
        return false;
    }
    
    
    
    DDLogInfo (@"New Habit[%@] Created", habitName);
    
    
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
    
    // etup relationship with Nanny
    if(nannyID){
        if(![self createNanny:nannyID withHabitID:newHabit.HabitID]){
            return false;
        }
        
    }
    
    return true;
  
}



- (NSArray *) getAllHabitsByType:(GBUserType) userType
{
    DDLogVerbose (@"Enter HabitDataModel::getAllHabits. userType:%d",userType);
    
    NSArray *userNames = nil;
    
    if(userType == kUserTypeInternal){    

        userNames = [NSArray arrayWithObject:self.localUserID];
    
    }
    else if (userType == kUserTypeFriend){
    
        userNames = [self getFriendList];
    
    }else if (userType == kUserTypeALL){
    
        NSMutableArray *allUserName = [NSMutableArray arrayWithArray:[self getFriendList]];
        [allUserName addObject:self.localUserID];
        userNames = allUserName;        
    }
    
    NSArray *objects = [self getAllHabitsByUserIDs:userNames];
    
    
    
    DDLogVerbose (@"Retrieved %d Habits", [objects count]);
    
              
    return objects;
}


- (NSArray *) getAllHabitsByUserID:(NSString*) userID
{
    
    DDLogVerbose(@"Enter HabitDataModel::getAllHabitsByUserID. userID :%@", userID);
    
    NSArray *nameArray = [NSArray arrayWithObject:userID];
      
    NSArray *objects = [self getAllHabitsByUserIDs:nameArray];  
    DDLogVerbose(@"Retrieved %d Habits", [objects count]);
    
    return objects;    
}


- (NSArray *) getAllHabitsByUserIDs:(NSArray*) userIDs
{
    
    DDLogVerbose (@"Enter HabitDataModel::getAllHabitsByUserIDs. userID Count:%d", userIDs.count);
    
    NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:userIDs.count];
    
    for(NSString* name in userIDs){
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(HabitOwner = %@)", name];
        [predicates addObject:predicate];
    }

    
    NSPredicate* orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    
  
    NSArray *objects = [self queryManagedObject:kHabit withPredicate:orPredicate];
    
    
    DDLogVerbose (@"Retrieved %d Habits", [objects count]);
    
    return objects;    
}


- (GBHabit*) getHabitByID : (NSString*) habitID{
    
    DDLogVerbose (@"Enter HabitDataModel::getHabitByID. haibtID:%@",habitID);
    
    
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"(HabitID = %@)", habitID];
    
    NSArray *objects = [self queryManagedObject:kHabit withPredicate:predicate];
    
    DDLogVerbose (@"Retrieved %d habits", [objects count]);
    
    if( objects.count == 0){
        
        DDLogInfo (@"No user habit retrieved");
        return nil;
        
    }else if (objects.count > 1){
        
        DDLogWarn (@"More than 1 habit object retrieved. Return the first one");
    } 
    
    return [objects objectAtIndex:0];
    
}



- (void) setHabitStatus: (NSString*) habitID 
             withStatus:(HabitStatus) habitStatus
{
    DDLogVerbose (@"Enter HabitDataModel::setHabitStatus. habitID: %@, habitStatus:%d", habitID, habitStatus);
        
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"GBHabit" inManagedObjectContext:objectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(HabitID = %@)", habitID];
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];

    
    
    if(!objects || objects.count == 0){
    
        DDLogWarn(@" No Habit with habit id %@ retrieved", habitID);
        
    }else if (objects.count > 1){
    
        DDLogWarn(@" Can't uniquely identify a habit. Habit id %@ ", habitID);
        
    }else{
        
        GBHabit *habit = (GBHabit*) [objects lastObject];
        habit.HabitStatus = [NSString stringWithString:[sHabitStatusStr objectAtIndex:kHabitStatusInProgress]];
        if(![objectContext save:&error]){
            
            DDLogError(@" Failed to update habit status %@, %@", error, [error userInfo]);
        }
    }
    
    
}


- (void) deleteHabitByID:(NSString*)habitID
{
    
    DDLogVerbose (@"Enter HabitDataModel::deleteHabitByID. habitID: %@", habitID);
    
    NSEntityDescription* desc = [NSEntityDescription entityForName:@"GBHabit" inManagedObjectContext:objectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(HabitID = %@)", habitID];
    [request setPredicate:predicate];
    
    
    NSError *error;
    
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];

    
    for (int i=0; i< [objects count]; i++) {
        GBHabit* habit = (GBHabit*)[objects objectAtIndex:i];
        
        DDLogInfo (@"Deleting Habit [%@]", habit.HabitName);
        [objectContext deleteObject:habit];   
    }
    
}




#pragma mark - 
#pragma mark TASK RELATED FUNCTION
#pragma mark - 

- (bool) createTaskForHabit: (GBHabit*) newHabit
             withTargetDate:(NSDate*) taskTargetDate
{

    DDLogVerbose (@"Enter HabitDataModel::createTaskForHabit. habitID: %@, target date:%@", newHabit.HabitID, taskTargetDate);
    
       
    GBTask* newTask = nil;
    newTask = [NSEntityDescription insertNewObjectForEntityForName:@"GBTask" inManagedObjectContext:objectContext];
    
    newTask.TaskID = [NSString stringWithFormat:@"TASK_%@",[GBDataModelManager createLocalUUID]];
    newTask.TaskStatus = [NSString stringWithString:[sTaskStatusStr objectAtIndex:kTaskStatusInit]];
    newTask.TaskTargetDate = taskTargetDate;
    newTask.TaskName = [NSString stringWithFormat:@"TASK_%@",newTask.TaskID];
    newTask.belongsToHabit = newHabit;
    newTask.createAt = newTask.updateAt = [NSDate date];
    
    NSError *error;
    if(![objectContext save:&error]){
        DDLogError(@" Failed to create task for Haibt. %@, %@", error, [error userInfo]);
        return false;
    }
    
    DDLogInfo (@"New Task[%@] Created. Target Date: %@", newTask.TaskName, taskTargetDate);
    
    return true;
}


- (NSArray *) getTasksWithHabitID:(NSString*) habitID{

    DDLogVerbose (@"Enter HabitDataModel::getTasksWithHabitID. habitID:%@",habitID);
    
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"(belongsToHabit.HabitID = %@)", habitID];
    
    NSArray *objects = [self queryManagedObject:kTask withPredicate:predicate];
    
    DDLogVerbose (@"Retrieved %d Tasks", [objects count]);
    
    return objects;
}


- (bool) createTaskWithRemoteTask: (PFObject*) remoteTask
{

    DDLogVerbose (@"Enter HabitDataModel::createTaskWithRemoteTask. remote task: %@", remoteTask);
    
    GBHabit *newHabit = [dataModel getHabitByID:[remoteTask objectForKey:@"HabitID"]];
    
    if(!newHabit){
        DDLogError (@"Can not retrive associated habit");
        return false;
    }
                      
                      
    GBTask* newTask = nil;
    newTask = [NSEntityDescription insertNewObjectForEntityForName:@"GBTask" inManagedObjectContext:objectContext];
    
    newTask.TaskID = [remoteTask objectForKey:@"TaskID"];
    newTask.TaskStatus = [remoteTask objectForKey:@"TaskStatus"];
    newTask.TaskTargetDate = [remoteTask objectForKey:@"TaskTargetStatus"];
    newTask.TaskName = [remoteTask objectForKey:@"TaskName"];
    
    newTask.belongsToHabit = newHabit;
    newTask.createAt = remoteTask.createdAt;
    newTask.updateAt = remoteTask.updatedAt;
    
    NSError *error;
    if(![objectContext save:&error]){
        DDLogError(@"Failed to create local object with remote object. %@,%@", error, [error userInfo]);
        return false;
    }
    
    DDLogInfo(@"New Task[%@] Created. Target Date: %@", newTask.TaskName, newTask.TaskTargetDate);
    
    return true;
}



- (void) setTaskStatus:(NSString*) taskID taskStatus:(TaskStatus) status{
    
    
    DDLogVerbose (@"Enter HabitDataModel::setHabitStatus. habitID: %@, habitStatus:%d", taskID, status);
    
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"GBTask" inManagedObjectContext:objectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(TaskID = %@)", taskID];
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];
    
    if(!objects || objects.count == 0){
        
        
        DDLogWarn(@" No Task with task id %@ retrieved", taskID);
        
    }else if (objects.count > 1){
        
        
        DDLogWarn(@" Can't uniquely identify a Task with task id : %@", taskID);
        
    }else{
        GBTask *task = (GBTask*) [objects lastObject];
        task.TaskStatus = [NSString stringWithString:[sTaskStatusStr objectAtIndex:status]];
        if(![objectContext save:&error]){
        
            DDLogError(@" Failed to set task status. Task ID : %@", taskID);
        }
            
    }
    
}


- (NSArray *) getAllTasksByUserType:(GBUserType)userType
{
 
    
    DDLogVerbose (@"Enter HabitDataModel::getAllTasksByUserType. userType:%d",userType);
    
    NSMutableArray *allTasks = [NSMutableArray array];
    
    NSArray *allHabits = [self getAllHabitsByType:userType];
    
    
    for( GBHabit *habit in allHabits){
    
        NSArray *tasks = [self getTasksWithHabitID:habit.HabitID];
        
        for (GBTask *task in tasks){
            [allTasks addObject:task];
        }
    }
    
    
    
    DDLogVerbose(@"Retrieved %d Tasks", [allTasks count]);
    
    
    return allTasks;

}

- (NSArray *) getTasksWithPeriod: (NSString*) userID withStartDateIndex: (int) startDate withEndDateIndex: (int) endDate
{
    DDLogVerbose(@"Enter HabitDataModel::getTasksWithPeriod. userID:%@, withStartDateIndex:%d, withEndDateIndex:%d",userID, startDate, endDate);
    
    // calculate start date and end date. 
  
    NSDate *start = [self getDateFloor:[self getDateWithIndex:startDate]];
    
    NSDate *end   = [self getDateCeil:[self getDateWithIndex:endDate]];
   
    
    DDLogVerbose(@" Start Date : %@, End Date : %@", start, end);
    
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"(TaskTargetDate >= %@ AND TaskTargetDate <= %@ AND belongsToHabit.HabitOwner = %@)", start, end, localUserID];
    
    
    NSArray *objects = [self queryManagedObject:kTask withPredicate:timePredicate];
    
    DDLogVerbose(@"Retrieved %d Tasks", [objects count]);
    
    return objects;
    
}

- (NSArray *) getRecentTaskByUserType: (GBUserType) userType withPeriod:(int)days
{
    DDLogVerbose(@"Enter HabitDataModel::getRecentTaskByUserType. userType:%d, withPeriod:%d",userType, days);
    
    NSArray* userNameList = nil;
    
    if( userType == kUserTypeInternal ){
    
        userNameList = [NSArray arrayWithObject:localUserID];
        
    }else if (userType == kUserTypeBaby){
    
        userNameList = [self getNannyList];
    
    }else{
    
        // J2DO : we might support get task by type for friends (and all)
        return nil;
    }
    
    
    //NSPredicate *predicate;
    
    NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:userNameList.count];
    
    for(NSString* name in userNameList){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(belongsToHabit.HabitOwner = %@)", name];
        [predicates addObject:predicate];
    }
    
    
    NSPredicate* orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    
    
    
    NSDate *now = [NSDate date];
    NSDate *target = [NSDate dateWithTimeIntervalSinceNow:(days*24*60*60)];
    
    NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"(TaskTargetDate >= %@ AND TaskTargetDate <= %@)", now, target];
    
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:orPredicate, timePredicate, nil]];
    
    DDLogVerbose(@"Query Predicate : %@", andPredicate);
    
    NSArray *objects = [self queryManagedObject:kTask withPredicate:andPredicate];
    
    DDLogVerbose(@"Retrieved %d Tasks", [objects count]);
    
    return objects;
}


#pragma mark - 
#pragma mark USER  RELATED FUNCTION
#pragma mark - 


- (bool) createUser: (NSString *) userID withUserName: (NSString*) userName
            withPassword: (NSString*) password
{

    DDLogVerbose(@"Enter HabitDataModel::createHabitForUser. userName:%@, password:%@",
          userID,
          password);
    
    
    // J2DO : Check the uniqueness of the username
    
    GBUser* newUser = nil;
    newUser = [NSEntityDescription insertNewObjectForEntityForName:@"GBUser" inManagedObjectContext:objectContext];
        
    
    newUser.UserID = [NSString stringWithString:userID];
    newUser.UserPass = [NSString stringWithString:password];
    newUser.UserName = [NSString stringWithString:userName];
    newUser.createAt = newUser.updateAt = [NSDate date];
    
    NSError *error;
    if (![objectContext save:&error]){
        
        DDLogError(@" Fail to create user. UserID : %@, Username : %@", userID, userName);
        return false;
    }

    return true;
}


- (GBUser*) getUserByID : (NSString*) userID{

    DDLogVerbose(@"Enter HabitDataModel::getUserByName. username:%@",userID);
    
    
    NSPredicate *predicate;
    
 
    predicate = [NSPredicate predicateWithFormat:@"(UserID = %@)", userID];
       
    NSArray *objects = [self queryManagedObject:kUser withPredicate:predicate];
    
    DDLogVerbose(@"Retrieved %d Users", [objects count]);
    
    if( objects.count == 0){
  
        DDLogWarn(@"No user object retrieved");
        return nil;
    
    }else if (objects.count > 1){
        
        DDLogWarn(@"More than 1 user object retrieved");
        return nil;
    
    } 
    
    return [objects lastObject];

}


- (NSArray*) getUserByType : (GBUserType) userType
{

    DDLogVerbose(@"Enter HabitDataModel::getUserByType. user type:%d",userType);
    
    NSMutableArray *userNameList = nil;
    
    if(userType == kUserTypeALL){
    
        userNameList = [NSMutableArray arrayWithArray:[self getFriendList]];
        [userNameList addObject:localUserID];
        
    }else if (userType == kUserTypeFriend){
    
        userNameList = [NSMutableArray arrayWithArray:[self getFriendList]];
        
    }else if (userType == kUserTypeInternal){
        
        userNameList = [NSMutableArray arrayWithObject:localUserID];
    }
    
    
    
    NSMutableArray *userList = [NSMutableArray array];
    
    for(NSString *name in userNameList){
    
        GBUser *user= [self getUserByID:name];
        
        if(user) 
            [userList addObject:user];
    }
    
    return userList;
    
       
}


#pragma mark - 
#pragma mark RELATION RELATED FUNCTION
#pragma mark - 

- (bool) createFriend: (NSString*) userID
{
    DDLogVerbose(@"Enter HabitDataModel::createFriend. userID:%@",userID);
       
    GBRelation* newRelation = nil;
    newRelation = [NSEntityDescription insertNewObjectForEntityForName:@"GBRelation" inManagedObjectContext:objectContext];
    
    newRelation.RelationID = [NSString stringWithFormat:@"RELATION_%@",[GBDataModelManager createLocalUUID]];
    newRelation.RelationType = [NSString stringWithString:[sRelationStr objectAtIndex:kFriend]];
    newRelation.RelationStatus = [NSString stringWithString:[sRelationStatusStr objectAtIndex:kRelationStatusPending]];
    newRelation.relationToUser = [NSString stringWithString:userID];
    newRelation.relationFromUser = [NSString stringWithString:localUserID];
    
    
    // J2DO : We might associate the object properties here. No such requirement for now. 
    //newRelation.fromUser = from;
    //newRelation.toUser = to;
    
    
    newRelation.createAt = newRelation.updateAt = [NSDate date];
    
    NSError *error = nil;
    if(![objectContext save:&error]){
    
        DDLogError(@" Failed to create friend :%@, %@", error, [error userInfo]);
        return false;
    }
        
    return true;
}



- (bool) createNanny: (NSString*) userID withHabitID:(NSString*) HabitID
{

    DDLogVerbose(@"Enter HabitDataModel::createNanny. userID:%@, habit:%@",userID, HabitID);
    
    
    GBUser *from, *to;
    GBHabit *habit;
    
    // get Current User
    
    from = [dataModel getUserByID:self.localUserID];
    
    if(!from){
        DDLogWarn(@" Can not retrieve local user");
        return false;
    }
    
    // get target User
    
    to = [dataModel getUserByID:userID];
    
    if(!to){
        DDLogError(@" Can not retrieve target user, user ID : %@", userID);
        return false;
    }
    
    
    // get the habit
    
    habit = [dataModel getHabitByID:HabitID];
    
    if(!habit){
        DDLogError(@" Can not retrieve the habit. Habit ID: %@ ", HabitID);
        return false;
    
    }
    
    
    GBRelation* newRelation = nil;
    newRelation = [NSEntityDescription insertNewObjectForEntityForName:@"GBRelation" inManagedObjectContext:objectContext];
    
    
    // Setting up data properties
    newRelation.RelationID       = [NSString stringWithFormat:@"RELATION_%@",[GBDataModelManager createLocalUUID]];
    newRelation.RelationType     = [NSString stringWithString:[sRelationStr objectAtIndex:kNanny]];
    newRelation.relationToUser   = [NSString stringWithString:userID];
    newRelation.relationFromUser = [NSString stringWithString:localUserID];
    newRelation.RelationStatus   = [NSString stringWithString:[sRelationStatusStr objectAtIndex:kRelationStatusPending]];

    // Setting up object properties
    newRelation.fromUser = from;
    newRelation.toUser = to;
    newRelation.hasHabit = habit;
    
    newRelation.createAt = newRelation.updateAt = [NSDate date];
    
    NSError *error;
    if(![objectContext save:&error]){
        DDLogError(@"Failed to create Nanny. Error :%@ , %@", error, [error userInfo]);
        return false;
        
    }
    
    return true;

}


- (NSArray *) getFriendList
{
    DDLogVerbose(@"Enter HabitDataModel::getFriendList.");
    
    
    NSPredicate *predicate;
    
    
    predicate = [NSPredicate predicateWithFormat:@"(RelationType = %@ AND relationFromUser = %@)", [sRelationStr objectAtIndex:kFriend], self.localUserID];
    
    NSArray *objects = [self queryManagedObject:kRelation withPredicate:predicate];
    
    DDLogVerbose(@"Retrieved %d relation", [objects count]);
    
    if( objects.count == 0){
        
        DDLogWarn(@"No friend retrieved");
        return nil;
        
    }
    
    NSMutableArray *friendNameList = [NSMutableArray array];
    
    for(GBRelation *relation in objects ){
    
        [friendNameList addObject:relation.relationToUser];
    }
    
    return friendNameList;
    
}


// J2DO : Combine getNannyList with getFriendList
- (NSArray *) getNannyList
{
    DDLogVerbose(@"Enter HabitDataModel::getNannyList.");
    
    
    NSPredicate *predicate;
    
    
    predicate = [NSPredicate predicateWithFormat:@"(RelationType = %@ AND relationFromUser = %@)", [sRelationStr objectAtIndex:kNanny], self.localUserID];
        
    NSArray *objects = [self queryManagedObject:kRelation withPredicate:predicate];
    
    DDLogVerbose(@"Retrieved %d relation", [objects count]);
    
    if( objects.count == 0){
        
        DDLogVerbose(@"No Nanny retrieved");
        return nil;
        
    }
    
    NSMutableArray *nannyNameList = [NSMutableArray array];
    
    for(GBRelation *relation in objects ){
        
        [nannyNameList addObject:relation.relationToUser];
        
        DDLogVerbose(@"Found Nanny:%@", relation.toUser.UserName);

    }
    
    return nannyNameList;
}

#pragma mark - 
#pragma mark Notification Related Objects
#pragma mark - 


- (bool) createNotification:(NSString*)message fromUser:(NSString*)fromUserID toUser:(NSString*)toUserID status:(int)status type:(int)type
{
    DDLogVerbose(@"Enter HabitDataModel::createNotification. fromUser:%@, toUser:%@, message:%@, status:%d, type:%d", fromUserID, toUserID, message, status, type);

    GBNotification* newNotification;
    
       
    newNotification = [NSEntityDescription insertNewObjectForEntityForName:@"GBNotification" inManagedObjectContext:objectContext];
    
    
    newNotification.notificationID  = [NSString stringWithFormat:@"NOTIFICATION_%@",[GBDataModelManager createLocalUUID]];
    
    newNotification.toUser          = [NSString stringWithString:toUserID];
    newNotification.fromUser        = [NSString stringWithString:fromUserID];
    newNotification.text            = [NSString stringWithString:message];
    newNotification.status          = [NSString stringWithString:[sNotificationStatusStr objectAtIndex:status]];
    newNotification.type            = [NSString stringWithString:[sNotificationTypeStr objectAtIndex:type]];
    
    newNotification.createAt = newNotification.updateAt  = [NSDate date];
    
    NSError *error;
    if(![objectContext save:&error]){
        
        DDLogError(@" Failed to create notification. Error : %@, %@", error, [error userInfo]);
        return false;
    }
    
    return true;
}


- (NSArray *) getAllNotifications
{

    DDLogVerbose(@"Enter HabitDataModel::getAllNotification.");
    
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"(toUser = %@)", localUserID];
    
    NSArray *objects = [self queryManagedObject:kNotification withPredicate:predicate];
    
    DDLogVerbose(@"Retrieved %d Notifications", [objects count]);
    
    return objects;
    
}

- (bool) createNotificationWithRemoteNotification : (PFObject*) remoteNotification
{

    DDLogVerbose(@"Enter HabitDataModel::createNotificationWithRemoteNotification. remoteNotification:%@", remoteNotification);
    
    
    GBNotification* newNotification;
    GBUser *notificationOwner;
    
    notificationOwner= [self getUserByID:[remoteNotification objectForKey:@"toUser"]];    
    if(!notificationOwner){
        DDLogError(@"Cannot retrieve notification owner");
        return false;
    }
    
    newNotification = [NSEntityDescription insertNewObjectForEntityForName:@"GBNotification" inManagedObjectContext:objectContext];
    
    
    newNotification.notificationID  = [remoteNotification objectForKey:@"notificationID"];
    
    newNotification.toUser          = [remoteNotification objectForKey:@"toUser"];
    newNotification.fromUser        = [remoteNotification objectForKey:@"fromUser"];
    newNotification.text            = [remoteNotification objectForKey:@"text"];
    newNotification.status          = [remoteNotification objectForKey:@"status"];
    newNotification.type            = [remoteNotification objectForKey:@"type"];
    
    newNotification.createAt          = remoteNotification.createdAt;
    newNotification.updateAt          = remoteNotification.updatedAt;
    
    
    NSError *error;
    if(![objectContext save:&error]){
        
        DDLogError(@" Failed to create local notification based on remote notification. Error : %@, %@", error, [error userInfo]);
        return false;
    }
    
    
    
    DDLogInfo(@"New Habit[%@] Created. Type : %@, Status, %@", newNotification.notificationID, newNotification.type, newNotification.status);
    
    
    return true;
    

}


#pragma mark - 
#pragma mark GENERIC FUNCTIONS
#pragma mark - 

- (NSArray *) getLocalObjects: (NSDate *) date withObjectType: (GBObjectType) objType withAttr: (GBSyncAttr) attr
{

    DDLogVerbose(@"Enter HabitDataModel::getLocalObjects. date:%@, object type: %d, attr : %d", date, objType, attr);
    
    
    NSPredicate *predicate;
    
    NSString* dateColumeName = nil;
    
    if (attr == kSyncCreateSince){
        
        dateColumeName = [NSString stringWithString:@"createAt"];
    
    }else if (attr == kSyncUpdateSince){
    
        dateColumeName = [NSString stringWithString:@"updateAt"];
    }
    
    predicate = [NSPredicate predicateWithFormat:@"(%K >= %@)", dateColumeName, date];
    NSArray *objects = [self queryManagedObject:objType withPredicate:predicate];
    
    DDLogVerbose(@"Retrieved %d objects", [objects count]);
    
    if( objects.count == 0){
        
        DDLogWarn(@"No object retrieved");
        return nil;
    }
    
    return objects;
}


- (NSManagedObject *) getLocalObjectByAttribute: (NSString*) attributeName withAttributeValue: (NSString*) attributeValue withObjectType: (GBObjectType) objType
{

    DDLogVerbose(@"Enter HabitDataModel::getLocalObjectByAttribute. attributeName: %@, attributeValue: %@, objType : %d", attributeName, attributeValue, objType);
    
    NSManagedObject *result = nil;
    NSPredicate *predicate;
    
    
    predicate = [NSPredicate predicateWithFormat:@"(%@ = %@)", attributeName, attributeValue];
    NSArray *objects = [self queryManagedObject:objType withPredicate:predicate];
    
    if( !objects || objects.count == 0 ){
    
        DDLogWarn(@" No object retrieved");
        
    }else if (objects.count > 1){
    
        DDLogWarn(@" More than one object retrieved");
    
    }else{
    
        result = objects.lastObject;
    }
    
    return result;
    
}

- (NSArray*)queryManagedObject: (GBObjectType)type withPredicate:(NSPredicate *)predicate
{
    
    DDLogVerbose(@"Enter HabitDataModel::queryManagedObject. type:%d, predicate:%@", type, predicate);
    
    
    // j2do : map different object type string    
    NSEntityDescription* desc = nil;
    
    if(type == kTask){
        desc = [NSEntityDescription entityForName:@"GBTask" inManagedObjectContext:objectContext];
    }else if(type == kHabit){
        desc = [NSEntityDescription entityForName:@"GBHabit" inManagedObjectContext:objectContext];
    }else if(type == kUser){
        desc = [NSEntityDescription entityForName:@"GBUser" inManagedObjectContext:objectContext];
    }else if(type == kRelation){
        desc = [NSEntityDescription entityForName:@"GBRelation" inManagedObjectContext:objectContext];        
    }else if(type == kNotification){
        desc = [NSEntityDescription entityForName:@"GBNotification" inManagedObjectContext:objectContext];                
    }
    
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    [request setEntity:desc];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [objectContext executeFetchRequest:request error:&error];
    
    
    if(!objects){
        
        DDLogError(@"Error Querying Objects, Error:%@, %@", error, [error userInfo]);
    }
    
    return objects;
}




// INTERNAL HELPER FUNCTIONS

- (NSArray *) getTaskSchedule: (NSDate*) startDate withFrequency: (NSString*) frequency withAttempts: (int) attempts
{
    
    DDLogVerbose(@"Enter HabitDataModel::getTaskSchedule. startDate : %@, Frequency: %@, Attempts : %d", startDate, frequency, attempts);
    
    NSMutableArray *array = [NSMutableArray array] ;
    
    NSTimeInterval dailyInterval = 60 * 60 * 24; // 86400
    NSTimeInterval weeklyInterval = dailyInterval * 7;  
    
    // Create a list of NSDate objects
    
    if ( [frequency caseInsensitiveCompare:@"daily"] == 0){
        
        
        for (int i =1; i<=attempts; i++) {
            NSDate* newDate = [self getDateCeil:[startDate dateByAddingTimeInterval:(dailyInterval*i)]];
            [array addObject:newDate];
        }
        
    }else if ([frequency caseInsensitiveCompare:@"weekly"] == 0){
        
        for (int i =1; i<=attempts; i++) {
            NSDate* newDate = [self getDateCeil:[startDate dateByAddingTimeInterval:(weeklyInterval * i)]];
            [array addObject:newDate];
        }
        
    }else if ([frequency caseInsensitiveCompare:@"monthly"] == 0){
        
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSCalendar *cal = [NSCalendar currentCalendar];
        
        
        
        for (int i =1; i<=attempts; i++) {
            [comps setMonth:i];   
            NSDate *newDate = [self getDateCeil:[cal dateByAddingComponents:comps toDate:startDate options:0]];
            [array addObject:newDate];
        }
        
    }
    
    for (int i=0;i<attempts;i++){
        
        NSDate* date = (NSDate*)[array objectAtIndex:i];
        DDLogInfo(@"new date %@",[date descriptionWithLocale:@"yy-mm-dd"]);
    }
    
    return array;
}



+ (NSString *)createLocalUUID {
        
    
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    return (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuid);
   }

- (void)SyncData
{

    NSError *error = NULL;
    if(![objectContext save:&error]){
        DDLogError(@" Save Context Error");
        
    }
    
}

- (NSDate*) getDateWithIndex : (int) offset
{
    DDLogVerbose(@"Enter HabitDataModel::getDateWithIndex. index:%d", offset);
    
    NSDate *result;
    
    if(index == 0){
        result = [NSDate date];
    }
    
    NSDate *today = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    
    [offsetComponents setDay:offset];
    
    // Calculate when, according to Tom Lehrer, World War III will end
    
    NSDate *newDate = [gregorian dateByAddingComponents:offsetComponents
                              
                                                        toDate:today options:0];
    
    
    
    return newDate;
}

- (NSDate*) getDateCeil : (NSDate*) date 
{
    DDLogVerbose(@"Enter HabitDataModel::getDateCeil. date:%@", date);
    
    NSDate *floorDate = [self getDateFloor:date];
    
    
    NSTimeInterval secondsInADay = 86400;
    
    NSDate *ceilDate = [floorDate dateByAddingTimeInterval:secondsInADay-1];
    
    return ceilDate;
    
}

- (NSDate*) getDateFloor: (NSDate*) date
{
        
    DDLogVerbose(@"Enter HabitDataModel::getDateFloor. date:%@", date);
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSDateComponents *overshootComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    
    NSTimeInterval overshotByHours = [overshootComponents hour] * 60 * 60;
    
    NSTimeInterval overshotByMinutes = [overshootComponents minute] * 60;
    
    NSTimeInterval overshotBySeconds = [overshootComponents second];
    
    NSTimeInterval interval = [date timeIntervalSinceReferenceDate];
   
    NSTimeInterval floorInterval = interval - overshotByHours - overshotByMinutes - overshotBySeconds;
    
    NSDate *floorDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:floorInterval];
    
    
    return floorDate;
}


@end
