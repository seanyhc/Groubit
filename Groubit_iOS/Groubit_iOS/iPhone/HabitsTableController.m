//
//  HabitsTableController.m
//  Groubit_iOS
//
//  Created by Sean Chen on 1/28/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import "HabitsTableController.h"
#import "GBDataModelManager.h"
#import "GBHabit.h"
#import "GBTask.h"
#import "GBUser.h"
#import "Groubit_iOSAppDelegate.h"
#import "TaipeiStation.h"
#import "Parse/Parse.h"


@implementation HabitsTableController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Habits"];
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

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"start: HabitsTableController: viewDidLoad");
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    NSArray *tempArray = [dataModel getAllHabitsByType:kUserTypeInternal];
    
    // * the arrayWithArray method that failed
    //habitsList = [NSMutableArray arrayWithArray:tempArray];
    habitsList = [[NSMutableArray alloc] init];
    
    for(int i=0; i < [tempArray count]; i++){
        GBHabit* habit = (GBHabit*)[tempArray objectAtIndex:i];
        [habitsList addObject:habit];
        
    }

    for(int i=0; i < [habitsList count]; i++){
        GBHabit* habit = (GBHabit*)[habitsList objectAtIndex:i];
        NSLog(@"Retrived Habit Name: %@, HabitID: %@, HabitOwner: %@, HabitStartDate: %@", habit.HabitName, habit.HabitID, habit.HabitOwner,habit.HabitStartDate);
    }
    
    NSLog(@"habitsList count1: %d", [habitsList count]);
    NSLog(@"end: HabitsTableController: viewDidLoad");
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"habitsList count: %d", [habitsList count]);
    return [habitsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"start: cellForRowAtIndexPath");
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"] autorelease];
    GBHabit *habit = [habitsList objectAtIndex:[indexPath row]];
    [cell.textLabel setText:habit.HabitName];
    [cell.detailTextLabel setText:habit.HabitOwner];

    return cell;
}

@end
