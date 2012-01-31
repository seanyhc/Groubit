//
//  TaipeiStation.h
//  Groubit_iOS
//
//  Created by Jeffrey on 1/20/12.
//  Copyright 2012 UCB MIMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBDataModelManager.h"

@interface TaipeiStation : NSObject
{
    GBDataModelManager *dataModel;
    NSDate *lastSyncDate;

}

@property (nonatomic, retain) NSDate *lastSyncDate;

- (bool)syncAll;
- (bool)syncUserData;
- (bool)syncRelation;
- (bool)syncHabit;
- (bool)syncTasks: (NSString*) habitID;

+(TaipeiStation*) getSyncEngine;

@end

