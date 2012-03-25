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
    IBOutlet UITextView *loginWarn;
}

@property (nonatomic, strong) UITextField *userName;
@property (nonatomic, strong) UITextField *passWord;
@property (nonatomic, strong) UITextView *loginWarn;

- (IBAction)register:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)logout:(id)sender;

@end
