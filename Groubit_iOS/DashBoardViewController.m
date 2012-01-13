//
//  DashBoardViewController.m
//  Groubit_iOS
//
//  Created by Sean Chen on 12/28/11.
//  Copyright 2011 UCB MIMS. All rights reserved.
//

#import "DashBoardViewController.h"
#import "HabitDataModel.h"
#import "HabitTypeObject.h"

@implementation DashBoardViewController

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

- (IBAction)createHabit:(id)sender{
    
    NSLog(@"enter createHabit");
    
    
    HabitDataModel* dataModel = [HabitDataModel getDataModel];
    
    
    [dataModel createHabit:@"MyHabit" withStartDate:[NSDate date] withFrequency:kWeekly withAttempts:3];
    
}

- (IBAction)getAllHabitsByOwnerName:(id)sender{
    
    NSLog(@"enter getAllHabitsByOwnerName");
    
    
    HabitDataModel* dataModel = [HabitDataModel getDataModel];
    
    NSArray* habits = [dataModel getAllHabitsByOwnerName:@"Bob"];
    
    for(int i=0; i < [habits count]; i++){
        HabitTypeObject* habit = (HabitTypeObject*)[habits objectAtIndex:i];
        NSLog(@"Retrived Habit Name: %@, HabitID: %@, HabitOwner: %@, HabitStartDate: %@", habit.HabitName, habit.HabitID, habit.HabitOwner,habit.HabitStartDate);
    }
    
}

@end
