//
//  DebugViewController.m
//  Groubit_iOS
//
//  Created by Jeffrey on 2/4/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import "DebugViewController.h"
#import "GBDataModelManager.h"
#import "GBHabit.h"
#import "GBTask.h"
#import "GBUser.h"
#import "GBNotification.h"
#import "Groubit_iOSAppDelegate.h"
#import "TaipeiStation.h"
#import "Parse/Parse.h"

@implementation DebugViewController

@synthesize localUserName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Debug"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self initTestData];
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSLog(@" view did load. Local user : %@", dataModel.localUserName);
    
    [localUserName setText:dataModel.localUserName];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shuldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - GUI Triggered Actions

- (IBAction)changeUserName:(id)sender{
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    dataModel.localUserName = [localUserName text];
    
    NSLog(@"Current local user : %@", dataModel.localUserName);
    
}

- (IBAction)initTestData:(id)sender{
    
    NSLog(@"Enter DashboardViewControll::createHabit");
    
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    // set local user
    [dataModel setLocalUserName:@"Jeffrey"];
    
    // create users
    [dataModel createUser:@"Jeffrey" withPassword:@"1234"];
    [dataModel createUser:@"Joey" withPassword:@"1234"];
    [dataModel createUser:@"Sean" withPassword:@"1234"];
    
    // create habits
    [dataModel createHabitForUser:@"Jeffrey" withName:@"Jeffrey_Habit1" withStartDate:[NSDate date] withFrequency:kDaily withAttempts:7 withDescription:@"Habit1 for Jeffrey"];
    
    [dataModel createHabitForUser:@"Jeffrey" withName:@"Jeffrey_Habit2" withStartDate:[NSDate date] withFrequency:kWeekly withAttempts:7 withDescription:@"Habit2 for Jeffrey"];
    
    [dataModel createHabitForUserWithNanny:@"Jeffrey" withName:@"Jeffrey_Habit3" withNannyName:@"Joey" withStartDate:[NSDate date] withFrequency:kWeekly withAttempts:7 withDescription:@"Habit3 for Jeffrey"];
    
    
    [dataModel createHabitForUser:@"Joey" withName:@"Joey_Habit1" withStartDate:[NSDate date] withFrequency:kDaily withAttempts:7 withDescription:@"Habit1 for Joey"];
    
    [dataModel createHabitForUser:@"Joey" withName:@"Joey_Habit2" withStartDate:[NSDate date] withFrequency:kWeekly withAttempts:7 withDescription:@"Habit2 for Joey"];
    
    [dataModel createHabitForUser:@"Sean" withName:@"Sean_Habit1" withStartDate:[NSDate date] withFrequency:kDaily withAttempts:7 withDescription:@"Habit1 for Sean"];
    
    [dataModel createHabitForUser:@"Sean" withName:@"Sean_Habit2" withStartDate:[NSDate date] withFrequency:kWeekly withAttempts:7 withDescription:@"Habit2 for Sean"];
    
    
    
    // setup relationship
    [dataModel createFriend:@"Sean"];
    [dataModel createFriend:@"Joey"];    
    //[dataModel createNanny:@"Sean" withHabitID:<#(NSString *)#>]
    
    
    
    
    
    
    
}

- (IBAction)cleanParseData:(id)sender{
    
    
    PFQuery *userQuery = [PFQuery queryWithClassName:@"GBUser"];
    NSArray *userList = [userQuery findObjects];
    
    
    if( userList && userList.count == 0){
        
        NSLog(@"No User object stored in Parse.");
        
    }
    
    for(PFObject* user in userList){
        
        NSLog(@"userID:%@", [user objectForKey:@"UserID"]);
        
        [user deleteInBackground];
    }
    
    
    PFQuery *habitQuery = [PFQuery queryWithClassName:@"GBHabit"];
    NSArray *habitList = [habitQuery findObjects];
    
    
    if( habitList && habitList.count == 0){
        
        NSLog(@"No Habit object stored in Parse.");
        
    }
    
    for(PFObject* habit in habitList){
        
        NSLog(@"HabitID:%@", [habit objectForKey:@"HabitID"]);
        
        [habit deleteInBackground];
    }
    
    
    PFQuery *taskQuery = [PFQuery queryWithClassName:@"GBTask"];
    NSArray *taskList = [taskQuery findObjects];
    
    
    if( taskList && taskList.count == 0){
        
        NSLog(@"No Task object stored in Parse.");
        
    }
    
    for(PFObject* task in taskList){
        
        NSLog(@"TaskID:%@", [task objectForKey:@"TaskID"]);
        
        [task deleteInBackground];
    }
    
    
    
    
    
}



