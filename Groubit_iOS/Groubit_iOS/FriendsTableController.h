//
//  FriendsTableController.h
//  Groubit_iOS
//
//  Created by Sean Chen on 12/28/11.
//  Copyright 2011 UCB MIMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsDetailController.h"
#import "FriendsAddController.h"


@interface FriendsTableController : UITableViewController
{
    NSMutableArray *friendsList;
    FriendsDetailController *friendsDetailController;
    FriendsAddController *friendsAddController;
}

@end
