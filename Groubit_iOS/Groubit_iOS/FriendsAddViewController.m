//
//  FriendsAddController.m
//  Groubit_iOS
//
//  Created by Joey Tseng on 3/18/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import "FriendsAddViewController.h"
#import "GBDataModelManager.h"

@implementation FriendsAddViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed)];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];
        
        [self.navigationItem setRightBarButtonItem:saveButton];
        [self.navigationItem setLeftBarButtonItem:cancelButton];
        [self.navigationItem setTitle:@"New Friend"];
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
    newFriendName = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)saveButtonPressed
{
    GBDataModelManager *dataModel = [GBDataModelManager getDataModelManager];
    NSLog(@"Saving New Friend with name: %@", newFriendName.text);
    
    [dataModel createFriend: newFriendName.text];
    
    // temp code
    NSArray *friendList = [dataModel getFriendList];
    NSUInteger i = 0;
    for (i = 0; i < [friendList count]; i ++)
    {
        NSLog(@"%@", [friendList objectAtIndex: i]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
