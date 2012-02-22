//
//  HabitsAddController.m
//  Groubit_iOS
//
//  Created by Sean Chen on 2/10/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import "HabitsAddController.h"
#import "GBDataModelManager.h"

@implementation HabitsAddController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed)];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];
        [self.navigationItem setRightBarButtonItem:saveButton];
        [self.navigationItem setLeftBarButtonItem:cancelButton];
        [self.navigationItem setTitle:@"New Habit"];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [habitName release];
    habitName = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [habitName setText:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)saveButtonPressed
{
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    NSLog(@"Saving new habit with name:%@", habitName.text);
    //todo: need to get local user name
    [dataModel createHabitForUser:@"Jeffrey" withName:habitName.text withStartDate:[NSDate date] withFrequency:kDaily withAttempts:7 withDescription:@"New habit for Jeffrey"];  
    [self.navigationController popViewControllerAnimated:YES];   
}

- (void)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
