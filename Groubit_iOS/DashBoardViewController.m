//
//  DashBoardViewController.m
//  Groubit_iOS
//
//  Created by Sean Chen on 12/28/11.
//  Copyright 2011 UCB MIMS. All rights reserved.
//

#import "DashBoardViewController.h"
#import "GBDataModelManager.h"
#import "GBHabit.h"
#import "GBTask.h"
#import "GBUser.h"
#import "Groubit_iOSAppDelegate.h"

@implementation DashBoardViewController

@synthesize localUserName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [dataModel createHabitForUser:@"Jeffrey" withName:@"Jeffrey_Habit1" withStartDate:[NSDate date] withFrequency:kDaily withAttempts:7];
    
    [dataModel createHabitForUser:@"Jeffrey" withName:@"Jeffrey_Habit2" withStartDate:[NSDate date] withFrequency:kWeekly withAttempts:7];
    
    [dataModel createHabitForUserWithNanny:@"Jeffrey" withName:@"Jeffrey_Habit3" withNannyName:@"Joey" withStartDate:[NSDate date] withFrequency:kWeekly withAttempts:7];
    
    
    [dataModel createHabitForUser:@"Joey" withName:@"Joey_Habit1" withStartDate:[NSDate date] withFrequency:kDaily withAttempts:7];
    
    [dataModel createHabitForUser:@"Joey" withName:@"Joey_Habit2" withStartDate:[NSDate date] withFrequency:kWeekly withAttempts:7];
    
    [dataModel createHabitForUser:@"Sean" withName:@"Sean_Habit1" withStartDate:[NSDate date] withFrequency:kDaily withAttempts:7];
    
    [dataModel createHabitForUser:@"Sean" withName:@"Sean_Habit2" withStartDate:[NSDate date] withFrequency:kWeekly withAttempts:7];
    
    
    
    // setup relationship
    [dataModel createFriend:@"Sean"];
    [dataModel createFriend:@"Joey"];    
    //[dataModel createNanny:@"Sean" withHabitID:<#(NSString *)#>]
 
    
    
   
    
   

}

- (IBAction)createHabit:(id)sender{
    
    NSLog(@"Enter DashboardViewControll::createHabit");
    
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    
    [dataModel createHabit:@"MyHabit" withStartDate:[NSDate date] withFrequency:kWeekly withAttempts:3];
    
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
        NSLog(@"Retrived TaskID: %@, TargetDate: %@, Status: %@", task.TaskID, task.TaskTargetDate, task.TaskStatus);
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


@end
