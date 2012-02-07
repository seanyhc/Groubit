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
#import "HabitsDetailViewController.h"


@implementation HabitsTableController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        /* 
        //since the root of this tab is a nav controller init in 
        //Groubit_iOSAppDelegate, there's no use init here
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Habits"];
        */
            
        habitsList = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] init];
        [addButton setTitle:@"Add"];
        [[self navigationItem] setRightBarButtonItem:addButton];
        [[self navigationItem] setTitle:@"Habits"];
        
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
    

    
    // * the arrayWithArray method that failed
    //habitsList = [NSMutableArray arrayWithArray:tempArray];

    NSLog(@"end: HabitsTableController: viewDidLoad");

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"start: HabitsTableController: viewWillAppear");
    //refresh the habit list
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    NSArray *tempArray = [dataModel getAllHabitsByType:kUserTypeInternal];
    [habitsList removeAllObjects];
    
    for(int i=0; i < [tempArray count]; i++){
        GBHabit* habit = (GBHabit*)[tempArray objectAtIndex:i];
        [habitsList addObject:habit];
        
    }
    

    /*
    //just for debugging
    for(int i=0; i < [habitsList count]; i++){
        GBHabit* habit = (GBHabit*)[habitsList objectAtIndex:i];
        NSLog(@"Retrived Habit Name: %@, HabitID: %@, HabitOwner: %@, HabitStartDate: %@", habit.HabitName, habit.HabitID, habit.HabitOwner,habit.HabitStartDate);
    }
    */
    
    [[self tableView] reloadData];
    NSLog(@"habitsList count1: %d", [habitsList count]);
    NSLog(@"end: HabitsTableController: viewWillAppear");
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
    [cell.detailTextLabel setText:habit.HabitDescription];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!habitsDetailController){
        habitsDetailController = [[HabitsDetailViewController alloc] init];
    }
    
    [habitsDetailController setCurrentHabit:[habitsList objectAtIndex:[indexPath row]]];
    
    [[self navigationController] pushViewController:habitsDetailController animated:YES];
}

@end
