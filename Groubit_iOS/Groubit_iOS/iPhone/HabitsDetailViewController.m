//
//  HabitsViewController.m
//  Groubit_iOS
//
//  Created by Sean Chen on 12/28/11.
//  Copyright 2011 UCB MIMS. All rights reserved.
//

#import "HabitsDetailViewController.h"

#import "GBHabit.h"

@implementation HabitsDetailViewController

@synthesize currentHabit;

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
    [[self view] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationItem] setTitle:currentHabit.HabitName];
    
    [nameLabel setText:currentHabit.HabitName];
    [descLabel setText:currentHabit.HabitDescription];
    [freqLabel setText:currentHabit.HabitFrequency];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [nameLabel release];
    nameLabel = nil;
    
    [descLabel release];
    descLabel = nil;
    
    [freqLabel release];
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

- (void)dealloc
{
    [nameLabel release];
    
    [descLabel release];
    
    [freqLabel release];
    
    [super dealloc];

}

@end
