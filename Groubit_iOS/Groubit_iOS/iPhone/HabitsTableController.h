//
//  HabitsTableController.h
//  Groubit_iOS
//
//  Created by Sean Chen on 1/30/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HabitsDetailViewController.h"
#import "HabitsAddTableViewController.h"
//#import "HabitsAddController.h"

@interface HabitsTableController : UITableViewController
{
    NSMutableArray *habitsList;
    HabitsDetailViewController *habitsDetailController;
    HabitsAddTableViewController *habitsAddTableViewController;
    //HabitsAddController *habitsAddController;
}


@end