- (IBAction)getAllHabitsByOwnerName:(id)sender{
    
    NSLog(@"Enter DashboardViewControll::getAllHabitsByOwnerName");
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSArray* habits = nil;
    
    NSLog(@"Test 1: get all habits by current user");
    
    habits = [dataModel getAllHabitsByType:kUserTypeInternal];
    
    for(int i=0; i < [habits count]; i++){
        GBHabit* habit = (GBHabit*)[habits objectAtIndex:i];
        NSLog(@"Retrived Habit Name: %@, HabitID: %@, HabitOwner: %@, HabitStartDate: %@", habit.HabitName, habit.HabitID, habit.HabitOwner,habit.HabitStartDate);
    }
    
    NSLog(@"Test 2: get all habits by friends");
    
    habits = [dataModel getAllHabitsByType:kUserTypeFriend];
    
    for(GBHabit* habit in habits){
        NSLog(@"Retrived Habit Name: %@, HabitID: %@, HabitOwner: %@, HabitStartDate: %@", habit.HabitName, habit.HabitID, habit.HabitOwner,habit.HabitStartDate);
    }
    
    NSLog(@"Test 3: get all habits for both local use and friends");
    
    habits = [dataModel getAllHabitsByType:kUserTypeALL];
    
    for(GBHabit* habit in habits){
        NSLog(@"Retrived Habit Name: %@, HabitID: %@, HabitOwner: %@, HabitStartDate: %@, HabitStatus: %@", habit.HabitName, habit.HabitID, habit.HabitOwner,habit.HabitStartDate, habit.HabitStatus);
    }
    
    
    
}

- (IBAction)getAllTasks:(id)sender{
    
    NSLog(@"Enter DashboardViewControll::getAllTasks");
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSArray* tasks = [dataModel getAllTasks:kUserTypeInternal];
    
    for(int i=0; i < [tasks count]; i++){
        GBTask* task = (GBTask*)[tasks objectAtIndex:i];
        NSLog(@"Retrived TaskID: %@, TargetDate: %@, Status: %@, createAt:%@, updateAt:%@", task.TaskID, task.TaskTargetDate, task.TaskStatus, task.createAt, task.updateAt);
    }
    
}

- (IBAction)setHabitCompleted:(id)sender{
    
    NSLog(@"Enter DashboardViewControll::setHabitCompleted");
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSLog(@"Test 1: get all habits by current user");
    
    NSArray *habits = [dataModel getAllHabitsByType:kUserTypeInternal];
    
    for(int i=0; i < [habits count]; i++){
        GBHabit* habit = (GBHabit*)[habits objectAtIndex:i];
        NSLog(@"Retrived Habit Name: %@, HabitID: %@, HabitOwner: %@, HabitStartDate: %@", habit.HabitName, habit.HabitID, habit.HabitOwner,habit.HabitStartDate);
        
        if (i == 0){
            [dataModel setHabitStatus:habit.HabitID withStatus:kHabitStatusCompleted];
        }
    }
    
}

- (IBAction)setTaskCompleted:(id)sender{
    
    NSLog(@"Enter DashboardViewControll::setTaskCompleted");
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSLog(@"Test 1: get all habits by current user");
    
    
    NSArray* tasks = [dataModel getAllTasks:kUserTypeInternal];
    
    for(int i=0; i < [tasks count]; i++){
        GBTask* task = (GBTask*)[tasks objectAtIndex:i];
        NSLog(@"Retrived TaskID: %@, TargetDate: %@, Status: %@", task.TaskID, task.TaskTargetDate, task.TaskStatus);
        
        if( i==0){
            [dataModel setTaskStatus:task.TaskID taskStatus:kTaskStatusCompleted];
        }
    }
    
}

- (IBAction)getFriends:(id)sender{
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    // test 1 get friend
    NSArray *friendList = [dataModel getFriendList];
    for (NSString *friend in friendList){
        NSLog(@"%@ has friend:%@", dataModel.localUserName, friend);
    }
}

