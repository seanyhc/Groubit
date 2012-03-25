//
//  TaipeiStation.m
//  Groubit_iOS
//
//  Created by Jeffrey on 1/20/12.
//  Copyright 2012 UCB MIMS. All rights reserved.
//

#import "TaipeiStation.h"
#import "GBDataModelManager.h"
#import "GBUser.h"
#import "GBHabit.h"
#import "GBTask.h"
#import "GBRelation.h"
#import "GBNotification.h"
#import "Parse/Parse.h"

#define DEFALUT_SYNC_INTERVAL 10.0    // sync every 10 secs

@implementation TaipeiStation

@synthesize lastSyncDate;
@synthesize syncTimer;


static TaipeiStation* syncEngine = nil; 

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    if(!dataModel){
    
        dataModel = [GBDataModelManager getDataModelManager];
    }
    lastSyncDate = nil;
    
    return self;
}

- (void)dealloc{
    
    NSLog(@"release sync engine");
}

+(TaipeiStation*) getSyncEngine
{
    if(syncEngine == nil)
    {
        NSLog(@"init sync engine");
        syncEngine = [[TaipeiStation alloc] init];
    }
    return syncEngine;
}


- (bool)syncUserData
{
    NSLog(@"TaipeiStation::syncUserData");
    
    GBUser *gbLocalUser = [dataModel getUserByName:dataModel.localUserName];
    
    if( !gbLocalUser){
        
        NSLog(@"Can not retrieve local user. Exit");
        return false;
    } 
    
    // check if local user exist on remote
    
    PFQuery *query = [PFQuery queryWithClassName:@"GBUser"];
    [query whereKey:@"UserID" equalTo:gbLocalUser.UserID];
    NSArray *pfUsers = [query findObjects];
    
    if( pfUsers.count == 0 ){
    
        NSLog(@"User not exist on remote. Create now");
        
        PFObject *pfUser = [PFObject objectWithClassName:@"GBUser"];
        [pfUser setObject:gbLocalUser.UserName forKey:@"UserName"];
        [pfUser setObject:gbLocalUser.UserPass forKey:@"UserPass"];
        [pfUser setObject:gbLocalUser.UserID   forKey:@"UserID"];
        [pfUser save];
        
    }else{
    
        NSLog(@"User Exist. Merge now");
        
        PFObject *pfUser = [pfUsers lastObject];
        
        if(pfUser.updatedAt > gbLocalUser.updateAt){
            
            // use remote copy
            
            NSLog(@"Use Remote Copy");
            
            gbLocalUser.UserName = [pfUser objectForKey:@"UserName"];
            // TODO: we should secure the password with hash function
            gbLocalUser.UserPass = [pfUser objectForKey:@"UserPass"];
            gbLocalUser.updateAt = [NSDate date];
            
            [dataModel SyncData];
            
        }else{
        
            // use local copy
            
              NSLog(@"Use Local Copy");
            
            [pfUser setObject:gbLocalUser.UserName forKey:@"UserName"];
            [pfUser setObject:gbLocalUser.UserPass forKey:@"UserPass"];
            [pfUser saveInBackground];
            
        }
    }
        
    return true;
}



