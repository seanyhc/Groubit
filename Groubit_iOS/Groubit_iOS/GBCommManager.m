//
//  GBCommManager.m
//  Groubit_iOS
//
//  Created by Jeffrey on 5/3/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import "GBCommManager.h"
#import "GBDataModelManager.h"
#import "DDLog.h"
#import "Parse/Parse.h"

@implementation GBCommManager

static GBCommManager* commManager = nil; 

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

+(GBCommManager*) getCommManager
{
    if(commManager == nil)
    {
        commManager = [[GBCommManager alloc] init];
    }
    return commManager;
}



- (void) onReceiveNotification{
    
    // TODO
}

- (void) sendParseNotification: (NSString*) channelID withData : (NSDictionary*) data{

    DDLogCVerbose(@"ENTER GBCommManager::sendParseNotification() channelID=%@, data=%@", channelID, data);

    PFPush *push = [[PFPush alloc] init];
    [push setChannel:channelID];
    [push setData:data];
    
    // J2DO : use async callback instead of synchronous function
    [push sendPushInBackground];
}



- (void) sendFriendRequestNotification: (NSString*) username withMessage : (NSString*) message{

    
    DDLogCVerbose(@"ENTER GBCommManager::sendFriendRequestNotification() username=%@, message=%@", username, message);
    
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSString *channelID = [NSString stringWithFormat:@"GB_PRI_CHANNEL_%@", username];
    
    NSString *notificationType = [NSString stringWithString:@"friendRequest"];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                            notificationType, @"GB_NOTIFICATION_TYPE",
                            dataModel.localUserName, @"GB_NOTIFICTION_FROM",
                            message, @"GB_NOTIFICATION_MESSAGE",
                            nil];

    [self sendParseNotification:channelID withData:data];
    

}

- (void) sendFriendConfirmationNotification: (NSString*) userID withMessage : (NSString*) message{

    DDLogCVerbose(@"ENTER GBCommManager::sendFriendConfirmationNotification() username=%@, message=%@", userID, message);
    
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSString *channelID = [NSString stringWithFormat:@"GB_PRI_CHANNEL_%@", userID];
    
    NSString *notificationType = [NSString stringWithString:@"friendConfirmation"];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          notificationType, @"GB_NOTIFICATION_TYPE",
                          dataModel.localUserName, @"GB_NOTIFICTION_FROM",
                          message, @"GB_NOTIFICATION_MESSAGE",
                          nil];
    
    
    [self sendParseNotification:channelID withData:data];
    

}

- (void) sendNannyRequestNotification : (NSString*) username withMessage : (NSString*) message withHabitID : (NSString*) habitID{

    DDLogCVerbose(@"ENTER GBCommManager::sendNannyRequestNotification() username=%@, message=%@, habitID=%@", username, message,habitID);
    
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSString *channelID = [NSString stringWithFormat:@"GB_PRI_CHANNEL_%@", username];
    
    NSString *notificationType = [NSString stringWithString:@"nannyRequest"];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          notificationType, @"GB_NOTIFICATION_TYPE",
                          dataModel.localUserName, @"GB_NOTIFICTION_FROM",
                          message, @"GB_NOTIFICATION_MESSAGE",
                          habitID, @"GB_NOTIFICATION_HABIT_ID",
                          nil];
    
    
    
    [self sendParseNotification:channelID withData:data];
    
}

- (void) sendNannyConfirmNotification : (NSString*) username withMessage : (NSString*) message{

    DDLogCVerbose(@"ENTER GBCommManager::sendNannyConfirmationNotification() username=%@, message=%@", username, message);
    
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSString *channelID = [NSString stringWithFormat:@"GB_PRI_CHANNEL_%@", username];
    
    NSString *notificationType = [NSString stringWithString:@"nannyConfirmation"];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          notificationType, @"GB_NOTIFICATION_TYPE",
                          dataModel.localUserName, @"GB_NOTIFICTION_FROM",
                          message, @"GB_NOTIFICATION_MESSAGE",
                          nil];
    
    
    [self sendParseNotification:channelID withData:data];
}

- (void) sendReminderNotification : (NSString*) userID withMessage : (NSString*) message{

    DDLogCVerbose(@"ENTER GBCommManager::sendReminderNotification() username=%@, message=%@", userID, message);
    
    
    GBDataModelManager* dataModel = [GBDataModelManager getDataModelManager];
    
    NSString *channelID = [NSString stringWithFormat:@"GB_PRI_CHANNEL_%@", userID];
    
    NSString *notificationType = [NSString stringWithString:@"reminder"];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          notificationType, @"GB_NOTIFICATION_TYPE",
                          dataModel.localUserName, @"GB_NOTIFICTION_FROM",
                          message, @"GB_NOTIFICATION_MESSAGE",
                          nil];
    
    [self sendParseNotification:channelID withData:data];
}



@end
