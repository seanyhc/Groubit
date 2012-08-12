//
//  RegisterLoginViewController.m
//  Groubit_iOS
//
//  Created by Joey Tseng on 2/10/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import "RegisterLoginViewController.h"
#import "Groubit_iOSAppDelegate.h"
#import "GBDataModelManager.h"
#import "GBHabit.h"
#import "GBTask.h"
#import "GBUser.h"
#import "Parse/Parse.h"

@implementation RegisterLoginViewController

@synthesize userName;
@synthesize passWord;
@synthesize loginWarn;

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - GUI Triggered Actions

- (IBAction)register:(id)sender{
    loginWarn.text = @"";

    PFUser *pfUser = [PFUser user];
    
    pfUser.username = [userName text];
    pfUser.password = [passWord text];
    pfUser.email = [userName text];
    
    [pfUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            PFUser *currentPFUser = [PFUser currentUser];
            
            if (currentPFUser) {
                // create a GB user based returned PF user
                NSLog(@"Current user name is %@", currentPFUser.username);
                // after (PF) user is successfully created on server, create local GB user
                GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
                
                // create GB user
                [dataModel createUser:pfUser.username withUserName:pfUser.username withPassword:pfUser.password];
                
                // set local GB user
                [dataModel setLocalUserName:pfUser.username];
                [dataModel setLocalUserID:pfUser.username];
            } 
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            // Show the errorString somewhere and let the user try again.
            NSLog(@"Signup error: %@", errorString);
            
            loginWarn.text = errorString;
        }
    }];
    
}

- (IBAction)login:(id)sender{
    
    loginWarn.text = @"";
    
    [PFUser logInWithUsernameInBackground:[userName text] password:[passWord text] 
            block:^(PFUser *user, NSError *error) {
        if (user) {
            PFUser *currentPFUser = [PFUser currentUser];
            NSLog(@"Current logged in user is %@", currentPFUser.username);
            
            // first, check if local GB user exists
            GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
            GBUser *localGBUser = [dataModel getUserByID:currentPFUser.username];
            
            if (!localGBUser) {
                // create GB user
                [dataModel createUser:currentPFUser.username withUserName:currentPFUser.username withPassword:@""]; //FIXME: use real encrypted pw
                localGBUser = [dataModel getUserByID:currentPFUser.username];
            }
            
            // set local GB user
            [dataModel setLocalUserName:localGBUser.UserName]; 
            [dataModel setLocalUserID:localGBUser.UserName]; 
            
            
            // go to Dashboard view
            Groubit_iOSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate.tabController dismissModalViewControllerAnimated:false];
            //[appDelegate.window setRootViewController:appDelegate.tabController];
            //[appDelegate.window makeKeyAndVisible];
                
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            // the username or password is invalid.
            NSLog(@"Login error: %@", errorString);
            
            loginWarn.text = errorString;
        }
    }];
}

- (IBAction)logout:(id)sender{
    [PFUser logOut];
    PFUser *currentPFUser = [PFUser currentUser]; // this will now be nil
    if (currentPFUser) {
        NSLog(@"Current user name is %@", currentPFUser.username);
    } else {
        NSLog(@"The user is logged out!");
    }
}

// Hide the keyboard after Return is pressed
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField{
    [theTextField resignFirstResponder];
    
    return YES;
}

@end