- (bool)syncRelation
{

    NSLog(@"TaipeiStation::syncRelation");
    
    
    
    // setp 1 : Merge relationes

    // get all local relation ID
    
    NSArray *localRelations = [dataModel getLocalObjects:lastSyncDate withObjectType:kRelation withAttr:kSyncUpdateSince];
    
    
    if( localRelations && localRelations.count > 0){
        
  
        
        for( GBRelation* localRelation in localRelations)
        {
        
            PFQuery *remoteRelationQuery = [PFQuery queryWithClassName:@"GBRelation"];
            [remoteRelationQuery whereKey:@"RelationID" equalTo:localRelation.RelationID];
            NSArray *remoteRelationArray = [remoteRelationQuery findObjects];

            if(remoteRelationArray && remoteRelationArray.count == 1){
            
                PFObject *remoteRelation = remoteRelationArray.lastObject;
                
                NSLog(@" Found relation in common. Relation ID: %@, local Status: %@, remote Status: %@", localRelation.RelationID, localRelation.RelationStatus, [remoteRelation objectForKey:@"RelationStatus"]);
                
                if(remoteRelation.updatedAt > localRelation.updateAt){
                
                    // remote has latest date
                    
                    localRelation.RelationStatus = [remoteRelation objectForKey:@"RelationStatus"];
                    localRelation.updateAt = [NSDate date];
                    
                    [dataModel SyncData];
                    
                }else{
                
                    [remoteRelation setObject:localRelation.RelationStatus forKey:@"RelationStatus"];
                    [remoteRelation saveInBackground];
                }
            
            }else{
                NSLog(@" No relation in common. Skip Merge");
            }
            
        } // end for
        
    } // end if
    
    
    // step 2 : Retrieve new relations on remote
    
    PFQuery *relationQuery = [PFQuery queryWithClassName:@"GBRelation"];
    [relationQuery whereKey:@"createAt" greaterThan:lastSyncDate] ;
    [relationQuery whereKey:@"relationToUser" equalTo:dataModel.localUserName];
    NSArray *newPFRelations = [relationQuery findObjects];
    
    if( newPFRelations && newPFRelations.count > 0 ){
    
        for( PFObject* pfRelation in newPFRelations){
        
            NSString *type     = [pfRelation objectForKey:@"RelationType"];
            NSString *status   = [pfRelation objectForKey:@"RelationStatus"];
            NSString *fromUser = [pfRelation objectForKey:@"fromUser"];
            
            if( [type isEqualToString:@"friend"] && [status isEqualToString:@"pending"]){
                
                // friend request
                // TODO : prompt user 
                NSLog(@"Friend Request from User:%@, status: %@", fromUser, status);
                
                
                // 0. create local relation object
                
                //[dataModel createRelationWithRemoteRelation:pfRelation];
                
                // 1. add user(originator) to local
                
                // 2. create notification object
                
                
                
                //[dataModel createFriend:fromUser];
                
            }else if ([type isEqualToString:@"nanny"]){
            
                NSLog(@"Nanny Request from User:%@, status: %@", fromUser, status);
                // nanny request
                
                
                // 0. 
                
                // TODO prompt user
                
            }
            
        }
        
    }
    
    
    // step 3 : Retrieve all new relations on local
    
    NSArray *newGBRelation = [dataModel getLocalObjects:lastSyncDate withObjectType:kRelation withAttr:kSyncCreateSince];
    
    for(GBRelation *relation in newGBRelation){

        // j2do : check the id is unique on remote
        
        NSLog(@"Create new relation on remote. RelaitonID: %@, Relation: %@", relation.RelationID, relation);
        PFObject *pfRelation = [PFObject objectWithClassName:@"GBRelation"];
        [pfRelation setObject:relation.RelationID forKey:@"RelationID"];
        [pfRelation setObject:relation.RelationType forKey:@"RelationType"];
        [pfRelation setObject:relation.RelationStatus forKey:@"RelationStatus"];
        [pfRelation setObject:relation.relationToUser forKey:@"relationToUser"];
        [pfRelation setObject:relation.relationFromUser forKey:@"relationFromUser"];
        
        [pfRelation saveInBackground];            
    }
    
    // j2do : handle delete here
    
    
    return true;
}

