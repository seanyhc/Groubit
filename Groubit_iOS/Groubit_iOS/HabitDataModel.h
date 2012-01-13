//
//  HabitDataModel.h
//  Groubit_alpha
//
//  Created by Jeffrey on 7/26/11.
//  Copyright 2011 NTU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HabitTypeObject.h"

@interface HabitDataModel : NSObject {
    
}

typedef enum {
    kUserTypeInternal = 0,
    kUserTypeFriend = 1,
    kUserTypeALL = 2
} UserType;

+ (HabitDataModel*) getDataModel;


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
                      withAttempts: (int) attempts;   


/**
 
 Retrieve all habits that associate with currentUser , baby, or both. 
 
 @param userType        specify whether to retrieve habits that belongs to current user, belong to baby, or both
 @return a list of habits with type "HabitTypeObject"
 */

- (NSArray *) getAllHabits:(int) userType;


/**
 
 Retrieve all habits that associate with a particular user. 
 
 @param ownerName  the name of the user
 @return a list of habits with type "HabitTypeObject"
 */

- (NSArray *) getAllHabitsByOwnerName:(NSString*) ownerName;


/**
 
 Retrieve all habits of current user where the specified user is the Nanny 
 
 @param friendName  the name of the user
 @return a list of habits with type "HabitTypeObject"
 */
- (NSArray *) getMyNanniedHabits:(NSString*) friendName;

/**
 
 Retrieve all habits of a particular friend where the current user is the Nanny 
 
 @param friendName  the name of the user
 @return a list of habits with type "HabitTypeObject"
 */
- (NSArray *) getMyBabyHabits:(NSString*) friendName;

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

/**
 
 Delete a habit. All the associated tasks will be deleted as well.  
 
 @param habitID  the name of the habit
 */
- (void) deleteHabitByName:(NSString*)habitName;



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
- (bool) createTaskForHabit: (NSString*) habitName
             withHabitID:(NSString*) habitID
             withTaskOwner:(NSString*) taskOwner
             withTargetDate:(NSDate*) taskTargetDate;


/**
 
 Mark a particular task as completed
 
 @param taskID  ID of the task
 */

- (void) markTaskCompletedByID:(NSString*) taskID;

/**
 
 Retrieve all tasks that associate with current User , baby, or both. 
 
 @param userType        specify whether to retrieve takss that belongs to current user, belong to baby, or both
 @return a list of task with type "TaskTypeObject"
 */

- (NSArray *) getAllTasks:(int) userType;

/**
 
 Retrieve all tasks that belongs the Baby of current User

 @return a list of task with type "TaskTypeObject"
 */
- (NSArray *) getMyBabyTasks;



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

- (bool) createLocalUser: (NSString *) ownerName
            withNickName: (NSString*) nickName 
            withPassword: (NSString*) password;

/**
 
 Add a new frend for current user
 
 @param email  the email address of the friend 
 */
- (bool) createFriend: (NSString*) email;

/**
 
 Setup Nanny relathionship with a particular friend
 
 @param UserID  the user ID of the friend
 @param HabitID the ID of the habit 
 */
- (bool) createNanny: (NSString*) UserID withHabitID:(NSString*) HabitID;

/**
 
 Retreive all the frineds of current user
 
 @return a list of user object of type "UserTypeObject"
 */
- (NSArray *) getFriendList;

/**
 
 Retreive a list of user that acting as the Nanny of current user
 
 @return a list of user object of type "UserTypeObject"
 */
- (NSArray *) getNannyList;



/*  
 *   Helper functions
 */

- (NSArray *) getTaskSchedule: (NSDate*) startDate withFrequency: (NSString*) frequency withAttempts: (int) attempts;

+ (NSString *)createLocalUUID;

@end
