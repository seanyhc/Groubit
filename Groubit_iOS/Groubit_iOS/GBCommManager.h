//
//  GBCommManager.h
//  Groubit_iOS
//
//  Created by Jeffrey on 5/3/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBCommManager : NSObject

typedef enum{
    kBroadcastChannel,
    kVisibleUserChannel,
    kInvisibleUserChannel
} GBChannelType;



+ (GBCommManager*) getCommManager;


/*
- (void) sendNotification: (NSString*) channelID withChannelType: (GBChannelType) channelType withMessage :(NSString*) message ;
*/
 
- (void) onReceiveNotification;

- (void) sendParseNotification: (NSString*) channelID withData : (NSDictionary*) data;


// Interfaces for UI layer

- (void) sendFriendRequestNotification: (NSString*) username withMessage : (NSString*) message;

- (void) sendFriendConfirmationNotification: (NSString*) userID withMessage : (NSString*) message;

- (void) sendNannyRequestNotification : (NSString*) username withMessage : (NSString*) message withHabitID : (NSString*) habitID;

- (void) sendNannyConfirmNotification : (NSString*) username withMessage : (NSString*) message;

- (void) sendReminderNotification : (NSString*) userID withMessage : (NSString*) message;




@end