- (bool)syncHabit
{
    
    NSLog(@"TaipeiStation::syncHabit");
    NSDate *now = [NSDate date];
    
    // setp 1 : Merge Habits
    
    NSLog(@"Merge Habits ...");
    //NSArray* localHabits = [dataModel getLocalObjects:lastSyncDate withObjectType:kHabit withAttr:kSyncUpdateSince];
    NSArray *localHabits = [dataModel getAllHabitsByType:kUserTypeALL];
    
    if( localHabits && localHabits.count > 0){
        
        for( GBHabit *localHabit in localHabits){
        
            PFQuery *remoteHabitQuery = [PFQuery queryWithClassName:@"GBHabit"];
            [remoteHabitQuery whereKey:@"HabitID" equalTo:localHabit.HabitID];
            NSArray *remoteHabitArray = [remoteHabitQuery findObjects];
            
            if(remoteHabitArray && remoteHabitArray.count == 1){
                
                PFObject *remoteHabit = remoteHabitArray.lastObject;
                
                NSLog(@" Found habit in common. Habit ID: %@, local habit: %@, remote habit: %@, remote update :%@", localHabit.HabitID, localHabit, remoteHabit, remoteHabit.updatedAt);
                
                if(remoteHabit.updatedAt > localHabit.updateAt){
                    
                    // remote has latest date
                    NSLog(@"Update local with remote status");
                    localHabit.HabitName        = [remoteHabit objectForKey:@"HabitName"];
                    localHabit.HabitStatus      = [remoteHabit objectForKey:@"HabitStatus"];
                    localHabit.HabitDescription = [remoteHabit objectForKey:@"HabitDescription"];
                    
                    localHabit.updateAt = [NSDate date];
                    
                    [dataModel SyncData];
                    
                    [self syncTasks:localHabit.HabitID];
                    
                    
                }else{
                    NSLog(@"Update Remote with local status");

                    [remoteHabit setObject:localHabit.HabitName forKey:@"HabitName"];
                    [remoteHabit setObject:localHabit.HabitStatus forKey:@"HabitStatus"];                    
                    [remoteHabit setObject:localHabit.HabitDescription forKey:@"HabitDescription"];
                    
                    [remoteHabit saveInBackground];
                }

            }
    
        }
    }
    
    // step 2 : retrive new habits on local and create remote habits
    NSLog(@"retrive new habits on local and create remote habits");
    NSArray *newGBHabit = [dataModel getLocalObjects:lastSyncDate withObjectType:kHabit withAttr:kSyncCreateSince];
    
    
    for(GBHabit *habit in newGBHabit){
        
        // j2do : check the id is unique on remote
        
        NSLog(@"Create new habit on remote. Habit: %@", habit);
        PFObject *pfHabit = [PFObject objectWithClassName:@"GBHabit"];
        [pfHabit setObject:habit.HabitID forKey:@"HabitID"];
        [pfHabit setObject:habit.HabitName forKey:@"HabitName"];
        [pfHabit setObject:habit.HabitOwner forKey:@"HabitOwner"];
        [pfHabit setObject:habit.HabitDescription forKey:@"HabitDescription"];
        [pfHabit setObject:habit.HabitFrequency forKey:@"HabitFrequency"];
        [pfHabit setObject:habit.HabitAttempts forKey:@"HabitAttempts"];
        [pfHabit setObject:habit.HabitStatus forKey:@"HabitStatus"];
        [pfHabit setObject:habit.HabitStartDate forKey:@"HabitStartDate"];
        
        // j2do : setup relation with task and owner
        
        [pfHabit saveInBackground];  
        
        
        // create tasks
        
        NSSet *tasks = habit.tasks;
        
        for( GBTask* task in tasks){
            
            NSLog(@"Create new tasks on remote. TaskID: %@, Task Status: %@", task.TaskID, task.TaskStatus);
            
            PFObject *pfTask = [PFObject objectWithClassName:@"GBTask"];
            
            [pfTask setObject:task.TaskID forKey:@"TaskID"];
            [pfTask setObject:habit.HabitID forKey:@"HabitID"];
            [pfTask setObject:task.TaskName forKey:@"TaskName"];
            [pfTask setObject:task.TaskStatus forKey:@"TaskStatus"];
            [pfTask setObject:task.TaskTargetDate forKey:@"TaskTargetDate"];
            
            //[pfTask setObject:pfHabit forKey:@"belongsToHabit"];
            
            [pfTask saveInBackground];
        }
        
    }
    
    

    
    
    // step 3 : retrieve new habits on remote and create local habits

    NSLog(@"retrieve new habits on remote and create local habits");

    // get a list of local users ( including local owner and his friends)
    NSArray *localUsers = [dataModel getUserByType:kUserTypeALL];
    NSMutableArray *localUserNames = [NSMutableArray array];
    
    for (GBUser * user in localUsers) {
        [localUserNames addObject:user.UserName];
    }
    
    PFQuery *newHabitQuery = [PFQuery queryWithClassName:@"GBHabit"];
    [newHabitQuery whereKey:@"createdAt" greaterThan:lastSyncDate];
    [newHabitQuery whereKey:@"createdAt" lessThan:now ]; 
    [newHabitQuery whereKey:@"HabitOwner" containedIn:localUserNames];
    NSLog(@" local users :%@", localUserNames);
    NSLog(@" new remote habit query : %@", newHabitQuery);
    
    NSArray *newPFHabits = [newHabitQuery findObjects];
    
    if( newPFHabits && newPFHabits.count > 0 ){
        
        for( PFObject* remoteHabit in newPFHabits){
            
            [dataModel createHabitWithRemoteHabit:remoteHabit];
            
            PFQuery *newTaskQuery = [PFQuery queryWithClassName:@"GBTask"];
            [newTaskQuery whereKey:@"HabitID" equalTo:[remoteHabit objectForKey:@"HabitID"]];
            NSArray *newPFTasks = [newTaskQuery findObjects];
        
            if( newPFTasks && newPFTasks.count > 0){
            
                for( PFObject* remoteTask in newPFTasks ){
                
                    [dataModel createTaskWithRemoteTask:remoteTask];
                }
            }
            
        }
        
    }else{
        NSLog(@" No new remote habits");
    }
    
    
  
    // j2do : delete habit objects
    
    
    return true;
}