- (IBAction)getNanny:(id)sender{
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSArray *nannyList = [dataModel getNannyList];
    for (NSString *nannyName in nannyList){
        NSLog(@"%@ has nanny:%@", dataModel.localUserName,nannyName);
    }
    
}

- (IBAction)syncNow:(id)sender
{
    TaipeiStation* ts = [TaipeiStation getSyncEngine];
    [ts syncAll];
    
}


- (IBAction)printParseObjects:(id)sender
{
    // print user
    
    
    PFQuery *userQuery = [PFQuery queryWithClassName:@"GBUser"];
    NSArray *pfUsers = [userQuery findObjects];
    
    NSLog(@" Retreived %d users", pfUsers.count);
    
    for( PFObject *user in pfUsers){
        
        NSLog(@" User: %@", user  );
    }
    
    // print relation
    
    PFQuery *relationQuery = [PFQuery queryWithClassName:@"GBRelations"];
    NSArray *pfRelations = [relationQuery findObjects];
    
    NSLog(@" Retreived %d relations", pfRelations.count);
    
    for( PFObject *relation in pfRelations){
        
        NSLog(@" Relation: %@", relation  );
    }
    
    
    
    // print habits
    
    
    PFQuery *habitQuery = [PFQuery queryWithClassName:@"GBHabit"];
    NSArray *pfHabits = [habitQuery findObjects];
    
    NSLog(@" Retreived %d habits", pfHabits.count);
    
    for( PFObject *habit in pfHabits){
        
        NSLog(@" Habit: %@", habit  );
    }
    
    
    // print tasks
    
    PFQuery *taskQuery = [PFQuery queryWithClassName:@"GBTask"];
    NSArray *pfTasks = [taskQuery findObjects];
    
    NSLog(@" Retreived %d tasks", pfTasks.count);
    
    for( PFObject *task in pfTasks){
        
        NSLog(@" Task: %@", task  );
    }
    
    // print notifications
    
    PFQuery *notificationQuery = [PFQuery queryWithClassName:@"GBNotification"];
    NSArray *pfNotifications = [notificationQuery findObjects];
    
    NSLog(@" Retreived %d notifications", pfNotifications.count);
    
    for( PFObject *notification in pfNotifications){
        
        NSLog(@" Notification: %@", notification  );
    }

    
}


- (IBAction)printLocalObjects:(id)sender
{
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSArray *users  = [dataModel getUserByType:kUserTypeALL];
    
    NSLog(@" Retrieved %d users", users.count);
    
    for(GBUser *user in users){
        
        NSLog(@"Local User:%@", user);
    }
    
    NSArray *habits = [dataModel getAllHabitsByType:kUserTypeALL];
    
    NSLog(@" Retrieved %d habits", habits.count);
    
    for(GBHabit *habit in habits){
        
        NSLog(@"Local Habit:%@", habit);
    }
   
    
    NSArray *tasks = [dataModel getAllTasks:kUserTypeALL];
    
    NSLog(@" Retrieved %d tasks", tasks.count);
    
    for(GBTask *task in tasks){
        
        NSLog(@"Local Task:%@", task);
    }
    
    NSArray *notifications = [dataModel getAllNotifications];
    
    NSLog(@"Retrieved %d notifications", notifications.count);
    
    for(GBNotification *notification in notifications){
        
        NSLog(@"Local Notification:%@", notification);
    }
    

}

- (IBAction)createHabit:(id)sender
{
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    [dataModel createHabitForUser:@"Jeffrey" withName:@"Jeffrey_Habit4" withStartDate:[NSDate date] withFrequency:kDaily withAttempts:7 withDescription:@"Habit4 for Jeffrey"];
}

