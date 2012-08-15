//
//  FriendsTableController.m
//  Groubit_iOS
//
//  Created by Sean Chen on 12/28/11.
//  Copyright 2011 UCB MIMS. All rights reserved.
//

#import "FriendsTableController.h"
#import "GBDataModelManager.h"
#import "GBHabit.h"
#import "GBTask.h"
#import "GBUser.h"

#import "DDLog.h"

// Debug levels: off, fatal, error, warn, notice, info, debug
static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation FriendsTableController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //UITabBarItem *tbi = [self tabBarItem];
        //[tbi setTitle:@"Friends"];
        
        friendsList = [[NSMutableArray alloc] init];
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
        [[self navigationItem] setRightBarButtonItem:addButton];
        [[self navigationItem] setTitle:@"Friends"];
        
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

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"start: FriendsTableController: viewWillAppear");
    // Refresh the friend list
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    NSArray *tempArray = [dataModel getFriendList];
    [friendsList removeAllObjects];
    
    for(int i=0; i < [tempArray count]; i++){
        NSString *friendName = (NSString*)[tempArray objectAtIndex:i];
        [friendsList addObject:friendName];
    }
    
    
    /*
     //just for debugging
     for(int i=0; i < [habitsList count]; i++){
     GBHabit* habit = (GBHabit*)[habitsList objectAtIndex:i];
     NSLog(@"Retrived Habit Name: %@, HabitID: %@, HabitOwner: %@, HabitStartDate: %@", habit.HabitName, habit.HabitID, habit.HabitOwner,habit.HabitStartDate);
     }
     */
    
    [[self tableView] reloadData];
    DDLogInfo(@"friendsList count: %d", [friendsList count]);
    DDLogInfo(@"end: FriendsTableController: viewWillAppear");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DDLogInfo(@"friendsList count: %d", [friendsList count]);
    return [friendsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogInfo(@"start: cellForRowAtIndexPath");
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    NSString *friendName = [friendsList objectAtIndex:[indexPath row]];
    [cell.textLabel setText:friendName];
    //[cell.detailTextLabel setText:habit.HabitDescription];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!friendsDetailController){
        friendsDetailController = [[FriendsDetailViewController alloc] init];
    }
    
    //[habitsDetailController setCurrentHabit:[habitsList objectAtIndex:[indexPath row]]];
    
    [[self navigationController] pushViewController:friendsDetailController animated:YES];
}


-(void)addButtonPressed{
    DDLogInfo(@"Add Friend addButton pressed");
    
    if(!friendsAddController){
        friendsAddController = [[FriendsAddViewController alloc] init];
    }
    
    [self.navigationController pushViewController:friendsAddController animated:YES];
}
@end