- (bool) syncTasks: (NSString*) habitID
{
    
    // retrieve remote tasks
    
    PFQuery *remoteTaskQuery = [PFQuery queryWithClassName:@"GBTasks"];
    
    [remoteTaskQuery whereKey:@"HabitID" equalTo:habitID] ;
  
    NSArray *remoteTaskArray = [remoteTaskQuery findObjects];
    
    if (remoteTaskArray && remoteTaskArray == 0)
    {
        NSLog(@" No remote tasks retrieved");
        return false;
    }
    
    for(PFObject *remoteTask in remoteTaskArray)
    {
    
        GBTask *localTask = (GBTask*)[dataModel getLocalObjectByAttribute:@"TaskID" withAttributeValue:[remoteTask objectForKey:@"TaskID"] withObjectType:kTask];
        
        
        if(localTask){
        

            if(localTask.updateAt > remoteTask.updatedAt)
            {
                [remoteTask setObject:localTask.TaskStatus forKey:@"TaskStatus"];
                [remoteTask saveInBackground];
                
            }else if(localTask.updateAt < remoteTask.updatedAt)
            {
                localTask.TaskStatus = [remoteTask objectForKey:@"TaskStatus"];
                localTask.updateAt = [NSDate date];
                
                [dataModel SyncData];
            }               
        }
    
    }
    
    return true;
}

