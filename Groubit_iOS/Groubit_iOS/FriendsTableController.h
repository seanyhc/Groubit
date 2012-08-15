//
//  FriendsTableController.h
//  Groubit_iOS
//
//  Created by Sean Chen on 12/28/11.
//  Copyright 2011 UCB MIMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsDetailViewController.h"
#import "FriendsAddViewController.h"


@interface FriendsTableController : UITableViewController
{
    NSMutableArray *friendsList;
    FriendsDetailViewController *friendsDetailController;
    FriendsAddViewController *friendsAddController;
}

@end
