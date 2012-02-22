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
#import "Parse/Parse.h"

#import "Groubit_iOSAppDelegate.h"

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


-(id) init{
    
    [super init];
    
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
    
    
    Groubit_iOSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.objectContext = appDelegate.managedObjectContext;
    
    NSLog(@"Set local username : %@", localUserName);
    self.localUserName = [[NSString alloc ]initWithString:@"Jeffrey"];

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
    
        NSLog(@"Sync Context Error: %@", error);
    }
    
    
}




#pragma mark - 
#pragma mark HABIT RELATED FUNCTION
#pragma mark - 

- (bool) createHabitWithRemoteHabit: (PFObject*) remoteHabit
{
    NSLog(@"Enter HabitDataModel::createHabitWithRemoteHabit. remoteHabit:%@", remoteHabit);

    
    GBHabit* newHabit;
    GBUser *habitOwner;
    
    habitOwner= [self getUserByName:[remoteHabit objectForKey:@"HabitOwner"]];    
    if(!habitOwner){
        NSLog(@"Cannot retrieve habit owner");
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
    
    
    
    NSLog(@"New Habit[%@] Created", newHabit.HabitName);
    

    return true;
}

- (bool) createHabitForUserWithNanny:(NSString*) userName
                            withName:(NSString*) habitName
                            withNannyName: (NSString*) nannyName
                            withStartDate:(NSDate*) habitStartDate
                            withFrequency: (HabitFrequency)habitFrequency
                            withAttempts: (int) attempts
                            withDescription:(NSString*) desc{

    NSLog(@"Enter HabitDataModel::createHabitForUserWithNanny. userName:%@, habitName:%@, nannyName:%@,habitStartDate:%@, habitFrequency:%d, habitAttempts:%d, habitDesc:%@",
          userName,
          nannyName,
          habitName,
          habitStartDate,
          habitFrequency,
          attempts,
          desc);

    GBUser *habitOwner;

    habitOwner= [self getUserByName:userName];    
    if(!habitOwner){
        NSLog(@"Cannot retrieve habit owner");
        return false;
    }
    
    
    GBHabit* newHabit;
    newHabit = [NSEntityDescription insertNewObjectForEntityForName:@"GBHabit" inManagedObjectContext:objectContext];
    
    
    NSString* habitStatusStr = [NSString stringWithString:[sHabitStatusStr objectAtIndex:kHabitStatusInit]];
    NSString* habitFrequencyStr = [[NSString alloc]initWithString:[sHabitFrequencyStr objectAtIndex:habitFrequency]];
    
    newHabit.HabitID = [[NSString alloc] initWithFormat:@"HABIT_%@",[GBDataModelManager createLocalUUID]];
    newHabit.HabitOwner = userName;
    newHabit.HabitName = habitName;
    newHabit.HabitFrequency = habitFrequencyStr;
    newHabit.HabitStatus = habitStatusStr;
    newHabit.HabitAttempts = [NSNumber numberWithInt:attempts];
    newHabit.HabitStartDate = habitStartDate;
    newHabit.belongsToUser = habitOwner;
    newHabit.HabitDescription = desc;
    newHabit.updateAt = newHabit.createAt = [NSDate date];

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
    
    // Automatically setup relationship
    if(nannyName){
        [self createNanny:nannyName withHabitID:newHabit.HabitID];
    }
    
    return true;

    
    
}


- (bool) createHabitForUser:(NSString*) userName
                   withName:(NSString*) habitName
                   withStartDate:(NSDate*) habitStartDate
                   withFrequency: (HabitFrequency)habitFrequency
                   withAttempts: (int) attempts
                   withDescription:(NSString *)desc{


    NSLog(@"Enter HabitDataModel::createHabitForUser. userName:%@, habitName:%@, habitStartDate:%@, habitFrequency:%d, habitAttempts:%d, habitDesc:%@",
          userName,
          habitName,
          habitStartDate,
          habitFrequency,
          attempts,
          desc);
    
    return [self createHabitForUserWithNanny:userName withName:habitName withNannyName:nil withStartDate:habitStartDate withFrequency:habitFrequency withAttempts:attempts withDescription:desc];
    
      
}


- (bool) createHabit:(NSString*) habitName
       withStartDate:(NSDate*) habitStartDate
       withFrequency: (HabitFrequency)habitFrequency
       withAttempts: (int) attempts
       withDescription:(NSString*) desc
{
    NSLog(@"Enter HabitDataModel::createHabitForUser. habitName:%@, habitStartDate:%@, habitFrequency:%d, habitAttempts:%d",
          habitName,
          habitStartDate,
          habitFrequency,
          attempts);
    
    return [self createHabitForUser:self.localUserName withName:habitName
                      withStartDate:habitStartDate withFrequency:habitFrequency withAttempts:attempts withDescription:desc];
   
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

- (GBHabit*) getHabitByID : (NSString*) habitID{
    
    NSLog(@"Enter HabitDataModel::getHabitByID. haibtID:%@",habitID);
    
    
    NSPredicate *predicate;
    
    
    predicate = [NSPredicate predicateWithFormat:@"(HabitID = %@)", habitID];
    
    NSArray *objects = [self queryManagedObject:kHabit withPredicate:predicate];
    
    NSLog(@"Retrieved %d habits", [objects count]);
    
    if( objects.count == 0){
        
        NSLog(@"No user habit retrieved");
        return nil;
        
    }else if (objects.count > 1){
        
        NSLog(@"More than 1 habit object retrieved");
        return nil;
        
    } 
    
    return [objects lastObject];
    
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
        habit.HabitStatus = [NSString stringWithString:[sHabitStatusStr objectAtIndex:kHabitStatusInProgress]];
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


#pragma mark - 
#pragma mark TASK RELATED FUNCTION
#pragma mark - 

- (bool) createTaskForHabit: (GBHabit*) newHabit
             withTargetDate:(NSDate*) taskTargetDate
{

    NSLog(@"Enter HabitDataModel::createTaskForHabit. habitID: %@, target date:%@", newHabit.HabitID, taskTargetDate);
    
       
    GBTask* newTask = nil;
    newTask = [NSEntityDescription insertNewObjectForEntityForName:@"GBTask" inManagedObjectContext:objectContext];
    
    newTask.TaskID = [[NSString alloc] initWithFormat:@"TASK_%@",[GBDataModelManager createLocalUUID]];
    newTask.TaskStatus = [NSString stringWithString:[sTaskStatusStr objectAtIndex:kTaskStatusInit]];
    newTask.TaskTargetDate = taskTargetDate;
    newTask.TaskName = [NSString stringWithFormat:@"TASK_%@",newTask.TaskID];
    newTask.belongsToHabit = newHabit;
    newTask.createAt = newTask.updateAt = [NSDate date];
    
    NSError *error;
    [objectContext save:&error];
    
    NSLog(@"New Task[%@] Created. Target Date: %@", newTask.TaskName, taskTargetDate);
    
    return true;
}

- (NSArray *) getTasksWithHabitID:(NSString*) habitID{

    NSLog(@"Enter HabitDataModel::getTasksWithHabitID. habitID:%@",habitID);
    
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"(belongsToHabit.HabitID = %@)", habitID];
    
    NSArray *objects = [self queryManagedObject:kTask withPredicate:predicate];
    
    NSLog(@"Retrieved %d Tasks", [objects count]);
    
    return objects;
}

- (bool) createTaskWithRemoteTask: (PFObject*) remoteTask
{

    NSLog(@"Enter HabitDataModel::createTaskWithRemoteTask. remote task: %@", remoteTask);
    
    GBHabit *newHabit = [dataModel getHabitByID:[remoteTask objectForKey:@"HabitID"]];
    
    if(!newHabit){
        NSLog(@"Can not retrive associated habit");
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
    [objectContext save:&error];
    
    NSLog(@"New Task[%@] Created. Target Date: %@", newTask.TaskName, newTask.TaskTargetDate);
    
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
        task.TaskStatus = [NSString stringWithString:[sTaskStatusStr objectAtIndex:kTaskStatusCompleted]];
        [objectContext save:&error];
        
        if(!error){
            NSLog(@"Task update successfully");
        }
    }
    
    [request release];
}

// j2do
- (NSArray *) getAllTasks:(GBUserType) userType
{
 
    
    NSLog(@"Enter HabitDataModel::getAllTasks. userType:%d",userType);
    
    NSMutableArray *allTasks = [NSMutableArray array];
    
    NSArray *allHabits = [self getAllHabitsByType:userType];
    
    
    for( GBHabit *habit in allHabits){
    
        NSArray *tasks = [self getTasksWithHabitID:habit.HabitID];
        
        for (GBTask *task in tasks){
            [allTasks addObject:task];
        }
    }
    
    
    
    NSLog(@"Retrieved %d Tasks", [allTasks count]);
    
    
    return allTasks;

}

// j2do
- (NSArray *) getMyBabyTasks
{

    return NULL;
}

- (NSArray *) getRecentTask: (GBUserType) userType withPeriod:(int)days
{
    NSLog(@"Enter HabitDataModel::getRecentTasks. userType:%d, withPeriod:%d",userType, days);
    
    NSArray* userNameList = nil;
    
    if( userType == kUserTypeInternal ){
    
        userNameList = [NSArray arrayWithObject:localUserName];
        
    }else if (userType == kUserTypeBaby){
    
        userNameList = [self getNannyList];
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
    
    NSLog(@"Query Predicate : %@", andPredicate);
    
    NSArray *objects = [self queryManagedObject:kTask withPredicate:andPredicate];
    
    NSLog(@"Retrieved %d Tasks", [objects count]);
    
    return objects;
}


#pragma mark - 
#pragma mark USER  RELATED FUNCTION
#pragma mark - 


- (bool) createUser: (NSString *) username
            withPassword: (NSString*) password
{

    NSLog(@"Enter HabitDataModel::createHabitForUser. userName:%@, password:%@",
          username,
          password);
    
    
    GBUser* newUser = nil;
    newUser = [NSEntityDescription insertNewObjectForEntityForName:@"GBUser" inManagedObjectContext:objectContext];
    
    
    
    newUser.UserID = [[NSString alloc] initWithFormat:@"USER_%@",[GBDataModelManager createLocalUUID]];
    newUser.UserPass = [NSString stringWithString:password];
    newUser.UserName = [NSString stringWithString:username];
    newUser.createAt = newUser.updateAt = [NSDate date];
    
    NSError *error;
    [objectContext save:&error];
    
    if(error){
        return false;
    }
    
    return true;
}

- (GBUser*) getUserByName : (NSString*) username{

    NSLog(@"Enter HabitDataModel::getUserByName. username:%@",username);
    
    
    NSPredicate *predicate;
    
 
    predicate = [NSPredicate predicateWithFormat:@"(UserName = %@)", username];
       
    NSArray *objects = [self queryManagedObject:kUser withPredicate:predicate];
    
    NSLog(@"Retrieved %d Users", [objects count]);
    
    if( objects.count == 0){
  
        NSLog(@"No user object retrieved");
        return nil;
    
    }else if (objects.count > 1){
        
        NSLog(@"More than 1 user object retrieved");
        return nil;
    
    } 
    
    return [objects lastObject];

}


- (NSArray*) getUserByType : (GBUserType) userType
{

    NSLog(@"Enter HabitDataModel::getUserByType. user type:%d",userType);
    
    NSMutableArray *userNameList = nil;
    if(userType == kUserTypeALL){
    
        userNameList = [NSMutableArray arrayWithArray:[self getFriendList]];
        [userNameList addObject:localUserName];
        
    }else if (userType == kUserTypeFriend){
    
        userNameList = [NSMutableArray arrayWithArray:[self getFriendList]];        
    }else if (userType == kUserTypeInternal){
        
        userNameList = [NSMutableArray arrayWithObject:localUserName];
    }
    
    
    
    NSMutableArray *userList = [NSMutableArray array];
    
    for(NSString *name in userNameList){
    
        GBUser *user= [self getUserByName:name];
        
        if(user) 
            [userList addObject:user];
    }
    
    return userList;
    
       
}


#pragma mark - 
#pragma mark RELATION RELATED FUNCTION
#pragma mark - 

- (bool) createFriend: (NSString*) username
{
    NSLog(@"Enter HabitDataModel::createFriend. username:%@",username);
    
    
    GBUser *from, *to;
    // get Current User
    
    from = [dataModel getUserByName:self.localUserName];
    
    if(!from){
        return false;
    }
    
    // get target User
    
    to = [dataModel getUserByName:username];
    
    if(!to){
        return false;
    }
    
    
    GBRelation* newRelation = nil;
    newRelation = [NSEntityDescription insertNewObjectForEntityForName:@"GBRelation" inManagedObjectContext:objectContext];
    
    
    
    newRelation.RelationID = [[NSString alloc] initWithFormat:@"RELATION_%@",[GBDataModelManager createLocalUUID]];
    newRelation.RelationType = (NSString*)[sRelationStr objectAtIndex:kFriend];
    newRelation.RelationStatus = (NSString*)[sRelationStatusStr objectAtIndex:kRelationStatusPending];
    newRelation.fromUser = from;
    newRelation.toUser = to;
    newRelation.createAt = newRelation.updateAt = [NSDate date];
    
    NSError *error;
    [objectContext save:&error];
    
    if(error){
        return false;
    }
    

    
    return true;
}

- (bool) createNanny: (NSString*) username withHabitID:(NSString*) HabitID
{

    NSLog(@"Enter HabitDataModel::createNanny. username:%@, habit:%@",username, HabitID);
    
    
    GBUser *from, *to;
    GBHabit *habit;
    
    // get Current User
    
    from = [dataModel getUserByName:self.localUserName];
    
    if(!from){
        NSLog(@" Can not retrieve local user");
        return false;
    }
    
    // get target User
    
    to = [dataModel getUserByName:username];
    
    if(!to){
        NSLog(@" Can not retrieve target user");
        return false;
    }
    
    
    // get the habit
    
    habit = [dataModel getHabitByID:HabitID];
    
    if(!habit){
        NSLog(@" Can not retrieve the habit ");
        return false;
    
    }else{
        
        
    }
    
    
    GBRelation* newRelation = nil;
    newRelation = [NSEntityDescription insertNewObjectForEntityForName:@"GBRelation" inManagedObjectContext:objectContext];
    
    
    
    newRelation.RelationID = [[NSString alloc] initWithFormat:@"RELATION_%@",[GBDataModelManager createLocalUUID]];
    newRelation.RelationType = (NSString*)[sRelationStr objectAtIndex:kNanny];
    newRelation.fromUser = from;
    newRelation.toUser = to;
    newRelation.hasHabit = habit;
    newRelation.RelationStatus = (NSString*)[sRelationStatusStr objectAtIndex:kRelationStatusPending];
    newRelation.createAt = newRelation.updateAt = [NSDate date];
    
    NSError *error;
    [objectContext save:&error];
    
    if(error){
        return false;
    }
    
    
    
    return true;

}


- (NSArray *) getFriendList
{
    NSLog(@"Enter HabitDataModel::getFriendList.");
    
    
    NSPredicate *predicate;
    
    
    predicate = [NSPredicate predicateWithFormat:@"(RelationType = %@ AND fromUser.UserName = %@)", [sRelationStr objectAtIndex:kFriend], self.localUserName];
    
    NSArray *objects = [self queryManagedObject:kRelation withPredicate:predicate];
    
    NSLog(@"Retrieved %d relation", [objects count]);
    
    if( objects.count == 0){
        
        NSLog(@"No friend retrieved");
        return nil;
        
    }
    
    NSMutableArray *friendNameList = [NSMutableArray array];
    
    for(GBRelation *relation in objects ){
    
        [friendNameList addObject:relation.toUser.UserName];
    }
    
    return friendNameList;
    
}

- (NSArray *) getNannyList
{
    NSLog(@"Enter HabitDataModel::getNannyList.");
    
    
    NSPredicate *predicate;
    
    
    predicate = [NSPredicate predicateWithFormat:@"(RelationType = %@ AND fromUser.UserName = %@)", [sRelationStr objectAtIndex:kNanny], self.localUserName];
        
    NSArray *objects = [self queryManagedObject:kRelation withPredicate:predicate];
    
    NSLog(@"Retrieved %d relation", [objects count]);
    
    if( objects.count == 0){
        
        NSLog(@"No Nanny retrieved");
        return nil;
        
    }
    
    NSMutableArray *nannyNameList = [NSMutableArray array];
    
    for(GBRelation *relation in objects ){
        
        [nannyNameList addObject:relation.toUser.UserName];
        
        NSLog(@"Found Nanny:%@", relation.toUser.UserName);
        // for test
        GBHabit *habit = relation.hasHabit;
        
        NSLog(@"Nannied Habit Name:%@", habit.HabitName);
        
        
    }
    
    return nannyNameList;
}


- (NSArray *) getLocalObjects: (NSDate *) date withObjectType: (GBObjectType) objType withAttr: (GBSyncAttr) attr
{

    NSLog(@"Enter HabitDataModel::getLocalObjects. date:%@, object type: %d, attr : %d", date, objType, attr);
    
    
    NSPredicate *predicate;
    
    NSString* dateColumeName = nil;
    
    if (attr == kSyncCreateSince){
        
        dateColumeName = [NSString stringWithString:@"createAt"];
    
    }else if (attr == kSyncUpdateSince){
    
        dateColumeName = [NSString stringWithString:@"updateAt"];
    }
    
    
  //  predicate = [NSPredicate predicateWithFormat:@"(%@ >= %@ AND %@ <= %@)", dateColumeName, date, dateColumeName, [NSDate date]];
    predicate = [NSPredicate predicateWithFormat:@"(%K >= %@)", dateColumeName, date];
    NSArray *objects = [self queryManagedObject:objType withPredicate:predicate];
    
    NSLog(@"Retrieved %d objects", [objects count]);
    
    if( objects.count == 0){
        
        NSLog(@"No object retrieved");
        return nil;
        
    }
    
    return objects;
}


- (NSManagedObject *) getLocalObjectByAttribute: (NSString*) attributeName withAttributeValue: (NSString*) attributeValue withObjectType: (GBObjectType) objType
{

    NSLog(@"Enter HabitDataModel::getLocalObjectByAttribute. attributeName: %@, attributeValue: %@, objType : %d", attributeName, attributeValue, objType);
    
    NSManagedObject *result = nil;
    NSPredicate *predicate;
    
    
    predicate = [NSPredicate predicateWithFormat:@"(%@ = %@)", attributeName, attributeValue];
    NSArray *objects = [self queryManagedObject:objType withPredicate:predicate];
    
    if( !objects || objects.count == 0 ){
    
        NSLog(@" No object retrieved");
        
    }else if (objects.count > 1){
    
        NSLog(@" More than one object retrieved");
    
    }else{
    
        result = objects.lastObject;
    }
    
    return result;
    
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
    }else if(type == kUser){
        desc = [NSEntityDescription entityForName:@"GBUser" inManagedObjectContext:objectContext];
    }else if(type == kRelation){
        desc = [NSEntityDescription entityForName:@"GBRelation" inManagedObjectContext:objectContext];        
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

- (void)SyncData
{

    NSError *error;
    [objectContext save:&error];
    
    if(error){
        NSLog(@" Save Context Error");
    }
    
}

@end
