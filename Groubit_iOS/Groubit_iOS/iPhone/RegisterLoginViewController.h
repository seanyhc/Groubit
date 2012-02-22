//
//  RegisterLoginViewController.h
//  Groubit_iOS
//
//  Created by Joey Tseng on 2/10/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterLoginViewController : UIViewController
{
    IBOutlet UITextField *userName;
    IBOutlet UITextField *passWord;
}

@property (nonatomic, retain) UITextField *userName;
@property (nonatomic, retain) UITextField *passWord;

- (IBAction)register:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)logout:(id)sender;

@end
