//
//  HabitDataModel.h
//  Groubit_alpha
//
//  Created by Jeffrey on 7/26/11.
//  Copyright 2011 NTU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBHabit.h"
#import "Parse/Parse.h"

@interface GBDataModelManager : NSObject {
 
    NSManagedObjectContext *obectContext;
    NSString *localUserName;
    NSStream *localUserID;
}

@property (nonatomic, retain) NSManagedObjectContext *objectContext;
@property (nonatomic, retain) NSString *localUserName;
@property (nonatomic, retain) NSStream *localUserID;

typedef enum {
    kHabitStatusInit,
    kHabitStatusInProgress ,
    kHabitStatusCompleted,
    kHabitStatusPending,
    kHabitStatusIllegal
} HabitStatus;

typedef enum {
    kTaskStatusInit,
    kTaskStatusCompleted,
    kTaskStatusIllegal
} TaskStatus;

typedef enum {
    kDaily,
    kWeekly,
    kBiWeekly,
    kMonthly,
    kCustom
} HabitFrequency;

typedef enum {
    kUserTypeInternal,
    kUserTypeFriend,
    kUserTypeBaby,
    kUserTypeNanny,
    kUserTypeALL
} GBUserType;

typedef enum{
    kHabit,
    kTask,
    kUser,
    kRelation
} GBObjectType;

typedef enum{
    kFriend,
    kNanny
} GBRelationType;

typedef enum{
    kRelationStatusPending,
    kRelationStatusConfirmed,
    kRelationStatusRejected
} GBRelationStatus;

typedef enum{
    kSyncUpdateSince,
    kSyncCreateSince
} GBSyncAttr;

+ (GBDataModelManager*) getDataModelManager;


/*  
 *   HABIT RELATED METHODS 
 */


/**
   
   Create a new habit for current user.
 
   @param habitName        the name of the habiit
   @param habitStartDate   the date when the habit will start
   @param habitFrequency   the frequency the habit should be exerciesed. 
   @param attempts         the number of tasks to be created
   @return success or fail
 */

- (bool) createHabit:(NSString*) habitName
                      withStartDate:(NSDate*) habitStartDate
                      withFrequency: (HabitFrequency)habitFrequency
                      withAttempts: (int) attempts
                      withDescription: (NSString*) desc;   



/**
 
 Create a new habit for a specific user.
 
 @param userName         the name of the owner
 @param habitName        the name of the habiit
 @param nannyName        the user name of the nanny
 @param habitStartDate   the date when the habit will start
 @param habitFrequency   the frequency the habit should be exerciesed. 
 @param attempts         the number of tasks to be created
 @return success or fail
 */

- (bool) createHabitForUserWithNanny:(NSString*) userName
                       withName:(NSString*) habitName
                       withNannyName: (NSString*) nannyName
                       withStartDate:(NSDate*) habitStartDate
                       withFrequency: (HabitFrequency)habitFrequency
                       withAttempts: (int) attempts
                       withDescription: (NSString*) desc;

/**
 
 Create a new habit for a specific user.
 
 @param userName         the name of the owner
 @param habitName        the name of the habiit
 @param habitStartDate   the date when the habit will start
 @param habitFrequency   the frequency the habit should be exerciesed. 
 @param attempts         the number of tasks to be created
 @return success or fail
 */

- (bool) createHabitForUser:(NSString*) userName
                   withName:(NSString*) habitName
                   withStartDate:(NSDate*) habitStartDate
                   withFrequency: (HabitFrequency)habitFrequency
                   withAttempts: (int) attempts
                   withDescription: (NSString*) desc;


- (bool) createHabitWithRemoteHabit: (PFObject*) remoteHabit;

/**
 
 Retrieve all habits that associate with currentUser , baby, or both. 
 
 @param userType        specify whether to retrieve habits that belongs to current user, belong to baby, or both
 @return a list of habits with type "GBHabit"
 */

- (NSArray *) getAllHabitsByType:(GBUserType) userType;


/**
 
 Retrieve all habits that associate with a particular user. 
 
 @param ownerName  the name of the user
 @return a list of habits with type "GBHabit"
 */

- (NSArray *) getAllHabitsByOwnerName:(NSString*) ownerName;


/**
 
 Retrieve all habits that associate with a list of users. 
 
 @param ownerName  the name of the users
 @return a list of habits with type "GBHabit"
 */
