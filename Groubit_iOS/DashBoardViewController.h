//
//  DashBoardViewController.h
//  Groubit_iOS
//
//  Created by Sean Chen on 12/28/11.
//  Copyright 2011 UCB MIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashBoardViewController : UIViewController
{
    IBOutlet UITextField *localUserName;
}

@property (nonatomic, retain) UITextField *localUserName;

- (IBAction)changeUserName:(id)sender;

- (IBAction)initTestData:(id)sender;
- (IBAction)createHabit:(id)sender;
- (IBAction)getAllHabitsByOwnerName:(id)sender;
- (IBAction)getAllTasks:(id)sender;
- (IBAction)setHabitCompleted:(id)sender;
- (IBAction)setTaskCompleted:(id)sender;
- (IBAction)getFriends:(id)sender;
- (IBAction)getNanny:(id)sender;


/*
- (IBAction)updateHabit:(id)sender;


- (IBAction)createTask:(id)sender;
- (IBAction)updateTask:(id)sender;
- (IBAction)getAllTasks:(id)sender;

- (IBAction)createFriend:(id)sender;
*/


@end
