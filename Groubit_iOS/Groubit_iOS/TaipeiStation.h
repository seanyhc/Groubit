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
    NSTimer *syncTimer;

}

@property (nonatomic, retain) NSDate *lastSyncDate;
@property (nonatomic, assign) NSTimer *syncTimer;

- (bool)syncAll;
- (bool)syncUserData;
- (bool)syncRelation;
- (bool)syncHabit;
- (bool)syncNotification;
- (bool)syncTasks: (NSString*) habitID;
- (void) startSyncTimer:(NSTimer*) timer;
- (void) stopSyncTimer;

+(bool) enableRegularSync;
+(TaipeiStation*) getSyncEngine;

@end

