//
//  HabitsViewController.h
//  Groubit_iOS
//
//  Created by Sean Chen on 12/28/11.
//  Copyright 2011 UCB MIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GBHabit;
@interface HabitsDetailViewController : UIViewController
{
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *descLabel;
    IBOutlet UILabel *freqLabel;
    
    GBHabit *currentHabit;
}
@property (nonatomic, assign) GBHabit *currentHabit;
@end
