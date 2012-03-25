//
//  HabitsViewController.m
//  Groubit_iOS
//
//  Created by Sean Chen on 12/28/11.
//  Copyright 2011 UCB MIMS. All rights reserved.
//

#import "HabitsDetailViewController.h"

#import "GBHabit.h"
#import "GBDataModelManager.h"
#import "GBTask.h"

@implementation HabitsDetailViewController

@synthesize currentHabit;
@synthesize taskTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        tasksList = [[NSMutableArray alloc] init];
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
    [[self view] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"start: HabitsDetailViewController: viewWillAppear");
    
    [super viewWillAppear:animated];
    
    [[self navigationItem] setTitle:currentHabit.HabitName];
    
    [nameLabel setText:currentHabit.HabitName];
    [descLabel setText:currentHabit.HabitDescription];
    [freqLabel setText:currentHabit.HabitFrequency];
    
    

    //refresh the habit list
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    NSArray *tempArray = [dataModel getTasksWithHabitID:currentHabit.HabitID];
    [tasksList removeAllObjects];
    
    for(int i=0; i < [tempArray count]; i++){
        GBTask* task = (GBTask*)[tempArray objectAtIndex:i];
        [tasksList addObject:task];
        
    }
    
    
    /*
     //just for debugging
     for(int i=0; i < [habitsList count]; i++){
     GBHabit* habit = (GBHabit*)[habitsList objectAtIndex:i];
     NSLog(@"Retrived Habit Name: %@, HabitID: %@, HabitOwner: %@, HabitStartDate: %@", habit.HabitName, habit.HabitID, habit.HabitOwner,habit.HabitStartDate);
     }
     */
    
    [taskTable reloadData];
    NSLog(@"habitsList count1: %d", [tasksList count]);
    NSLog(@"end: HabitsDetailViewController: viewWillAppear");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    nameLabel = nil;
    
    descLabel = nil;
    
    freqLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [nameLabel resignFirstResponder];
    [descLabel resignFirstResponder];
    [freqLabel resignFirstResponder];
    
    
    //if want to save change to habits
    //[currentHabit setHabitDescription:xxxField.text];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [tasksList count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
    //cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    //cell.textLabel.text = [NSString	 stringWithFormat:@"Cell Row #%d", [indexPath row]];
    
    GBTask *task = [tasksList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", task.TaskTargetDate ];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", task.TaskStatus ];
    
    UIImage *cellImage;
    NSLog(@"HabitsDetailViewController status: %d %@", indexPath.row, task.TaskStatus);
    if([task.TaskStatus isEqualToString:@"init"]){
        cellImage = [UIImage imageNamed:@"checkbox_unchecked.png"];      
    } else if([task.TaskStatus isEqualToString: @"completed"]){
        cellImage = [UIImage imageNamed:@"checkbox_checked.png"];

    }
    cell.imageView.image = cellImage;
        

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GBTask *task = [tasksList objectAtIndex:indexPath.row];
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    if([task.TaskStatus isEqualToString:@"init"]){
        [dataModel setTaskStatus:task.TaskID taskStatus:(kTaskStatusCompleted)];    
    } else if([task.TaskStatus isEqualToString: @"completed"]){
        [dataModel setTaskStatus:task.TaskID taskStatus:(kTaskStatusInit)];
        
    }
    
    
    [taskTable reloadData];

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Upcoming Tasks"; 
}


@end
