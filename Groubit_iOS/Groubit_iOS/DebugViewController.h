//
//  DebugViewController.h
//  Groubit_iOS
//
//  Created by Jeffrey on 2/4/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DebugViewController : UIViewController
{
    IBOutlet UITextField *localUserName;
}



@property (nonatomic, retain) UITextField *localUserName;

- (IBAction)changeUserName:(id)sender;

- (IBAction)initTestData:(id)sender;
- (IBAction)cleanParseData:(id)sender;
- (IBAction)getAllHabitsByOwnerName:(id)sender;
- (IBAction)getAllTasks:(id)sender;
- (IBAction)setHabitCompleted:(id)sender;
- (IBAction)setTaskCompleted:(id)sender;
- (IBAction)getFriends:(id)sender;
- (IBAction)getNanny:(id)sender;
- (IBAction)syncNow:(id)sender;

- (IBAction)printParseObjects:(id)sender;
- (IBAction)printLocalObjects:(id)sender;
- (IBAction)createHabit:(id)sender;

- (IBAction)createRemoteHabit:(id)sender;
- (IBAction)updateRemoteHabit:(id)sender;
- (IBAction)updateLocalHabit:(id)sender;

- (IBAction)startSyncTimer:(id)sender;
- (IBAction)stopSyncTimer:(id)sender;



@end