- (NSArray *) getAllHabitsByOwnerNames:(NSArray*) ownerNames;



/**
 
 Retrieve Habit object with given ID
 
 @param habitID   the ID of the habit
 @return habit object
 */
- (GBHabit*) getHabitByID : (NSString*) habitID;


/**
 
 Change the status of the habit. 
 
 @param habitID      the ID of the habit
 @param habitStatus  the new status of the habit
 @return a list of habits with type "HabitTypeObject"
 */
- (void) setHabitStatus: (NSString*) habitID 
             withStatus:(HabitStatus) habitStatus;

/**
 
 Delete a habit. All the associated tasks will be deleted as well.  
 
 @param habitID  the ID of the habit
 */
- (void) deleteHabitByID:(NSString*)habitID;


/*  
 *   TASK RELATED METHODS 
 */

/**
 
 Create a list of tasks associated with a habit
 
 @param habitName      the name of the habit
 @param habitID        the ID of the habit
 @param taskOwner      the name of the owner
 @param taskTargetDate the date where the task should be completed
 @return success or failure
 */
- (bool) createTaskForHabit: (GBHabit*) habitName
                              withTargetDate:(NSDate*) taskTargetDate;


- (bool) createTaskWithRemoteTask: (PFObject*) remoteTask;

/**
 
 Mark a particular task as completed
 
 @param taskID  ID of the task
 */

- (void) setTaskStatus:(NSString*) taskID taskStatus:(TaskStatus) taskStatus;

/**
 
 Retrieve all tasks that associate with current User , baby, or both. 
 
 @param userType        specify whether to retrieve takss that belongs to current user, belong to baby, or both
 @return a list of task with type "TaskTypeObject"
 */

- (NSArray *) getAllTasks:(GBUserType) userType;



/**
 
 Retrieve all tasks that associated with a specific Habit
 
 @param habitID  the ID of the habit
 @return a list of task with type "TaskTypeObject"
 */
- (NSArray *) getTasksWithHabitID:(NSString*) habitID;



- (NSArray *) getRecentTask: (GBUserType) userType withPeriod:(int)days;

/*  
 *   USER/FRIEND RELATED METHODS 
 */

/**
 
 Create an object that represents local user
 
 @param ownerName  the name of current User
 @param nickName   the name used for display purpose
 @param password   the secrets
 
 @return success or failure
 */

- (bool) createUser: (NSString *) ownerName
            withPassword: (NSString*) password;



/**
 
 Retrieve User object with given name
 
 @param username   the name of the user
 @return user object
 */

- (GBUser*) getUserByName : (NSString*) username;

/**

 Retrieve User object with given name
 
 @param type   user type. It could be internal ( current owner), friends, or both
 @return users of that type
 
 */
 
- (NSArray*) getUserByType : (GBUserType) userType;

/**
 
 Add a new frend for current user
 
 @param email  the name of the user
 @return success or failure
 */
- (bool) createFriend: (NSString*) username;

/**
 
 Setup Nanny relathionship with a particular friend
 
 @param UserID  the user name of the friend
 @param HabitID the ID of the habit 
 */
- (bool) createNanny: (NSString*) username withHabitID:(NSString*) HabitID;

/**
 
 Retreive all the frineds of current user
 
 @return a list of user names (NSString)
 */
- (NSArray *) getFriendList;


/**
 
 Retreive a list of user that acting as the Nanny of current user
 
 @return a list of user names (NSString)
 */
- (NSArray *) getNannyList;




//- (NSArray *) getAllRelations;


/*  
 *   Helper functions
 */
- (void)SyncData;
- (NSArray *) getTaskSchedule: (NSDate*) startDate withFrequency: (NSString*) frequency withAttempts: (int) attempts;
- (NSArray*)queryManagedObject: (GBObjectType)type withPredicate:(NSPredicate *)predicate;
- (NSArray *) getLocalObjects: (NSDate *) date withObjectType: (GBObjectType) objType withAttr: (GBSyncAttr) attr ; 
- (NSManagedObject *) getLocalObjectByAttribute: (NSString*) attributeName withAttributeValue: (NSString*) attributeValue withObjectType: (GBObjectType) objType;


+ (NSString *)createLocalUUID;

@end