- (bool) syncNotification
{
     NSLog(@"Enter TaipeiStation::syncNotification");
     NSDate *now = [NSDate date];
    
    // 1. sync nofication in common
    
   
    NSArray *localNotifications = [dataModel getAllNotifications];
    
    if( localNotifications && localNotifications.count > 0){
         NSLog(@"Merge Notification ...");
        for( GBNotification *localNotification in localNotifications){
            
            PFQuery *remoteNotificationQuery = [PFQuery queryWithClassName:@"GBNotification"];
            [remoteNotificationQuery whereKey:@"notificationID" equalTo:localNotification.notificationID];
            NSArray *remoteNotificationArray = [remoteNotificationQuery findObjects];
            
            if(remoteNotificationArray && remoteNotificationArray.count == 1){
                
                PFObject *remoteNotification = remoteNotificationArray.lastObject;
                
                NSLog(@" Found notification in common. Notification ID: %@, local notification: %@, remote notification: %@, remote update :%@", localNotification.notificationID, localNotification, remoteNotification, remoteNotification.updatedAt);
                
                if(remoteNotification.updatedAt > localNotification.updateAt){
                    
                    // remote has latest date
                    NSLog(@"Update local with remote status");
                    localNotification.status        = [remoteNotification objectForKey:@"status"];
                    localNotification.text      = [remoteNotification objectForKey:@"text"];

                    localNotification.updateAt = now;
                    
                    [dataModel SyncData];
                
                    
                }else{
                    NSLog(@"Update Remote with local status");
                    
                    [remoteNotification setObject:localNotification.status forKey:@"status"];
                    [remoteNotification setObject:localNotification.text forKey:@"text"];                    
                    
                    [remoteNotification saveInBackground];
                }
                
            }
            
        }
    }
    
    
    // 2. upload local notification to remote
    NSLog(@"retrive new Notification on local and create remote habits");
    NSArray *newGBNotifications = [dataModel getLocalObjects:lastSyncDate withObjectType:kNotification withAttr:kSyncCreateSince];
    
    
    for(GBNotification *notification in newGBNotifications){
        
        // j2do : check the id is unique on remote
        
        NSLog(@"Create new Notification on remote. Notification: %@", notification);
        PFObject *pfNotification = [PFObject objectWithClassName:@"GBNotification"];
        [pfNotification setObject:notification.notificationID forKey:@"notificationID"];
        [pfNotification setObject:notification.type forKey:@"type"];
        [pfNotification setObject:notification.fromUser forKey:@"fromUser"];
        [pfNotification setObject:notification.toUser forKey:@"toUser"];
        [pfNotification setObject:notification.text forKey:@"text"];
        [pfNotification setObject:notification.status forKey:@"status"];
      
        
        // j2do : setup relation with task and owner
        
        [pfNotification saveInBackground];  
    }
    

    // 3. create local notification object based on remote object
    
    NSLog(@"retrieve new notification on remote and create local notification");
    
   
    NSArray *localUsers = [dataModel getUserByType:kUserTypeALL];
    NSMutableArray *localUserNames = [NSMutableArray array];
    
    for (GBUser * user in localUsers) {
        [localUserNames addObject:user.UserName];
    }
    
    PFQuery *newNotificationQuery = [PFQuery queryWithClassName:@"GBNotification"];
    [newNotificationQuery whereKey:@"createdAt" greaterThan:lastSyncDate];
    [newNotificationQuery whereKey:@"createdAt" lessThan:now ]; 
    [newNotificationQuery whereKey:@"toUser" equalTo:[dataModel localUserName]];

    NSArray *newPFNotifications = [newNotificationQuery findObjects];
    
    if( newPFNotifications && newPFNotifications.count > 0 ){
        
        for( PFObject* remoteNotification in newPFNotifications){
            
            [dataModel createNotificationWithRemoteNotification:remoteNotification];
            
        }
        
    }else{
        NSLog(@" No new remote habits");
    }
    
    
    return true;
}

- (bool) syncAll 
{
    NSLog(@"Enter TaipeiStation::syncAll");
    
    if (!lastSyncDate){
        // j2do : maybe a leak..
        lastSyncDate = [[NSDate alloc]init];
        NSLog(@" Set Last Sync Date to %@", lastSyncDate);
    }
    
    NSLog(@"Last Sync Date: %@", lastSyncDate);   
  
    /*
  
    [self syncUserData];
    
    [self syncRelation];
    
    [self syncHabit];
    
     */
    
    [self syncNotification];
    
    lastSyncDate = [[NSDate alloc]init];
    NSLog(@" Set Last Sync Date to %@", lastSyncDate);
    return true;
}

-(void) startSyncTimer: (NSTimer*) timer
{

    NSLog(@"Enter TaipeiStation::startSyncTimer");
    
    if(!syncTimer)
    {
        NSLog(@"create Sync Timers");
        syncTimer = [NSTimer scheduledTimerWithTimeInterval:DEFALUT_SYNC_INTERVAL
                                      target:self
                                      selector:@selector(startSyncTimer:)
                                      userInfo:nil
                                      repeats:YES];

    }
    
    [self syncAll];
    
        
}

-(void) stopSyncTimer
{
    NSLog(@"Enter TaipeiStation::stopSyncTimer");

    if(syncTimer)
    {
        [syncTimer invalidate];
        syncTimer = nil;
    }

}


+(bool) enableRegularSync
{
    NSLog(@"Enter TaipeiStation::enableRegularSync");
    

    TaipeiStation *syncEngine = [TaipeiStation getSyncEngine];
    
    if(syncEngine)
    {
        [syncEngine startSyncTimer:nil];
        
    }
    
    return true;
}



@end