- (IBAction)createRemoteHabit:(id)sender
{
    
    NSLog(@"Create new habit on remote." );
    PFObject *pfHabit = [PFObject objectWithClassName:@"GBHabit"];
    [pfHabit setObject:@"12345" forKey:@"HabitID"];
    [pfHabit setObject:@"RemoteHabitName" forKey:@"HabitName"];
    [pfHabit setObject:@"Jeffrey" forKey:@"HabitOwner"];
    [pfHabit setObject:@"Remote Habit" forKey:@"HabitDescription"];
    [pfHabit setObject:@"weekly" forKey:@"HabitFrequency"];
    [pfHabit setObject:[NSNumber numberWithInt:7] forKey:@"HabitAttempts"];
    [pfHabit setObject:@"init" forKey:@"HabitStatus"];
    [pfHabit setObject:[NSDate date] forKey:@"HabitStartDate"];
    
    [pfHabit saveInBackground];
    
    
    pfHabit = [PFObject objectWithClassName:@"GBHabit"];
    [pfHabit setObject:@"6789" forKey:@"HabitID"];
    [pfHabit setObject:@"RemoteHabitName111" forKey:@"HabitName"];
    [pfHabit setObject:@"Joey" forKey:@"HabitOwner"];
    [pfHabit setObject:@"Remote Habit111" forKey:@"HabitDescription"];
    [pfHabit setObject:@"weekly" forKey:@"HabitFrequency"];
    [pfHabit setObject:[NSNumber numberWithInt:7] forKey:@"HabitAttempts"];
    [pfHabit setObject:@"init" forKey:@"HabitStatus"];
    [pfHabit setObject:[NSDate date] forKey:@"HabitStartDate"];
    
    [pfHabit saveInBackground];
    
}
- (IBAction)updateRemoteHabit:(id)sender
{
    
    PFQuery *newHabitQuery = [PFQuery queryWithClassName:@"GBHabit"];
    [newHabitQuery whereKey:@"HabitOwner" equalTo:@"Jeffrey"];
    [newHabitQuery whereKey:@"HabitID" equalTo:@"12345"];
    
    NSArray *newPFHabits = [newHabitQuery findObjects];
    
    PFObject *habit = [newPFHabits lastObject];
    
    [habit setObject:@"completed" forKey:@"HabitStatus"];
    
    [habit saveInBackground];
    
    newHabitQuery = [PFQuery queryWithClassName:@"GBHabit"];
    [newHabitQuery whereKey:@"HabitOwner" equalTo:@"Joey"];
    [newHabitQuery whereKey:@"HabitID" equalTo:@"6789"];
    
    newPFHabits = [newHabitQuery findObjects];
    
    habit = [newPFHabits lastObject];
    
    [habit setObject:@"completed" forKey:@"HabitStatus"];
    
    [habit saveInBackground];
    
    
}
- (IBAction)updateLocalHabit:(id)sender
{
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    GBHabit *habit = (GBHabit*)[dataModel getLocalObjectByAttribute:@"HabitName" withAttributeValue:@"Jeffrey_Habit4" withObjectType:kHabit];
    
    NSArray *habits = [dataModel getAllHabitsByOwnerName:@"Jeffrey"];
    
    
    if(!habit || habits.count == 0 )
        NSLog(@" no habit retrieved");
    
    for( GBHabit *habit in habits){
        habit.HabitStatus = [NSString stringWithString:@"completed"];
        habit.updateAt = [NSDate date];
        [dataModel SyncData];
        
    }
    
    
    
}

- (IBAction)startSyncTimer:(id)sender{
    [TaipeiStation enableRegularSync];
}
- (IBAction)stopSyncTimer:(id)sender{
    TaipeiStation *syncEngine = [TaipeiStation getSyncEngine];
    [syncEngine stopSyncTimer];
}

- (IBAction)userDefinedAction1:(id)sender
{
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    [dataModel createNotification:@"New Friend Request From Joey" fromUser:@"Joey" toUser:@"Jeffrey" status:kNotificationStatusNew type:kFriendRequest];
    [dataModel SyncData];
    
}

- (IBAction)userDefinedAction2:(id)sender
{

    
    
    NSLog(@"Create new Notification on remote." );
    PFObject *pfNotification = [PFObject objectWithClassName:@"GBNotification"];
    [pfNotification setObject:@"12345" forKey:@"notificationID"];
    [pfNotification setObject:@"From A to B" forKey:@"text"];
    [pfNotification setObject:@"new" forKey:@"status"];
    [pfNotification setObject:@"new" forKey:@"type"];
    [pfNotification setObject:@"Joey" forKey:@"fromUser"];
    [pfNotification setObject:@"Jeffrey" forKey:@"toUser"];
    
    [pfNotification saveInBackground];

    
}

- (IBAction)userDefinedAction3:(id)sender
{

}



@end
